import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agent_provider.dart';
import '../../providers/shift_provider.dart';
import '../../models/shift_schedule.dart';
import '../../models/agent.dart';
import '../../widgets/app_drawer.dart';


class ShiftManagementScreen extends StatelessWidget {
  const ShiftManagementScreen({super.key});

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
                  endTime: DateTime.now(),
                  isActive: false,
                  scheduleType: 'NONE',
                ),
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(agent.name),
                  subtitle: Text(
                    shift.id.isEmpty
                        ? 'No shift assigned'
                        : 'Working days: ${_formatWeekdays(shift.weekdays)}\n'
                          '${_formatTime(shift.startTime)} - ${_formatTime(shift.endTime)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editShift(context, agent, shift),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-shift'),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatWeekdays(List<int> weekdays) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays.map((day) => days[day - 1]).join(', ');
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }

  void _editShift(BuildContext context, Agent agent, ShiftSchedule shift) {
    Navigator.pushNamed(
      context,
      '/edit-shift',
      arguments: {'agent': agent, 'shift': shift},
    );
  }
}