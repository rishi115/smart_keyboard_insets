import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_keyboard_insets/smart_keyboard_insets.dart';

void main() {
  const eventChannel = EventChannel('smart_keyboard_insets/event');
  const keyboardOpen = KeyboardMetrics(
    keyboardHeight: 336,
    safeAreaBottom: 34,
    isKeyboardVisible: true,
  );
  const keyboardClosed = KeyboardMetrics(
    keyboardHeight: 0,
    safeAreaBottom: 34,
    isKeyboardVisible: false,
  );

  late MockStreamHandlerEventSink keyboardEvents;

  setUp(() {
    // The plugin is a singleton, so clear state left by the previous test.
    SmartKeyboardInsets.instance.metricsNotifier.value = KeyboardMetrics.hidden;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
          eventChannel,
          MockStreamHandler.inline(
            onListen: (arguments, events) {
              keyboardEvents = events;
            },
          ),
        );
  });

  /// Sends a keyboard event the way the native side would and lets it arrive.
  Future<void> sendKeyboard(
    WidgetTester tester,
    KeyboardMetrics metrics,
  ) async {
    keyboardEvents.success(metrics.toMap());
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1206, 2622); // iPhone 17 Pro
    tester.view.devicePixelRatio = 3;
    // Status bar and home indicator, in physical pixels.
    tester.view.padding = const FakeViewPadding(top: 186, bottom: 102);
    tester.view.viewPadding = const FakeViewPadding(top: 186, bottom: 102);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp());
    await tester.pump();
  }

  testWidgets('keyboard to sticker panel and back never overflows', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Chat Demo'), findsOneWidget);

    // Keyboard opens.
    await tester.tap(find.byType(TextField));
    await sendKeyboard(tester, keyboardOpen);
    await tester.pumpAndSettle();

    // Switch to the sticker panel; the keyboard reports hidden a bit later.
    await tester.tap(find.byIcon(Icons.emoji_emotions_outlined));
    await tester.pump(const Duration(milliseconds: 50));
    await sendKeyboard(tester, keyboardClosed);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.text('Sticker Panel (height: 336)'), findsOneWidget);

    // Switch back; the panel stays until the keyboard is visible again.
    await tester.tap(find.byIcon(Icons.keyboard));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Sticker Panel (height: 336)'), findsOneWidget);
    await sendKeyboard(tester, keyboardOpen);
    await tester.pumpAndSettle();
    expect(find.textContaining('Sticker Panel'), findsNothing);

    // Any RenderFlex overflow above would have failed the test already.
    expect(tester.takeException(), isNull);
  });

  testWidgets('sticker panel closes if no keyboard appears', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.emoji_emotions_outlined));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sticker Panel'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.keyboard));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sticker Panel'), findsNothing);
  });
}
