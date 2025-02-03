import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ticket.dart';
import '../../models/agent.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/agent_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/ui_helpers.dart';

class TicketDetailsScreen extends StatefulWidget {
  final Ticket ticket;

  const TicketDetailsScreen({super.key, required this.ticket});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  late Ticket _ticket;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
  }

  Widget _buildStatusChip() {
    Color color;
    IconData icon;
    
    switch (_ticket.status) {
      case 'OPEN':
        color = Colors.blue;
        icon = Icons.fiber_new;
        break;
      case 'IN_PROGRESS':
        color = Colors.orange;
        icon = Icons.trending_up;
        break;
      case 'CLOSED':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(_ticket.status),
      backgroundColor: color.withAlpha(25),
      side: BorderSide(color: color),
    );
  }

  Widget _buildPriorityChip() {
    Color color;
    IconData icon;
    
    switch (_ticket.priority) {
      case 'HIGH':
        color = Colors.red;
        icon = Icons.arrow_upward;
        break;
      case 'MEDIUM':
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case 'LOW':
        color = Colors.green;
        icon = Icons.arrow_downward;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(_ticket.priority),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  Widget _buildAssignmentSection() {
    return Consumer<AgentProvider>(
      builder: (context, agentProvider, child) {
        final assignedAgent = agentProvider.agents
            .firstWhere((a) => a.id == _ticket.assignedTo,
                orElse: () => Agent(
                  id: '', 
                  name: 'Unassigned',
                  email: '',
                  role: 'SUPPORT',
                ));

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assignment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: assignedAgent.isAvailable ? Colors.green : Colors.grey,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(assignedAgent.name),
                  subtitle: Text(assignedAgent.email),
                  trailing: _ticket.assignedTo != null
                      ? TextButton.icon(
                          icon: const Icon(Icons.person_remove),
                          label: const Text('Unassign'),
                          onPressed: () => _unassignTicket(),
                        )
                      : TextButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: const Text('Assign'),
                          onPressed: () => _showAssignDialog(context),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _unassignTicket() async {
    setState(() => _isLoading = true);

    try {
      final updatedTicket = Ticket(
        id: _ticket.id,
        title: _ticket.title,
        description: _ticket.description,
        dueDate: _ticket.dueDate,
        estimatedHours: _ticket.estimatedHours,
        status: 'OPEN',
        priority: _ticket.priority,
        assignedTo: null,
        createdAt: _ticket.createdAt,
        requiredSkills: _ticket.requiredSkills,
      );

      await context.read<TicketProvider>().updateTicket(updatedTicket, context);
      setState(() => _ticket = updatedTicket);
    } catch (e) {
      UIHelpers.showCustomSnackBar(
        context: context,
        message: 'Failed to unassign ticket: $e',
        icon: Icons.error_outline,
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAssignDialog(BuildContext context) async {
    final agents = context.read<AgentProvider>().agents
        .where((a) => a.isAvailable && a.currentTickets.length < 3)
        .toList();

    if (agents.isEmpty) {
      UIHelpers.showCustomSnackBar(
        context: context,
        message: 'No available agents found',
        icon: Icons.warning_amber_rounded,
        backgroundColor: Colors.orange,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Ticket'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: agents.length,
            itemBuilder: (context, index) {
              final agent = agents[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(agent.name),
                subtitle: Text('Current tickets: ${agent.currentTickets.length}'),
                onTap: () => _assignTicket(agent.id),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _assignTicket(String agentId) async {
    Navigator.pop(context); // Close dialog
    setState(() => _isLoading = true);

    try {
      final updatedTicket = Ticket(
        id: _ticket.id,
        title: _ticket.title,
        description: _ticket.description,
        dueDate: _ticket.dueDate,
        estimatedHours: _ticket.estimatedHours,
        status: 'IN_PROGRESS',
        priority: _ticket.priority,
        assignedTo: agentId,
        createdAt: _ticket.createdAt,
        requiredSkills: _ticket.requiredSkills,
      );

      await context.read<TicketProvider>().updateTicket(updatedTicket, context);
      setState(() => _ticket = updatedTicket);
    } catch (e) {
      UIHelpers.showCustomSnackBar(
        context: context,
        message: 'Failed to assign ticket: $e',
        icon: Icons.error_outline,
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
        title: Text('Ticket #${_ticket.id}'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context,
              '/edit-ticket',
              arguments: _ticket,
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ticket.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatusChip(),
                        const SizedBox(width: 8),
                        _buildPriorityChip(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_ticket.description),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildAssignmentSection(),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Due Date'),
                      subtitle: Text(
                        _ticket.dueDate.toString().split(' ')[0],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.timer),
                      title: const Text('Estimated Hours'),
                      subtitle: Text('${_ticket.estimatedHours} hours'),
                    ),
                    if (_ticket.requiredSkills.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.psychology),
                        title: const Text('Required Skills'),
                        subtitle: Wrap(
                          spacing: 8,
                          children: _ticket.requiredSkills
                              .map((skill) => Chip(label: Text(skill)))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}