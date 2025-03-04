import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> init() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}