import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticket_support_system/providers/agent_provider.dart';
import '../models/agent.dart';
import '../utils/ui_helpers.dart';
import '../utils/console_logger.dart';  // Add this import

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

  @override
  void initState() {
    super.initState();
    ConsoleLogger.info(
      'CreateAgentScreen initialized', 
      'Ready to create new agent'
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      ConsoleLogger.info(
        'Creating new agent',
        'Name: $_name\nEmail: $_email\nRole: $_role\nAvailable: $_isAvailable'
      );

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
        
        ConsoleLogger.info(
          'Agent created successfully',
          'Returning to agent list screen'
        );
        
        Navigator.pop(context);
      } catch (error) {
        ConsoleLogger.error(
          'Failed to create agent',
          error,
        );
        
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
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    helperText: 'Enter agent\'s full name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter agent name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    helperText: 'Enter work email address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    helperText: 'Select agent role',
                    prefixIcon: Icon(Icons.admin_panel_settings),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'SUPPORT',
                      child: Row(
                        children: [
                          Icon(Icons.headset_mic, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          const Text('Support Agent'),
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
                          Icon(Icons.security, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          const Text('Administrator'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _role = value!),
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
      ),
    );
  }
}