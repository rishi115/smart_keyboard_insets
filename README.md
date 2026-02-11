# Smart Keyboard Insets

A Flutter plugin that provides accurate keyboard height and safe area bottom inset detection on Android and iOS. Perfect for chat apps and any UI that needs to respond to keyboard state changes.

## Features

- Real-time keyboard height detection
- Safe area bottom inset calculation
- Works with gesture navigation and 3-button navigation on Android
- Smooth animated transitions with `AnimatedKeyboardPadding`
- Multiple API styles: Stream, ValueNotifier, and helper widgets
- Proper lifecycle management (no memory leaks)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  smart_keyboard_insets: ^0.0.1
```

## Usage

### Using AnimatedKeyboardPadding (Recommended)

The easiest way to handle keyboard insets:

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

```dart
ValueListenableBuilder<KeyboardMetrics>(
  valueListenable: SmartKeyboardInsets.instance.metricsNotifier,
  builder: (context, metrics, child) {
    return Text('Keyboard height: ${metrics.keyboardHeight}');
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

## License

MIT License - see LICENSE file for details.
