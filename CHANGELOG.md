# Changelog

## 0.3.1

- Web, macOS, Windows and Linux support: on these platforms the keyboard metrics come from Flutter's view metrics, so `metricsStream`, `metricsNotifier`, `getCurrentMetrics()` and the padding widgets work there too (Android and iOS keep the native implementation).
- Swift Package Manager support for iOS (CocoaPods still works).
- iOS minimum is now 13.0, matching Flutter's own minimum.
- Clearer pub.dev description.

## 0.3.0

- **Fix:** Android apps using AGP 9 with built-in Kotlin (the default since Flutter 3.47) failed to build with this plugin. The plugin now uses built-in Kotlin instead of applying the Kotlin Gradle plugin, as described in Flutter's migration guide.
- **Breaking:** requires Flutter 3.44 / Dart 3.12 or later. Apps on older Flutter versions keep resolving 0.2.0.
- iOS podspec version now matches the package version.
- Example app migrated to AGP 9 with built-in Kotlin.

## 0.2.0

- **Fix:** `KeyboardPadding`, `AnimatedKeyboardPadding` and `metricsNotifier` now update on their own on Android and iOS. Previously they stayed at 0 unless something was listening to `metricsStream`.
- Example app: switching between the keyboard and the sticker panel no longer overflows
- Real unit and widget tests, and GitHub Actions CI

## 0.1.1

- README: demo GIF, comparison with `MediaQuery.viewInsets`, and badges
- Added a pub.dev screenshot
- Example app: hide the debug banner

## 0.1.0

- Changed Android package from `com.example.smart_keyboard_insets` to `com.rishi115.smart_keyboard_insets`
- Filled in LICENSE copyright holder and year
- Added library-level documentation for `keyboard_metrics`, `keyboard_padding`, and `animated_keyboard_padding`

## 0.0.1

- Initial release
- `KeyboardMetrics` data class with keyboard height, safe area bottom, and visibility state
- `SmartKeyboardInsets` API with Stream, ValueNotifier, and one-time query support
- `KeyboardPadding` widget for automatic bottom padding
- `AnimatedKeyboardPadding` widget for smooth animated transitions
- Android support with ViewTreeObserver and WindowInsets
- iOS support with keyboard notifications and safeAreaInsets
- Example chat app demonstrating usage
