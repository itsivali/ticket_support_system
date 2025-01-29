import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ticket.dart';
import '../providers/ticket_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _title = widget.ticket.title;
    _description = widget.ticket.description;
    _dueDate = widget.ticket.dueDate;
    _estimatedHours = widget.ticket.estimatedHours;
    _status = widget.ticket.status;
    _priority = widget.ticket.priority;
    _assignedTo = widget.ticket.assignedTo;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedTicket = Ticket(
        id: widget.ticket.id,
        title: _title,
        description: _description,
        dueDate: _dueDate,
        estimatedHours: _estimatedHours,
        status: _status,
        priority: _priority,
        assignedTo: _assignedTo,
      );

      Provider.of<TicketProvider>(context, listen: false)
          .updateTicket(updatedTicket)
          .then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        // Handle error accordingly
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context);
    final agents = ticketProvider.agents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Ticket'),
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
                        initialValue: _title,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _title = value!;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description
                      TextFormField(
                        initialValue: _description,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _description = value!;
                        },
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
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: ['OPEN', 'IN_PROGRESS', 'CLOSED']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Priority
                      DropdownButtonFormField<String>(
                        value: _priority,
                        decoration:
                            const InputDecoration(labelText: 'Priority'),
                        items: ['LOW', 'MEDIUM', 'HIGH']
                            .map((priority) => DropdownMenuItem(
                                  value: priority,
                                  child: Text(priority),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _priority = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Assigned To
                      DropdownButtonFormField<String>(
                        value: _assignedTo,
                        decoration:
                            const InputDecoration(labelText: 'Assign To'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Unassigned'),
                          ),
                          ...agents.map((agent) => DropdownMenuItem(
                                value: agent.id,
                                child: Text(agent.name),
                              ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            _assignedTo = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // Submit Button
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Update Ticket'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
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
  }
}