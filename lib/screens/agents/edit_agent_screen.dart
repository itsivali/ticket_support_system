import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agent_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_overlay.dart';

class EditAgentScreen extends StatefulWidget {
  final String agentId;

  const EditAgentScreen({
    super.key,
    required this.agentId,
  });

  @override
  State<EditAgentScreen> createState() => _EditAgentScreenState();
}

class _EditAgentScreenState extends State<EditAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _role = 'SUPPORT';
  bool _isAvailable = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAgentData();
  }

  Future<void> _loadAgentData() async {
    final agent = context.read<AgentProvider>().getAgentById(widget.agentId);
    if (agent != null) {
      setState(() {
        _name = agent.name;
        _email = agent.email;
        _role = agent.role;
        _isAvailable = agent.isAvailable;
      });
    }
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
          .updateAgent(widget.agentId, updates);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Agent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _submitForm,
          ),
        ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}