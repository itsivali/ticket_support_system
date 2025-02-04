import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agent.dart';
import '../../models/shift_schedule.dart';
import '../../providers/shift_provider.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/loading_overlay.dart';

class EditShiftScreen extends StatefulWidget {
  final Agent agent;
  final ShiftSchedule shift;

  const EditShiftScreen({
    super.key,
    required this.agent,
    required this.shift,
  });

  @override
  State<EditShiftScreen> createState() => _EditShiftScreenState();
}

class _EditShiftScreenState extends State<EditShiftScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late Set<int> _selectedWeekdays;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _scheduleType;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _initializeShiftData();
  }

  void _initializeShiftData() {
    _selectedWeekdays = widget.shift.weekdays.toSet();
    _startTime = TimeOfDay.fromDateTime(widget.shift.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.shift.endTime);
    _scheduleType = widget.shift.scheduleType;
    _isActive = widget.shift.isActive;
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  bool _validateSchedule() {
    if (_selectedWeekdays.isEmpty) {
      UIHelpers.showErrorSnackBar(
        context: context,
        message: 'Please select at least one working day',
      );
      return false;
    }

    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      UIHelpers.showErrorSnackBar(
        context: context,
        message: 'End time must be after start time',
      );
      return false;
    }

    return true;
  }

  Future<void> _saveShift() async {
    if (!_formKey.currentState!.validate() || !_validateSchedule()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final updatedShift = ShiftSchedule(
        id: widget.shift.id,
        agentId: widget.agent.id,
        weekdays: _selectedWeekdays.toList()..sort(),
        startTime: DateTime(
          now.year,
          now.month,
          now.day,
          _startTime.hour,
          _startTime.minute,
        ),
        endTime: DateTime(
          now.year,
          now.month,
          now.day,
          _endTime.hour,
          _endTime.minute,
        ),
        isActive: _isActive,
        scheduleType: _scheduleType,
      );

      final success = await context
          .read<ShiftProvider>()
          .updateAgentSchedule(widget.agent.id, updatedShift);

      if (success && mounted) {
        Navigator.pop(context);
        UIHelpers.showSuccessSnackBar(
          context: context,
          message: 'Shift schedule updated successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showErrorSnackBar(
          context: context,
          message: 'Failed to update shift: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteShift() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shift'),
        content: const Text('Are you sure you want to delete this shift schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final success = await context
          .read<ShiftProvider>()
          .deleteSchedule(widget.shift.id);

      if (success && mounted) {
        Navigator.pop(context);
        UIHelpers.showSuccessSnackBar(
          context: context,
          message: 'Shift schedule deleted successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showErrorSnackBar(
          context: context,
          message: 'Failed to delete shift: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.agent.name}\'s Shift'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _deleteShift,
            tooltip: 'Delete Shift',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Working Days',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    final day = index + 1;
                    return FilterChip(
                      label: Text(UIHelpers.weekdayName(day)),
                      selected: _selectedWeekdays.contains(day),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedWeekdays.add(day);
                          } else {
                            _selectedWeekdays.remove(day);
                          }
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Time',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectTime(true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(10),
                              ),
                              child: Text(_startTime.format(context)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Time',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectTime(false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(10),
                              ),
                              child: Text(_endTime.format(context)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Schedule Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _scheduleType,
                  items: const [
                    DropdownMenuItem(value: 'FIXED', child: Text('Fixed Schedule')),
                    DropdownMenuItem(value: 'FLEXIBLE', child: Text('Flexible Schedule')),
                    DropdownMenuItem(value: 'ROTATING', child: Text('Rotating Schedule')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _scheduleType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  subtitle: Text(_isActive ? 'Schedule is active' : 'Schedule is inactive'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _saveShift,
                    icon: const Icon(Icons.save),
                    label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}