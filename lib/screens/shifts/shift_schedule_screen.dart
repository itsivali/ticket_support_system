import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../models/agent.dart' hide ShiftSchedule;
import '../../models/shift_schedule.dart';
import '../../providers/agent_provider.dart';
import '../../providers/shift_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/ui_helpers.dart';

class ShiftScheduleScreen extends StatefulWidget {
  final Agent agent;

  const ShiftScheduleScreen({
    super.key,
    required this.agent,
  });

  @override
  State<ShiftScheduleScreen> createState() => _ShiftScheduleScreenState();
}

class _ShiftScheduleScreenState extends State<ShiftScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Set<int> _selectedWeekdays = {};
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  String _scheduleType = 'REGULAR';

  @override
  void initState() {
    super.initState();
    _loadCurrentSchedule();
  }

  void _loadCurrentSchedule() {
    final schedule = widget.agent.shiftSchedule;
    if (schedule != null) {
      setState(() {
        _selectedWeekdays = schedule.weekdays.toSet();
        _startTime = TimeOfDay(
          hour: schedule.startTime.hour,
          minute: schedule.startTime.minute,
        );
        _endTime = TimeOfDay(
          hour: schedule.endTime.hour,
          minute: schedule.endTime.minute,
        );
        _scheduleType = schedule.scheduleType;
      });
    }
  }

  Widget _buildWeekdaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Working Days',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildWeekdayChip('Mon', 1),
            _buildWeekdayChip('Tue', 2),
            _buildWeekdayChip('Wed', 3),
            _buildWeekdayChip('Thu', 4),
            _buildWeekdayChip('Fri', 5),
            _buildWeekdayChip('Sat', 6),
            _buildWeekdayChip('Sun', 7),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdayChip(String label, int day) {
    return FilterChip(
      label: Text(label),
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
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
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
        message: 'Select at least one working day',
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

    final workHours = (endMinutes - startMinutes) / 60;
    if (workHours < 1 || workHours > 24) {
      UIHelpers.showErrorSnackBar(
        context: context,
        message: 'Work hours must be between 1 and 24',
      );
      return false;
    }

    return true;
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate() || !_validateSchedule()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final schedule = ShiftSchedule(
        id: widget.agent.shiftSchedule?.id ?? '',
        agentId: widget.agent.id,
        weekdays: _selectedWeekdays.toList()..sort(),
        startTime: DateTime(
          now.year, now.month, now.day,
          _startTime.hour, _startTime.minute
        ),
        endTime: DateTime(
          now.year, now.month, now.day,
          _endTime.hour, _endTime.minute
        ),
        scheduleType: _scheduleType,
        hoursPerDay: (_endTime.hour * 60 + _endTime.minute - 
                      _startTime.hour * 60 - _startTime.minute) / 60.0,
      );

      final success = await context.read<ShiftProvider>()
          .updateAgentSchedule(widget.agent.id, schedule);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
      } else {
        UIHelpers.showErrorSnackBar(
          context: context,
          message: 'Failed to save schedule'
        );
      }
    } catch (e) {
      if (!mounted) return;
      UIHelpers.showErrorSnackBar(
        context: context,
        message: 'Error: ${e.toString()}'
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSchedule() async {
    final schedule = ShiftSchedule(
      id: '',
      agentId: widget.agent.id,
      weekdays: [1, 2, 3, 4, 5], // Mon-Fri
      startTime: DateTime(2024, 1, 1, 9, 0), // 9 AM
      endTime: DateTime(2024, 1, 1, 17, 0), // 5 PM
      hoursPerDay: 8,
    );

    final success = await context.read<ShiftProvider>().updateAgentSchedule(
      widget.agent.id,
      schedule,
    );

    if (success) {
      UIHelpers.showSuccessSnackBar(
        context: context,
        message: 'Schedule updated successfully',
      );
    } else {
      UIHelpers.showErrorSnackBar(
        context: context,
        message: 'Failed to update schedule',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule: ${widget.agent.name}'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWeekdaySelector(),
              const SizedBox(height: 24),
              _buildTimeSelectors(),
              const SizedBox(height: 24),
              _buildScheduleType(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _saveSchedule,
                  icon: const Icon(Icons.save),
                  label: Text(_isLoading ? 'Saving...' : 'Save Schedule'),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _updateSchedule,
                  icon: const Icon(Icons.update),
                  label: Text(_isLoading ? 'UPDATING...' : 'UPDATE SCHEDULE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleType() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Schedule Type',
        border: OutlineInputBorder(),
      ),
      value: _scheduleType,
      items: const [
        DropdownMenuItem(value: 'REGULAR', child: Text('Regular')),
        DropdownMenuItem(value: 'FLEXIBLE', child: Text('Flexible')),
      ],
      onChanged: (value) => setState(() => _scheduleType = value!),
    );
  }

  Widget _buildTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: const Text('Start Time'),
            subtitle: Text(_startTime.format(context)),
            leading: const Icon(Icons.access_time),
            onTap: () => _selectTime(true),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('End Time'),
            subtitle: Text(_endTime.format(context)),
            leading: const Icon(Icons.access_time),
            onTap: () => _selectTime(false),
          ),
        ),
      ],
    );
  }
}