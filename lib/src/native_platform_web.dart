/// Whether this platform has the native Android/iOS implementation.
///
/// Always false on the web, which uses the view-metrics fallback.
bool get isNativePlatform => false;
