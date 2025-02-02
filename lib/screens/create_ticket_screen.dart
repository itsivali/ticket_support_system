import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ticket.dart';
import '../providers/ticket_provider.dart';
import '../providers/agent_provider.dart';
import '../utils/validators.dart';
import '../widgets/loading_overlay.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  double _estimatedHours = 1.0;
  String _priority = 'MEDIUM';
  String? _assignedTo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAgents() async {
    final agentProvider = context.read<AgentProvider>();
    if (agentProvider.agents.isEmpty) {
      await agentProvider.fetchAgents();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newTicket = Ticket(
        id: '',
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        estimatedHours: _estimatedHours,
        status: 'OPEN',
        priority: _priority,
        assignedTo: _assignedTo,
        createdAt: DateTime.now().toIso8601String(),
      );

      await context.read<TicketProvider>().createTicket(newTicket, context);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating ticket: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ticket'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
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
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) => Validators.required(value, 'Title'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) => Validators.required(value, 'Description'),
                ),
                const SizedBox(height: 16),
                _buildPrioritySelector(),
                const SizedBox(height: 16),
                _buildAgentDropdown(),
                const SizedBox(height: 16),
                _buildDueDatePicker(),
                const SizedBox(height: 16),
                _buildHoursEstimation(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: const Text('Create Ticket'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return DropdownButtonFormField<String>(
      value: _priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        prefixIcon: Icon(Icons.flag),
      ),
      items: const [
        DropdownMenuItem(value: 'HIGH', child: Text('High')),
        DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
        DropdownMenuItem(value: 'LOW', child: Text('Low')),
      ],
      onChanged: (value) => setState(() => _priority = value!),
    );
  }

  Widget _buildAgentDropdown() {
    return Consumer<AgentProvider>(
      builder: (context, provider, child) {
        final agents = provider.getAvailableAgents();
        return DropdownButtonFormField<String?>(
          value: _assignedTo,
          decoration: const InputDecoration(
            labelText: 'Assign To',
            prefixIcon: Icon(Icons.person),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Unassigned'),
            ),
            ...agents.map((agent) => DropdownMenuItem<String?>(
              value: agent.id,
              child: Text(agent.name),
            )),
          ],
          onChanged: (value) => setState(() => _assignedTo = value),
        );
      },
    );
  }

  Widget _buildDueDatePicker() {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: const Text('Due Date'),
      subtitle: Text(_dueDate.toString().split(' ')[0]),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() => _dueDate = picked);
        }
      },
    );
  }

  Widget _buildHoursEstimation() {
    return Row(
      children: [
        const Icon(Icons.timer),
        const SizedBox(width: 16),
        Expanded(
          child: Slider(
            value: _estimatedHours,
            min: 0.5,
            max: 8.0,
            divisions: 15,
            label: '$_estimatedHours hours',
            onChanged: (value) => setState(() => _estimatedHours = value),
          ),
        ),
        Text('${_estimatedHours.toStringAsFixed(1)}h'),
      ],
    );
  }
}