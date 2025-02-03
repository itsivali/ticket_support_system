import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shift_schedule.dart';
import '../../models/agent.dart';
import '../../providers/shift_provider.dart';
import '../../providers/agent_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../utils/ui_helpers.dart';

class CreateShiftScreen extends StatefulWidget {
  const CreateShiftScreen({super.key});

  @override
  State<CreateShiftScreen> createState() => _CreateShiftScreenState();
}

class _CreateShiftScreenState extends State<CreateShiftScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedAgentId;
  Set<int> _selectedWeekdays = {};
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  String _scheduleType = 'REGULAR';

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

  Widget _buildAgentSelector() {
    return Consumer<AgentProvider>(
      builder: (context, provider, child) {
        final agents = provider.agents;
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Select Agent',
            border: OutlineInputBorder(),
          ),
          value: _selectedAgentId,
          items: agents.map((agent) {
            return DropdownMenuItem(
              value: agent.id,
              child: Text(agent.name),
            );
          }).toList(),
          validator: (value) => value == null ? 'Please select an agent' : null,
          onChanged: (value) => setState(() => _selectedAgentId = value),
        );
      },
    );
  }

  Widget _buildWeekdaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Working Days', style: TextStyle(fontSize: 16)),
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || !_validateSchedule()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final schedule = ShiftSchedule(
        id: '',
        agentId: _selectedAgentId!,
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
        scheduleType: _scheduleType,
        hoursPerDay: _endTime.hour - _startTime.hour +
            (_endTime.minute - _startTime.minute) / 60.0,
      );

      final success = await context
          .read<ShiftProvider>()
          .updateAgentSchedule(_selectedAgentId!, schedule);

      if (success && mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      UIHelpers.showErrorSnackBar(
        context: context,
        message: 'Failed to create shift: $e',
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
        title: const Text('Create Shift Schedule'),
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
                _buildAgentSelector(),
                const SizedBox(height: 24),
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Schedule Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _scheduleType,
                  items: const [
                    DropdownMenuItem(
                      value: 'REGULAR',
                      child: Text('Regular Schedule'),
                    ),
                    DropdownMenuItem(
                      value: 'FLEXIBLE',
                      child: Text('Flexible Hours'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _scheduleType = value!),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _submitForm,
                    icon: const Icon(Icons.save),
                    label: Text(_isLoading ? 'Creating...' : 'Create Schedule'),
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