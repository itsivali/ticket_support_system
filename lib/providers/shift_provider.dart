
import 'package:flutter/foundation.dart';



class ShiftProvider with ChangeNotifier {

  List<dynamic> _currentShifts = [];



  List<dynamic> get currentShifts => _currentShifts;



  Future<void> fetchCurrentShifts() async {

    // TODO: Implement shift fetching logic

    _currentShifts = [];

    notifyListeners();

  }

}
