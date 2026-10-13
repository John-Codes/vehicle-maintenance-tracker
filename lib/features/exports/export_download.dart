// Platform-safe entry: web gets the real browser download; native gets a
// no-op because native exports go through share sheets instead.
export 'export_download_io.dart' if (dart.library.html) 'export_download_web.dart';
