import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ticket.dart';
import '../../models/agent.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/agent_provider.dart';
import '../../utils/ui_helpers.dart';

class EditTicketScreen extends StatefulWidget {
  final Ticket ticket;

  const EditTicketScreen({super.key, required this.ticket});

  @override
  State<EditTicketScreen> createState() => _EditTicketScreenState();
}

class _EditTicketScreenState extends State<EditTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _dueDate;
  late double _estimatedHours;
  late String _status;
  late String _priority;
  String? _assignedTo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _title = widget.ticket.title;
    _description = widget.ticket.description;
    _dueDate = widget.ticket.dueDate;
    _estimatedHours = widget.ticket.estimatedHours;
    _status = widget.ticket.status;
    _priority = widget.ticket.priority;
    // Only store the ID string
    _assignedTo = widget.ticket.assignedTo;
    
    // Fetch agents if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AgentProvider>().agents.isEmpty) {
        context.read<AgentProvider>().fetchAgents();
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final updatedTicket = Ticket(
          id: widget.ticket.id,
          title: _title,
          description: _description,
          dueDate: _dueDate,
          estimatedHours: _estimatedHours,
          status: _status,
          priority: _priority,
          assignedTo: _assignedTo,
          createdAt: widget.ticket.createdAt,
          requiredSkills: widget.ticket.requiredSkills,
        );

        await Provider.of<TicketProvider>(context, listen: false)
            .updateTicket(updatedTicket, context);

        if (!mounted) return;
        Navigator.pop(context);
      } catch (error) {
        if (!mounted) return;
        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Failed to update ticket: $error',
          icon: Icons.error_outline,
          backgroundColor: Colors.red,
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildAgentDropdown(List<Agent> agents) {
    // Check if the current _assignedTo value exists in agents list
    final bool hasValidAssignment = _assignedTo == null || 
        agents.any((agent) => agent.id == _assignedTo);
    
    // Reset assignedTo if current value is invalid
    if (!hasValidAssignment) {
      _assignedTo = null;
    }

    return DropdownButtonFormField<String?>(
      value: hasValidAssignment ? _assignedTo : null,
      decoration: const InputDecoration(
        labelText: 'Assign To',
        helperText: 'Select agent to handle this ticket',
        prefixIcon: Icon(Icons.person_add),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Row(
            children: [
              Icon(Icons.person_off_outlined),
              SizedBox(width: 8),
              Text('Unassigned'),
            ],
          ),
        ),
        ...agents.map((agent) => DropdownMenuItem<String?>(
          value: agent.id,
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: agent.isAvailable ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(agent.name),
              if (!agent.isAvailable) ...[
                const SizedBox(width: 4),
                const Icon(Icons.schedule, size: 16, color: Colors.orange),
              ],
            ],
          ),
        )),
      ],
      onChanged: (String? newValue) {
        setState(() {
          _assignedTo = newValue;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Ticket'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      body: Consumer2<TicketProvider, AgentProvider>(
        builder: (context, ticketProvider, agentProvider, child) {
          if (ticketProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: _title,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        helperText: 'At least 3 characters',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        if (value.length < 3) {
                          return 'Title must be at least 3 characters';
                        }
                        return null;
                      },
                      onSaved: (value) => _title = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        helperText: 'At least 10 characters',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                      onSaved: (value) => _description = value!,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Due Date'),
                      subtitle: Text('${_dueDate.toLocal()}'.split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null && picked != _dueDate) {
                          setState(() {
                            _dueDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        helperText: 'Current ticket status',
                        prefixIcon: Icon(Icons.assignment_turned_in),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'OPEN',
                          child: Row(
                            children: [
                              Icon(Icons.fiber_new, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              const Text('Open'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'IN_PROGRESS',
                          child: Row(
                            children: [
                              Icon(Icons.trending_up, color: Colors.orange[700]),
                              const SizedBox(width: 8),
                              const Text('In Progress'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'CLOSED',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              const Text('Closed'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _status = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        helperText: 'Ticket priority level',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'LOW',
                          child: Row(
                            children: [
                              Icon(Icons.arrow_downward, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              const Text('Low'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'MEDIUM',
                          child: Row(
                            children: [
                              Icon(Icons.remove, color: Colors.orange[700]),
                              const SizedBox(width: 8),
                              const Text('Medium'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'HIGH',
                          child: Row(
                            children: [
                              Icon(Icons.arrow_upward, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              const Text('High'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildAgentDropdown(agentProvider.agents),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _submitForm,
                        icon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.update),
                        label: Text(
                          _isLoading ? 'UPDATING...' : 'UPDATE',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}