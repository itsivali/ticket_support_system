import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agent_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_overlay.dart';
import '../../models/agent.dart';

class EditAgentScreen extends StatelessWidget {
  final Agent agent;
  
  const EditAgentScreen({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Agent')),
      body: AgentForm(agent: agent),
    );
  }
}

class AgentForm extends StatefulWidget {
  final Agent agent;

  const AgentForm({super.key, required this.agent});

  @override
  State<AgentForm> createState() => _AgentFormState();
}

class _AgentFormState extends State<AgentForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _role;
  late bool _isAvailable;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.agent.name;
    _email = widget.agent.email;
    _role = widget.agent.role;
    _isAvailable = widget.agent.isAvailable;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final updates = {
        'name': _name,
        'email': _email,
        'role': _role,
        'isAvailable': _isAvailable,
      };

      final success = await context
          .read<AgentProvider>()
          .updateAgent(widget.agent.id, updates);

      if (success && mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating agent: ${e.toString()}')),
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
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  helperText: 'Full name of the agent',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => Validators.required(value, 'Name'),
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  helperText: 'Work email address',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: Validators.email,
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  helperText: "Agent's role in the system",
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
                onChanged: (value) => setState(() => _role = value!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Available for Assignment'),
                subtitle: Text(_isAvailable ? 'Active' : 'Inactive'),
                value: _isAvailable,
                onChanged: (value) => setState(() => _isAvailable = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}