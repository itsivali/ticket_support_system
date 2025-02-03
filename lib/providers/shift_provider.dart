import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/shift_schedule.dart';
import '../models/shift.dart';
import '../models/agent.dart' as agent_model;
import '../services/shift_service.dart';
import '../utils/console_logger.dart';

class ShiftProvider extends ChangeNotifier {
  final ShiftService _shiftService;
  List<ShiftSchedule> _currentShifts = [];
  bool _isLoading = false;
  String? _error;

  // Constructor with dependency injection
  ShiftProvider({ShiftService? shiftService}) 
    : _shiftService = shiftService ?? ShiftService();

  // Getters
  List<ShiftSchedule> get currentShifts => List.unmodifiable(_currentShifts);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // Get shifts for a specific agent
  List<ShiftSchedule> getAgentShifts(String agentId) {
    return _currentShifts.where((shift) => shift.agentId == agentId).toList();
  }

  // Get currently active shifts
  List<ShiftSchedule> getActiveShifts() {
    final now = DateTime.now();
    return _currentShifts.where((shift) => 
      shift.isActive && 
      shift.weekdays.contains(now.weekday) &&
      shift.isWorkingAt(now)
    ).toList();
  }

  // Check if agent is currently working
  bool isAgentWorking(String agentId) {
    final now = DateTime.now();
    return _currentShifts.any((shift) => 
      shift.agentId == agentId &&
      shift.isActive &&
      shift.weekdays.contains(now.weekday) &&
      shift.isWorkingAt(now)
    );
  }

  // Fetch all shifts
  Future<void> fetchCurrentShifts() async {
    if (_isLoading) return;
    
    _setLoading(true);
    _clearError();

    try {
      final shifts = await _shiftService.getAllShifts();
      _currentShifts = shifts.map((shift) => shift as ShiftSchedule).toList();
      _setLoading(false);
    } catch (e) {
      _handleError('Failed to fetch shifts', e);
    }
  }

  // Update agent's schedule
  Future<bool> updateAgentSchedule(String agentId, ShiftSchedule schedule) async {
    if (_isLoading) return false;
    
    _setLoading(true);
    _clearError();

    try {
      // Validate schedule
      if (!_validateSchedule(schedule)) {
        throw Exception('Invalid schedule configuration');
      }

      final updatedShift = await _shiftService.updateShift(
        schedule.id.isEmpty ? null : schedule.id,
        Shift.fromMap(schedule.toShift()),
      );

      // Update local state
      final index = _currentShifts.indexWhere((s) => s.agentId == agentId);
      final updatedSchedule = ShiftSchedule.fromShift(updatedShift);
      if (index != -1) {
        _currentShifts[index] = updatedSchedule;
      } else {
        _currentShifts.add(updatedSchedule);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _handleError('Failed to update schedule', e);
      return false;
    }
  }

  // Delete a shift schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    if (_isLoading) return false;
    
    _setLoading(true);
    _clearError();

    try {
      final success = await _shiftService.deleteShift(scheduleId);
      if (success) {
        _currentShifts.removeWhere((s) => s.id == scheduleId);
        _setLoading(false);
      }
      return success;
    } catch (e) {
      _handleError('Failed to delete schedule', e);
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _handleError(String message, dynamic error) {
    _error = '$message: ${error.toString()}';
    ConsoleLogger.error(message, error.toString());
    _setLoading(false);
  }

  bool _validateSchedule(ShiftSchedule schedule) {
    if (schedule.weekdays.isEmpty) {
      return false;
    }

    if (schedule.weekdays.any((day) => day < 1 || day > 7)) {
      return false;
    }

    final startMinutes = schedule.startTime.hour * 60 + schedule.startTime.minute;
    final endMinutes = schedule.endTime.hour * 60 + schedule.endTime.minute;
    
    if (endMinutes <= startMinutes) {
      return false;
    }

    final workHours = (endMinutes - startMinutes) / 60;
    if (workHours < 1 || workHours > 24) {
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _currentShifts.clear();
    super.dispose();
  }
}