import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ticket.dart';
import '../models/agent.dart';
import '../providers/ticket_provider.dart';
import '../providers/agent_provider.dart';
import '../utils/ui_helpers.dart';


class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  final DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  final double _estimatedHours = 1.0;
  final String _status = 'OPEN';
  String _priority = 'MEDIUM';
  String? _assignedTo;
  bool _isLoading = false;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AgentProvider>().agents.isEmpty) {
        context.read<AgentProvider>().fetchAgents();
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _title = _titleController.text;
      _description = _descriptionController.text;
      setState(() => _isLoading = true);

      try {
        final newTicket = Ticket(
          id: '', 
          title: _title,
          description: _description,
          dueDate: _dueDate,
          estimatedHours: _estimatedHours,
          status: _status,
          priority: _priority,
          assignedTo: _assignedTo,
          createdAt: DateTime.now(), 
        );

        await Provider.of<TicketProvider>(context, listen: false)
            .createTicket(newTicket, context);

        if (!mounted) return;

        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Ticket created successfully!',
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
        );

        Navigator.pop(context);
      } catch (error) {
        if (!mounted) return;
        
        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Failed to create ticket: ${error.toString()}',
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
    return DropdownButtonFormField<String?>(
      value: _assignedTo,
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

  Widget _buildPrioritySelector() {
    return DropdownButtonFormField<String>(
      value: _priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        helperText: 'Select ticket priority',
        prefixIcon: Icon(Icons.priority_high),
      ),
      items: const [
        DropdownMenuItem(
          value: 'LOW',
          child: Text('Low'),
        ),
        DropdownMenuItem(
          value: 'MEDIUM',
          child: Text('Medium'),
        ),
        DropdownMenuItem(
          value: 'HIGH',
          child: Text('High'),
        ),
      ],
      onChanged: (String? newValue) {
        setState(() {
          _priority = newValue!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ticket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  helperText: 'Enter ticket title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  helperText: 'Enter ticket description',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Consumer<AgentProvider>(
                builder: (context, provider, child) {
                  return _buildAgentDropdown(provider.agents);
                },
              ),
              const SizedBox(height: 16),
              _buildPrioritySelector(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}