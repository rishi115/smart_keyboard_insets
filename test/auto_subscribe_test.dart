import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_keyboard_insets/smart_keyboard_insets.dart';

// Kept in its own file: once started, the automatic subscription lives for
// the rest of the test isolate.
void main() {
  testWidgets('KeyboardPadding updates without a manual stream listener',
      (tester) async {
    late MockStreamHandlerEventSink events;
    tester.binding.defaultBinaryMessenger.setMockStreamHandler(
      const EventChannel('smart_keyboard_insets/event'),
      MockStreamHandler.inline(onListen: (arguments, sink) {
        events = sink;
      }),
    );
    SmartKeyboardInsets.debugAutoSubscribeOnAnyPlatform = true;
    addTearDown(
        () => SmartKeyboardInsets.debugAutoSubscribeOnAnyPlatform = false);

    await tester.pumpWidget(
      const KeyboardPadding(child: SizedBox(key: Key('child'))),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));

    events.success(const {
      'keyboardHeight': 336,
      'safeAreaBottom': 34,
      'isKeyboardVisible': true,
    });
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    final padding = tester.widget<Padding>(find
        .ancestor(
            of: find.byKey(const Key('child')), matching: find.byType(Padding))
        .first);
    expect(padding.padding.resolve(TextDirection.ltr).bottom, 336);
  });
}
