import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/agent.dart';
import '../../providers/agent_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../models/shift_schedule.dart'; 

class CreateAgentScreen extends StatelessWidget {
  const CreateAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Agent')),
      body: const AgentForm(),
    );
  }
}

class AgentForm extends StatefulWidget {
  const AgentForm({super.key});

  @override
  State<AgentForm> createState() => _AgentFormState();
}

class _AgentFormState extends State<AgentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _role = 'SUPPORT';
  bool _isAvailable = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final newAgent = Agent(
        id: '',
        name: _nameController.text,
        email: _emailController.text,
        role: _role,
        isAvailable: _isAvailable,
        isOnline: true,
        currentTickets: [],
        skills: ['Communication', 'Problem Solving', 'Technical Support'], // Default skills
        shiftSchedule: ShiftSchedule(
          id: '1', // Example value
          agentId: '1', // Example value
          weekdays: [1, 2], // Example value (1 for Monday, 2 for Tuesday)
          startTime: DateTime(0, 1, 1, 9, 0), // Example value
          endTime: DateTime(0, 1, 1, 17, 0), // Example value
          isActive: true, // Example value
          scheduleType: 'Regular', // Example value
        ), // Example value
        lastAssignment: DateTime.now(), // Example value
      );

      final success = await context.read<AgentProvider>().createAgent(newAgent);

      if (success && mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error creating agent: ${e.toString()}')),
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
    return LoadingOverlay(
      isLoading: _isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter agent name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.work),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'SUPPORT',
                    child: Text('Support Agent'),
                  ),
                  DropdownMenuItem(
                    value: 'SUPERVISOR',
                    child: Text('Supervisor'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _role = value!);
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Available for Assignment'),
                value: _isAvailable,
                onChanged: (value) {
                  setState(() => _isAvailable = value);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: const Text('Create Agent'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}