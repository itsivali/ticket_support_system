import '../services/database_helper.dart';

Future<void> init() async {
  await DatabaseHelper.instance.init();
}