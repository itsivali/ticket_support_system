import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ticket.dart';
import '../providers/ticket_provider.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  double _estimatedHours = 1.0;
  String _status = 'OPEN';
  String _priority = 'MEDIUM';
  String? _assignedTo;

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final agents = ticketProvider.agents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ticketProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Title
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
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
                        onSaved: (value) => _title = value!.trim(),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
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
                        onSaved: (value) => _description = value!.trim(),
                      ),
                      const SizedBox(height: 16),
                      // Due Date
                      Row(
                        children: [
                          const Text('Due Date: '),
                          Text(
                              '${_dueDate.year}-${_dueDate.month}-${_dueDate.day}'),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _pickDueDate,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Estimated Hours
                      Row(
                        children: [
                          const Text('Estimated Hours: '),
                          Expanded(
                            child: Slider(
                              value: _estimatedHours,
                              min: 0.5,
                              max: 24,
                              divisions: 47,
                              label: _estimatedHours.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _estimatedHours = value;
                                });
                              },
                            ),
                          ),
                          Text(_estimatedHours.toString()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Status
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: ['OPEN', 'IN_PROGRESS', 'CLOSED']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() {
                          _status = value!;
                        }),
                      ),
                      const SizedBox(height: 16),
                      // Priority
                      DropdownButtonFormField<String>(
                        value: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        items: ['LOW', 'MEDIUM', 'HIGH']
                            .map((priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(priority),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() {
                          _priority = value!;
                        }),
                      ),
                      const SizedBox(height: 16),
                      // Assigned To
                      DropdownButtonFormField<String>(
                        value: _assignedTo,
                        decoration: const InputDecoration(
                          labelText: 'Assign To',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Unassigned'),
                          ),
                          ...agents.map((agent) => DropdownMenuItem(
                                value: agent.id,
                                child: Text(agent.name),
                              )),
                        ],
                        onChanged: (value) => setState(() {
                          _assignedTo = value;
                        }),
                      ),
                      const SizedBox(height: 24),
                      // Submit Button
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Create Ticket'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
        final newTicket = Ticket(
          id: '', // ID will be assigned by backend
          title: _title,
          description: _description,
          dueDate: _dueDate,
          estimatedHours: _estimatedHours,
          status: _status,
          priority: _priority,
          assignedTo: _assignedTo,
        );

        await Provider.of<TicketProvider>(context, listen: false)
            .createTicket(newTicket);
            
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket created successfully'))
        );
        Navigator.pop(context);
        
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceAll('Exception:', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}
