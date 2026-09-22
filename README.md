# Smart Keyboard Insets

[![pub package](https://img.shields.io/pub/v/smart_keyboard_insets.svg)](https://pub.dev/packages/smart_keyboard_insets)
[![CI](https://github.com/rishi115/smart_keyboard_insets/actions/workflows/ci.yml/badge.svg)](https://github.com/rishi115/smart_keyboard_insets/actions/workflows/ci.yml)
[![pub points](https://img.shields.io/pub/points/smart_keyboard_insets)](https://pub.dev/packages/smart_keyboard_insets/score)
[![pub likes](https://img.shields.io/pub/likes/smart_keyboard_insets)](https://pub.dev/packages/smart_keyboard_insets/score)
[![platform](https://img.shields.io/badge/platform-android%20%7C%20ios-blue)](https://pub.dev/packages/smart_keyboard_insets)
[![GitHub](https://img.shields.io/github/license/rishi115/smart_keyboard_insets)](https://github.com/rishi115/smart_keyboard_insets/blob/main/LICENSE)

A Flutter plugin that provides accurate keyboard height and safe area bottom inset detection on Android and iOS. Built for chat apps: composers that sit right on top of the keyboard, and sticker/emoji panels that open at exactly the keyboard's height.

<p align="center">
  <img src="https://raw.githubusercontent.com/rishi115/smart_keyboard_insets/main/doc/demo.gif" alt="Chat composer following the keyboard, then swapping to a sticker panel of the same height" width="300">
</p>

## Why not just use `MediaQuery.viewInsets`?

For a simple form, `MediaQuery.viewInsets.bottom` is fine. Chat UIs need more:

| | `MediaQuery.viewInsets` | `smart_keyboard_insets` |
|---|---|---|
| Final keyboard height | Only known once the open animation finishes | Reported as the keyboard starts to open (iOS), and on every layout change (Android) |
| Sizing a sticker/emoji panel to match the keyboard | Height drops to 0 as soon as the keyboard closes, so the panel jumps | Remember the last `keyboardHeight` and open the panel at exactly that size |
| Safe area when the keyboard is hidden | Combine `viewInsets` and `viewPadding` yourself | `safeAreaBottom` included in the same `KeyboardMetrics` |
| Access outside `build()` | Needs a `BuildContext` | `Stream`, `ValueNotifier`, or a one-time `getCurrentMetrics()` call |
| Ready-made widgets | None | `KeyboardPadding` and `AnimatedKeyboardPadding` |

## Features

- Keyboard height as soon as the keyboard starts to appear, not after it settles
- Safe area bottom inset calculation
- Works with gesture navigation and 3-button navigation on Android
- Smooth animated transitions with `AnimatedKeyboardPadding`
- Multiple API styles: Stream, ValueNotifier, and helper widgets
- Proper lifecycle management (no memory leaks)
- Support for custom keyboards and sticker panels

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  smart_keyboard_insets: ^0.2.0
```

## Usage

### Using AnimatedKeyboardPadding (Recommended)

The easiest way to handle keyboard insets with smooth animations:

```dart
Scaffold(
  resizeToAvoidBottomInset: false, // Important: disable default behavior
  body: Column(
    children: [
      Expanded(child: MessageList()),
      AnimatedKeyboardPadding(
        child: ComposerWidget(),
      ),
    ],
  ),
)
```

### Using KeyboardPadding (No Animation)

```dart
KeyboardPadding(
  child: YourBottomWidget(),
)
```

### Using ValueNotifier

Perfect for building custom sticker/emoji panels that match keyboard height:

```dart
ValueListenableBuilder<KeyboardMetrics>(
  valueListenable: SmartKeyboardInsets.instance.metricsNotifier,
  builder: (context, metrics, child) {
    // Use metrics.keyboardHeight to size your sticker panel
    return StickerPanel(
      height: metrics.isKeyboardVisible ? metrics.keyboardHeight : 300,
    );
  },
)
```

### Using Stream

```dart
@override
void initState() {
  super.initState();
  SmartKeyboardInsets.instance.metricsStream.listen((metrics) {
    print('Keyboard visible: ${metrics.isKeyboardVisible}');
    print('Keyboard height: ${metrics.keyboardHeight}');
    print('Safe area bottom: ${metrics.safeAreaBottom}');
  });
}
```

### One-Time Query

```dart
final metrics = await SmartKeyboardInsets.instance.getCurrentMetrics();
print('Current keyboard height: ${metrics.keyboardHeight}');
```

## KeyboardMetrics

The `KeyboardMetrics` class contains:

| Property | Type | Description |
|----------|------|-------------|
| `keyboardHeight` | `double` | Keyboard height in logical pixels (0 when hidden) |
| `safeAreaBottom` | `double` | Bottom safe area inset in logical pixels |
| `isKeyboardVisible` | `bool` | Whether the keyboard is currently visible |

## Platform Support

| Platform | Minimum Version |
|----------|-----------------|
| Android | API 21 (Android 5.0) |
| iOS | iOS 12.0 |

## Important Notes

1. Set `resizeToAvoidBottomInset: false` on your Scaffold when using `KeyboardPadding` or `AnimatedKeyboardPadding` to avoid double padding.

2. For chat apps with reversed lists (`reverse: true`), you don't need manual scroll handling - the list stays anchored automatically.

3. For sticker/emoji panels, use `metricsNotifier` to get the keyboard height and size your panel accordingly.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.
