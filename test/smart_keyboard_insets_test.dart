import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_keyboard_insets/smart_keyboard_insets.dart';

const _methodChannel = MethodChannel('smart_keyboard_insets/method');
const _eventChannel = EventChannel('smart_keyboard_insets/event');

const _open = KeyboardMetrics(
  keyboardHeight: 336,
  safeAreaBottom: 34,
  isKeyboardVisible: true,
);
const _closed = KeyboardMetrics(
  keyboardHeight: 0,
  safeAreaBottom: 34,
  isKeyboardVisible: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    SmartKeyboardInsets.instance.metricsNotifier.value = KeyboardMetrics.hidden;
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(_methodChannel, null);
    messenger.setMockStreamHandler(_eventChannel, null);
  });

  group('KeyboardMetrics', () {
    test('fromMap converts ints to doubles', () {
      final metrics = KeyboardMetrics.fromMap(const {
        'keyboardHeight': 336,
        'safeAreaBottom': 34,
        'isKeyboardVisible': true,
      });
      expect(metrics, _open);
    });

    test('fromMap falls back to hidden values for missing keys', () {
      expect(KeyboardMetrics.fromMap(const {}), KeyboardMetrics.hidden);
    });

    test('toMap round-trips through fromMap', () {
      expect(KeyboardMetrics.fromMap(_open.toMap()), _open);
    });

    test('equality and hashCode are value based', () {
      const copy = KeyboardMetrics(
        keyboardHeight: 336,
        safeAreaBottom: 34,
        isKeyboardVisible: true,
      );
      expect(copy, _open);
      expect(copy.hashCode, _open.hashCode);
      expect(copy, isNot(_closed));
    });
  });

  group('getCurrentMetrics', () {
    test('parses the platform result', () async {
      messenger.setMockMethodCallHandler(_methodChannel, (call) async {
        expect(call.method, 'getCurrentMetrics');
        return _open.toMap();
      });
      expect(await SmartKeyboardInsets.instance.getCurrentMetrics(), _open);
    });

    test('returns hidden when the platform call fails', () async {
      messenger.setMockMethodCallHandler(_methodChannel, (call) async {
        throw PlatformException(code: 'NO_ACTIVITY');
      });
      expect(
        await SmartKeyboardInsets.instance.getCurrentMetrics(),
        KeyboardMetrics.hidden,
      );
    });
  });

  test('metricsStream emits platform events and updates metricsNotifier',
      () async {
    messenger.setMockStreamHandler(
      _eventChannel,
      MockStreamHandler.inline(onListen: (arguments, events) {
        events.success(_open.toMap());
        events.success(_closed.toMap());
      }),
    );

    final received =
        await SmartKeyboardInsets.instance.metricsStream.take(2).toList();

    expect(received, [_open, _closed]);
    expect(SmartKeyboardInsets.instance.metricsNotifier.value, _closed);
  });

  group('padding widgets', () {
    double bottomPadding(WidgetTester tester, Type paddingType) {
      final Finder finder = find.ancestor(
        of: find.byKey(const Key('child')),
        matching: find.byType(paddingType),
      );
      final EdgeInsetsGeometry padding = paddingType == AnimatedPadding
          ? tester.widget<AnimatedPadding>(finder).padding
          : tester.widget<Padding>(finder.first).padding;
      return padding.resolve(TextDirection.ltr).bottom;
    }

    testWidgets('KeyboardPadding uses keyboard height or safe area',
        (tester) async {
      final notifier = SmartKeyboardInsets.instance.metricsNotifier;
      await tester.pumpWidget(
        const KeyboardPadding(child: SizedBox(key: Key('child'))),
      );
      expect(bottomPadding(tester, Padding), 0);

      notifier.value = _open;
      await tester.pump();
      expect(bottomPadding(tester, Padding), 336);

      notifier.value = _closed;
      await tester.pump();
      expect(bottomPadding(tester, Padding), 34);
    });

    testWidgets('AnimatedKeyboardPadding animates to the new padding',
        (tester) async {
      final notifier = SmartKeyboardInsets.instance.metricsNotifier;
      await tester.pumpWidget(
        const AnimatedKeyboardPadding(child: SizedBox(key: Key('child'))),
      );

      notifier.value = _open;
      await tester.pumpAndSettle();
      expect(bottomPadding(tester, AnimatedPadding), 336);

      notifier.value = _closed;
      await tester.pumpAndSettle();
      expect(bottomPadding(tester, AnimatedPadding), 34);
    });
  });
}
