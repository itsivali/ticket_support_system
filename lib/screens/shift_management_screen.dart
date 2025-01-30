import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agent_provider.dart';
import '../models/agent.dart';
import '../widgets/app_drawer.dart';

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  final List<int> _selectedWeekdays = [];
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  Agent? _selectedAgent;

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AgentProvider>().fetchAgents(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<AgentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Agent>(
                  value: _selectedAgent,
                  decoration: const InputDecoration(
                    labelText: 'Select Agent',
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: provider.agents.map((agent) {
                    return DropdownMenuItem(
                      value: agent,
                      child: Text(agent.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedAgent = value),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Working Days',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Mon'),
                      selected: _selectedWeekdays.contains(1),
                      onSelected: (selected) => setState(() {
                        selected 
                          ? _selectedWeekdays.add(1)
                          : _selectedWeekdays.remove(1);
                      }),
                    ),
                    FilterChip(
                      label: const Text('Tue'),
                      selected: _selectedWeekdays.contains(2),
                      onSelected: (selected) => setState(() {
                        selected 
                          ? _selectedWeekdays.add(2)
                          : _selectedWeekdays.remove(2);
                      }),
                    ),
                  FilterChip(
                    label: const Text('Wed'),
                    selected: _selectedWeekdays.contains(3),
                    onSelected: (selected) => setState(() {
                      selected 
                        ? _selectedWeekdays.add(3)
                        : _selectedWeekdays.remove(3);
                    }),
                  ),
                  FilterChip(
                    label: const Text('Thu'),
                    selected: _selectedWeekdays.contains(4),
                    onSelected: (selected) => setState(() {
                      selected 
                        ? _selectedWeekdays.add(4)
                        : _selectedWeekdays.remove(4);
                    }),
                  ),
                  FilterChip(
                    label: const Text('Fri'),
                    selected: _selectedWeekdays.contains(5),
                    onSelected: (selected) => setState(() {
                      selected 
                        ? _selectedWeekdays.add(5)
                        : _selectedWeekdays.remove(5);
                    }),
                  ),
                  FilterChip(
                    label: const Text('Sat'),
                    selected: _selectedWeekdays.contains(6),
                    onSelected: (selected) => setState(() {
                      selected 
                        ? _selectedWeekdays.add(6)
                        : _selectedWeekdays.remove(6);
                    }),
                  ),
                  FilterChip(
                    label: const Text('Sun'),
                    selected: _selectedWeekdays.contains(7),
                    onSelected: (selected) => setState(() {
                      selected 
                        ? _selectedWeekdays.add(7)
                        : _selectedWeekdays.remove(7);
                    }),
                  ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Start Time'),
                        subtitle: Text(_startTime.format(context)),
                        leading: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                          );
                          if (time != null) {
                            setState(() => _startTime = time);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('End Time'),
                        subtitle: Text(_endTime.format(context)),
                        leading: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                          );
                          if (time != null) {
                            setState(() => _endTime = time);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _selectedAgent == null ? null : () {
                      // Save shift schedule
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('SAVE SCHEDULE'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}