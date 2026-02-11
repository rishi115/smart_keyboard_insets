# Smart Keyboard Insets

[![pub package](https://img.shields.io/pub/v/smart_keyboard_insets.svg)](https://pub.dev/packages/smart_keyboard_insets)
[![GitHub](https://img.shields.io/github/license/rishi115/smart_keyboard_insets)](https://github.com/rishi115/smart_keyboard_insets/blob/main/LICENSE)

A Flutter plugin that provides accurate keyboard height and safe area bottom inset detection on Android and iOS. Perfect for chat apps and any UI that needs to respond to keyboard state changes.

## Why Use This Plugin?

- **Smooth UI transitions** - No more janky or laggy list scrolling when keyboard opens/closes
- **Sticker/Emoji keyboard support** - Get accurate height for custom keyboards, sticker panels, and emoji pickers
- **Real-time updates** - Know the exact keyboard height as it animates, not just when fully open
- **Works with any keyboard type** - System keyboard, third-party keyboards, custom input panels

## Features

- Real-time keyboard height detection during animation
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
  smart_keyboard_insets: ^0.0.1
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
