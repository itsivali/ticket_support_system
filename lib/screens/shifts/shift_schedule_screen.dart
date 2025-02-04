import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agent.dart';
import '../../models/shift_schedule.dart';
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
  String _scheduleType = 'FIXED';

  @override
  void initState() {
    super.initState();
    _selectedWeekdays = widget.agent.shiftSchedule.weekdays.toSet();
    _startTime = TimeOfDay.fromDateTime(widget.agent.shiftSchedule.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.agent.shiftSchedule.endTime);
    _scheduleType = widget.agent.shiftSchedule.scheduleType;
  }

  Future<void> _saveShiftSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newShiftSchedule = ShiftSchedule(
      id: widget.agent.shiftSchedule.id,
      agentId: widget.agent.id,
      weekdays: _selectedWeekdays.toList(),
      startTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        _startTime.hour,
        _startTime.minute,
      ),
      endTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        _endTime.hour,
        _endTime.minute,
      ),
      isActive: true,
      scheduleType: _scheduleType,
    );

    try {
      await Provider.of<ShiftProvider>(context, listen: false)
          .updateShiftSchedule(widget.agent.id, newShiftSchedule);
      if (!mounted) return;
      UIHelpers.showCustomSnackBar(
        context: context,
        message: 'Shift schedule updated successfully',
        icon: Icons.check_circle,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      if (!mounted) return;
      UIHelpers.showCustomSnackBar(
        context: context,
        message: 'Failed to update shift schedule: $e',
        icon: Icons.error,
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shift Schedule for ${widget.agent.name}'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Weekdays',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Wrap(
                      spacing: 8.0,
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
                    const SizedBox(height: 16),
                    Text(
                      'Select Start Time',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (time != null) {
                          setState(() => _startTime = time);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                        child: Text(_startTime.format(context)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select End Time',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );
                        if (time != null) {
                          setState(() => _endTime = time);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                        child: Text(_endTime.format(context)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Schedule Type',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    DropdownButtonFormField<String>(
                      value: _scheduleType,
                      items: ['FIXED', 'FLEXIBLE', 'ROTATING']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _scheduleType = value!);
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveShiftSchedule,
                      child: const Text('Save Shift Schedule'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}