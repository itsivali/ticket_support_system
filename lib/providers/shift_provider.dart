import 'package:flutter/foundation.dart';
import '../models/shift_schedule.dart';
import '../services/shift_service.dart';
import '../utils/console_logger.dart';

class ShiftProvider extends ChangeNotifier {
  final ShiftService _shiftService = ShiftService();
  List<ShiftSchedule> _currentShifts = [];
  bool _isLoading = false;
  String? _error;

  List<ShiftSchedule> get currentShifts => _currentShifts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCurrentShifts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final shifts = await _shiftService.getAllShifts();
      _currentShifts = shifts;
    } catch (e) {
      _error = e.toString();
      ConsoleLogger.error('Failed to fetch shifts', e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAgentSchedule(String agentId, ShiftSchedule schedule) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate schedule
      if (!_validateSchedule(schedule)) {
        throw Exception('Invalid schedule configuration');
      }

      // Update or create schedule
      final updatedSchedule = await _shiftService.updateShift(
        schedule.id.isEmpty ? null : schedule.id,
        schedule,
      );

      // Update local state
      final index = _currentShifts.indexWhere((s) => s.agentId == agentId);
      if (index != -1) {
        _currentShifts[index] = updatedSchedule;
      } else {
        _currentShifts.add(updatedSchedule);
      }

      ConsoleLogger.info(
        'Schedule updated successfully',
        'Agent: $agentId, Shift ID: ${updatedSchedule.id}'
      );

      return true;
    } catch (e) {
      _error = e.toString();
      ConsoleLogger.error('Failed to update schedule', e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ShiftSchedule?> getAgentSchedule(String agentId) async {
    try {
      return await _shiftService.getAgentShift(agentId);
    } catch (e) {
      ConsoleLogger.error('Failed to get agent schedule', e.toString());
      return null;
    }
  }

  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _shiftService.deleteShift(scheduleId);
      if (success) {
        _currentShifts.removeWhere((s) => s.id == scheduleId);
      }

      return success;
    } catch (e) {
      ConsoleLogger.error('Failed to delete schedule', e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _validateSchedule(ShiftSchedule schedule) {
    // Ensure at least one weekday is selected
    if (schedule.weekdays.isEmpty) {
      return false;
    }

    // Validate working hours
    if (schedule.hoursPerDay <= 0 || schedule.hoursPerDay > 24) {
      return false;
    }

    // Ensure end time is after start time
    if (!schedule.endTime.isAfter(schedule.startTime)) {
      return false;
    }

    // Validate weekday values
    if (schedule.weekdays.any((day) => day < 1 || day > 7)) {
      return false;
    }

    return true;
  }

  List<ShiftSchedule> getActiveShifts() {
    final now = DateTime.now();
    return _currentShifts.where((shift) => 
      shift.isActive && 
      shift.weekdays.contains(now.weekday) &&
      shift.isWorkingAt(now)
    ).toList();
  }

  bool isAgentWorking(String agentId) {
    final now = DateTime.now();
    return _currentShifts.any((shift) => 
      shift.agentId == agentId &&
      shift.isActive &&
      shift.weekdays.contains(now.weekday) &&
      shift.isWorkingAt(now)
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}