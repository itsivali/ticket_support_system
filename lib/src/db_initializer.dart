export 'db_initializer_stub.dart'
    if (dart.library.html) 'db_initializer_web.dart'
    if (dart.library.io) 'db_initializer_ffi.dart';