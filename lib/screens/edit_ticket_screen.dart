import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ticket.dart';
import '../providers/ticket_provider.dart';
import '../utils/ui_helpers.dart';

class EditTicketScreen extends StatefulWidget {
  final Ticket ticket;

  const EditTicketScreen({Key? key, required this.ticket}) : super(key: key);

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
    _assignedTo = widget.ticket.assignedTo;
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
        );

        await Provider.of<TicketProvider>(context, listen: false)
            .updateTicket(updatedTicket, context);

        if (!mounted) return;
        
        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Ticket updated successfully!',
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
        );

        Navigator.pop(context);
      } catch (error) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                      Row(
                        children: [
                          const Text('Due Date: '),
                          TextButton(
                            onPressed: () async {
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
                            child: Text(
                              '${_dueDate.year}-${_dueDate.month}-${_dueDate.day}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Estimated Hours:'),
                      Slider(
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
                      const SizedBox(height: 16),
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
                      DropdownButtonFormField<String>(
                        value: _priority,
                        decoration: const InputDecoration(labelText: 'Priority'),
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submitForm,
                          icon: const Icon(Icons.save),
                          label: const Text('Update Ticket'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
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