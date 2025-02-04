import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agent_provider.dart';
import '../../providers/shift_provider.dart';
import '../../models/shift_schedule.dart';
import '../../models/agent.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/ui_helpers.dart';

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  bool _isLoading = false;
  String? _filterValue = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        context.read<ShiftProvider>().fetchCurrentShifts(),
        context.read<AgentProvider>().fetchAgents(),
      ]);
    } catch (e) {
      if (mounted) {
        UIHelpers.showErrorSnackBar(
          context: context,
          message: 'Failed to load shifts: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatWeekdays(List<int> weekdays) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays.map((day) => days[day - 1]).join(', ');
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }

  List<Agent> _filterAgents(List<Agent> agents, List<ShiftSchedule> shifts) {
    switch (_filterValue) {
      case 'active':
        return agents.where((agent) => 
          shifts.any((shift) => 
            shift.agentId == agent.id && shift.isActive
          )
        ).toList();
      case 'inactive':
        return agents.where((agent) => 
          shifts.any((shift) => 
            shift.agentId == agent.id && !shift.isActive
          )
        ).toList();
      case 'unassigned':
        return agents.where((agent) => 
          !shifts.any((shift) => shift.agentId == agent.id)
        ).toList();
      default:
        return agents;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Management'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filterValue = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Shifts'),
              ),
              const PopupMenuItem(
                value: 'active',
                child: Text('Active Shifts'),
              ),
              const PopupMenuItem(
                value: 'inactive',
                child: Text('Inactive Shifts'),
              ),
              const PopupMenuItem(
                value: 'unassigned',
                child: Text('Unassigned Agents'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Shifts',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Consumer2<ShiftProvider, AgentProvider>(
              builder: (context, shiftProvider, agentProvider, _) {
                final shifts = shiftProvider.currentShifts;
                final agents = _filterAgents(agentProvider.agents, shifts);

                if (agents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No agents found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: agents.length,
                  padding: const EdgeInsets.all(8),
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
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: shift.isActive 
                              ? Colors.green 
                              : Colors.grey,
                          child: const Icon(
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
                              : '${shift.scheduleType} Schedule',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/edit-shift',
                            arguments: {
                              'agent': agent,
                              'shift': shift,
                            },
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (shift.weekdays.isNotEmpty) ...[
                                  _InfoRow(
                                    icon: Icons.calendar_today,
                                    label: 'Working Days',
                                    value: _formatWeekdays(shift.weekdays),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                _InfoRow(
                                  icon: Icons.access_time,
                                  label: 'Working Hours',
                                  value: '${_formatTime(shift.startTime)} - '
                                        '${_formatTime(shift.endTime)}',
                                ),
                                const SizedBox(height: 8),
                                _InfoRow(
                                  icon: Icons.work,
                                  label: 'Status',
                                  value: shift.isActive ? 'Active' : 'Inactive',
                                  valueColor: shift.isActive 
                                      ? Colors.green 
                                      : Colors.grey,
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}