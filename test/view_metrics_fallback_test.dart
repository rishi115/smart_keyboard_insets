import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_keyboard_insets/smart_keyboard_insets.dart';

// Tests run on the host (not Android/iOS), so the plugin uses the fallback
// that reads Flutter's view metrics, the same path as web and desktop.
// Kept in its own file because the plugin is a singleton.
void main() {
  void setView(
    WidgetTester tester, {
    required double keyboard,
    required double safeArea,
  }) {
    const ratio = 3.0;
    tester.view.devicePixelRatio = ratio;
    tester.view.viewPadding = FakeViewPadding(bottom: safeArea * ratio);
    tester.view.viewInsets = FakeViewPadding(bottom: keyboard * ratio);
  }

  testWidgets('getCurrentMetrics reads the view metrics', (tester) async {
    addTearDown(tester.view.reset);
    setView(tester, keyboard: 300, safeArea: 34);

    expect(
      await SmartKeyboardInsets.instance.getCurrentMetrics(),
      const KeyboardMetrics(
        keyboardHeight: 300,
        safeAreaBottom: 34,
        isKeyboardVisible: true,
      ),
    );
  });

  testWidgets('padding widgets follow the view metrics with no setup', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    setView(tester, keyboard: 0, safeArea: 34);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: KeyboardPadding(child: SizedBox(key: Key('child'))),
      ),
    );
    await tester.pump();

    double bottomPadding() => tester
        .widget<Padding>(
          find
              .ancestor(
                of: find.byKey(const Key('child')),
                matching: find.byType(Padding),
              )
              .first,
        )
        .padding
        .resolve(TextDirection.ltr)
        .bottom;

    expect(bottomPadding(), 34);

    setView(tester, keyboard: 300, safeArea: 34);
    await tester.pump();
    expect(bottomPadding(), 300);
    expect(
      SmartKeyboardInsets.instance.metricsNotifier.value.isKeyboardVisible,
      isTrue,
    );

    setView(tester, keyboard: 0, safeArea: 34);
    await tester.pump();
    expect(bottomPadding(), 34);
  });

  testWidgets('metricsStream emits when the view metrics change', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    setView(tester, keyboard: 0, safeArea: 20);

    final received = <KeyboardMetrics>[];
    final subscription = SmartKeyboardInsets.instance.metricsStream.listen(
      received.add,
    );
    addTearDown(subscription.cancel);
    await tester.pump();

    setView(tester, keyboard: 250, safeArea: 20);
    await tester.pump();

    expect(
      received.last,
      const KeyboardMetrics(
        keyboardHeight: 250,
        safeAreaBottom: 20,
        isKeyboardVisible: true,
      ),
    );
  });
}
