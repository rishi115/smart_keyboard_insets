import 'dart:io' show Platform;

/// Whether this platform has the native Android/iOS implementation.
bool get isNativePlatform => Platform.isAndroid || Platform.isIOS;
