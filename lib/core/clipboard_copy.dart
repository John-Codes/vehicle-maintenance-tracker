// Clipboard with an http-tolerant fallback: picks the web or native impl.
export 'clipboard_copy_io.dart' if (dart.library.html) 'clipboard_copy_web.dart';
