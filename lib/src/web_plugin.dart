import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Registers the web implementation.
///
/// There is nothing to set up: `SmartKeyboardInsets` reads Flutter's view
/// metrics on the web instead of talking to native code.
class SmartKeyboardInsetsWebPlugin {
  /// Called by Flutter's web plugin registrant.
  static void registerWith(Registrar registrar) {}
}
