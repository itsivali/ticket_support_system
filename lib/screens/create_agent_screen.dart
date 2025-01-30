import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticket_support_system/providers/agent_provider.dart';
import '../models/agent.dart';
import '../utils/ui_helpers.dart';

class CreateAgentScreen extends StatefulWidget {
  const CreateAgentScreen({super.key});

  @override
  State<CreateAgentScreen> createState() => _CreateAgentScreenState();
}

class _CreateAgentScreenState extends State<CreateAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _role = 'SUPPORT';  // Default role
  bool _isAvailable = true;
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final newAgent = Agent(
          id: '',
          name: _name,
          email: _email,
          role: _role,
          isAvailable: _isAvailable,
        );

        await Provider.of<AgentProvider>(context, listen: false)
            .createAgent(newAgent, context);

        if (!mounted) return;
        Navigator.pop(context);
      } catch (error) {
        if (!mounted) return;
        
        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Failed to create agent: $error',
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
        title: const Text('Create New Agent'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value?.isEmpty ?? true 
                  ? 'Please enter name' 
                  : null,
                onSaved: (value) => _name = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) => !value!.contains('@') 
                  ? 'Invalid email' 
                  : null,
                onSaved: (value) => _email = value ?? '',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: DropdownButtonFormField<String>(
                  value: _role,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.work),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'SUPPORT',
                      child: Row(
                        children: [
                          Icon(Icons.support_agent, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          const Text('Support'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'SUPERVISOR',
                      child: Row(
                        children: [
                          Icon(Icons.supervisor_account, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          const Text('Supervisor'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'ADMIN',
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          const Text('Admin'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _role = newValue ?? 'SUPPORT';
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.event_available,
                      color: _isAvailable ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text('Available'),
                  ],
                ),
                subtitle: const Text('Agent can be assigned to tickets'),
                value: _isAvailable,
                onChanged: (value) => setState(() => _isAvailable = value),
              ),
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
                    : const Icon(Icons.person_add),
                  label: Text(
                    _isLoading ? 'CREATING...' : 'CREATE AGENT',
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
  }
}