import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agent_provider.dart';
import '../../providers/shift_provider.dart';
import '../../models/shift_schedule.dart';
import '../../models/agent.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/ui_helpers.dart';

class ShiftManagementScreen extends StatelessWidget {
  const ShiftManagementScreen({super.key});

  String _formatWeekdays(List<int> weekdays) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays.map((day) => days[day - 1]).join(', ');
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ShiftProvider>().fetchCurrentShifts();
              context.read<AgentProvider>().fetchAgents();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer2<ShiftProvider, AgentProvider>(
        builder: (context, shiftProvider, agentProvider, _) {
          if (shiftProvider.isLoading || agentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final shifts = shiftProvider.currentShifts;
          final agents = agentProvider.agents;

          if (agents.isEmpty) {
            return const Center(
              child: Text('No agents available'),
            );
          }

          return ListView.builder(
            itemCount: agents.length,
            itemBuilder: (context, index) {
              final agent = agents[index];
              final shift = shifts.firstWhere(
                (s) => s.agentId == agent.id,
                orElse: () => ShiftSchedule(
                  id: '',
                  agentId: agent.id,
                  weekdays: [],
                  startTime: DateTime.now(),
                  endTime: DateTime.now().add(const Duration(hours: 8)),
                  isActive: false,
                  scheduleType: 'FIXED',
                ),
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: shift.isActive ? Colors.green : Colors.grey,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    agent.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    shift.id.isEmpty
                        ? 'No shift assigned'
                        : 'Schedule: ${shift.scheduleType}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (shift.weekdays.isNotEmpty) ...[
                            Text('Working Days: ${_formatWeekdays(shift.weekdays)}'),
                            const SizedBox(height: 8),
                          ],
                          Text('Hours: ${_formatTime(shift.startTime)} - ${_formatTime(shift.endTime)}'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Schedule'),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/edit-shift',
                                    arguments: {
                                      'agent': agent,
                                      'shift': shift,
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-shift'),
        icon: const Icon(Icons.add),
        label: const Text('New Schedule'),
      ),
    );
  }
}