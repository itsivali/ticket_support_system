// Dart: lib/src/db_initializer.dart
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logging/logging.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  final Logger _logger = Logger('DatabaseHelper');

  DatabaseHelper._privateConstructor();

  Future<void> init() async {
    // Connect to MongoDB using the mongo_dart package with the database name "ticketing-db".
    final db = Db('mongodb://localhost:27017/ticketing-db');
    try {
      await db.open();
      _logger.info('Successfully connected to MongoDB');
       _logger.info('Successfully connected to MongoDB');
    } catch (e) {
      _logger.severe('Error connecting to MongoDB: $e');
       _logger.info('Error connecting to MongoDB: $e');
    }
  }
}

Future<void> init() async {
  await DatabaseHelper.instance.init();
}