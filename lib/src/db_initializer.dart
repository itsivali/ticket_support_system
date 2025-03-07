class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<void> init() async {
    // Connect to MongoDB using the mongo_dart package.
    final db = Db('mongodb://localhost:27017/yourDatabaseName');
    try {
      await db.open();
      print('Successfully connected to MongoDB');
      // perform additional initialization if necessary
    } catch (e) {
      print('Error connecting to MongoDB: \$e');
    }
  }
}

Future<void> init() async {
  await DatabaseHelper.instance.init();
}
