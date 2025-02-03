import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agent.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCurrentSchedule();
  }

  void _loadCurrentSchedule() {
    if (widget.agent.shiftSchedule != null) {
      setState(() {
        _selectedWeekdays = widget.agent.shiftSchedule!.weekdays.toSet();
        _startTime = TimeOfDay(
          hour: widget.agent.shiftSchedule!.startTime.hour,
          minute: widget.agent.shiftSchedule!.startTime.minute,
        );
        _endTime = TimeOfDay(
          hour: widget.agent.shiftSchedule!.endTime.hour,
          minute: widget.agent.shiftSchedule!.endTime.minute,
        );
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

  Future<void> _saveSchedule() async {
    if (!_validateSchedule()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        _startTime.hour,
        _startTime.minute,
      );
      final endTime = DateTime(
        now.year,
        now.month,
        now.day,
        _endTime.hour,
        _endTime.minute,
      );

      final schedule = ShiftSchedule(
        id: widget.agent.shiftSchedule?.id ?? '',
        agentId: widget.agent.id,
        weekdays: _selectedWeekdays.toList()..sort(),
        startTime: startTime,
        endTime: endTime,
        hoursPerDay: endTime.difference(startTime).inHours.toDouble(),
      );

      await context.read<ShiftProvider>().updateAgentSchedule(
        widget.agent.id,
        schedule,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      UIHelpers.showErrorSnackBar(
        context: context,
        message: 'Failed to save schedule: $e',
      );
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
              Row(
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
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _saveSchedule,
                  icon: const Icon(Icons.save),
                  label: Text(_isLoading ? 'SAVING...' : 'SAVE SCHEDULE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}