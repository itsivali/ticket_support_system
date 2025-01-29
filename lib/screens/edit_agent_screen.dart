import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/agent.dart';
import '../providers/agent_provider.dart';
import '../utils/ui_helpers.dart';

class EditAgentScreen extends StatefulWidget {
  final Agent agent;

  const EditAgentScreen({super.key, required this.agent});

  @override
  State<EditAgentScreen> createState() => _EditAgentScreenState();
}

class _EditAgentScreenState extends State<EditAgentScreen> {
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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final updatedAgent = Agent(
          id: widget.agent.id,
          name: _name,
          email: _email,
          role: _role,
          isAvailable: _isAvailable,
        );

        await Provider.of<AgentProvider>(context, listen: false)
            .updateAgent(updatedAgent, context);

        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 10),
                const Text('Success'),
              ],
            ),
            content: const Text('Agent updated successfully'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        if (!mounted) return;
        Navigator.pop(context);
      } catch (error) {
        if (!mounted) return;

        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Failed to update agent: $error',
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
        title: const Text('Edit Agent'),
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
                  initialValue: _name,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    helperText: 'Full name of the agent',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter agent name' : null,
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
                  title: const Text('Available'),
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
      ),
    );
  }
}
