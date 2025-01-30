import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/agent.dart';
import '../services/agent_service.dart';
import '../utils/console_logger.dart';
import '../utils/ui_helpers.dart';

class AgentProvider with ChangeNotifier {
  final AgentService _agentService = AgentService();

  List<Agent> _agents = [];
  bool _isLoading = false;
  String? _error;

  List<Agent> get agents => _agents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAgents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _agents = await _agentService.getAgents();
    } catch (e) {
      ConsoleLogger.error('Error fetching agents', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAgent(Agent agent, BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate agent fields
      if (agent.name.length < 2) {
        throw Exception('Name must be at least 2 characters');
      }
      if (agent.email.isEmpty || !agent.email.contains('@')) {
        throw Exception('Please enter a valid email address');
      }

      final newAgent = await _agentService.createAgent(agent);
      _agents.add(newAgent);

      if (context.mounted) {
        // Show success dialog
        if (!context.mounted) return;
        
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
            content: const Text('Agent has been successfully created.'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        if (context.mounted) {
          UIHelpers.showCustomSnackBar(
            context: context,
            message: 'Agent created successfully!',
            icon: Icons.person_add,
            backgroundColor: Colors.green,
          );
        }
      }
    } catch (e) {
      ConsoleLogger.error('Error creating agent', e);
      _error = e.toString();
      if (context.mounted) {
        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Failed to create agent: ${e.toString()}',
          icon: Icons.error_outline,
          backgroundColor: Colors.red,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAgent(Agent agent, BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedAgent = await _agentService.updateAgent(agent);
      final index = _agents.indexWhere((a) => a.id == updatedAgent.id);
      if (index != -1) {
        _agents[index] = updatedAgent;
      }

      if (!context.mounted) return;

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
          content: const Text('Agent has been successfully updated.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!context.mounted) return;

      UIHelpers.showCustomSnackBar(
        context: context,
        message: 'Agent updated successfully',
        icon: Icons.check_circle,
        backgroundColor: Colors.blue,
      );
    } catch (e) {
      ConsoleLogger.error('Error updating agent', e);
      _error = e.toString();
      if (context.mounted) {
        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Failed to update agent: ${e.toString()}',
          icon: Icons.error_outline,
          backgroundColor: Colors.red,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAgent(String agentId, BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _agentService.deleteAgent(agentId);
      _agents.removeWhere((agent) => agent.id == agentId);

      if (context.mounted) {
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
            content: const Text('Agent has been successfully deleted.'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Agent deleted successfully',
          icon: Icons.delete_forever,
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      ConsoleLogger.error('Error deleting agent', e);
      _error = e.toString();
      if (context.mounted) {
        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Failed to delete agent: ${e.toString()}',
          icon: Icons.error_outline,
          backgroundColor: Colors.red,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class CreateAgentScreen extends StatefulWidget {
  const CreateAgentScreen({super.key});

  @override
  State<CreateAgentScreen> createState() => _CreateAgentScreenState();
}

class _CreateAgentScreenState extends State<CreateAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _role = '';
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
        title: const Text('Create Agent'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Your form fields here
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  icon: Icon(Icons.person),
                ),
                validator: (value) => (value?.length ?? 0) < 2 ? 'Name must be at least 2 characters' : null,
                onSaved: (value) => _name = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  icon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => !value!.contains('@') ? 'Enter a valid email' : null,
                onSaved: (value) => _email = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  icon: Icon(Icons.work),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Role is required' : null,
                onSaved: (value) => _role = value ?? '',
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Available'),
                value: _isAvailable,
                onChanged: (bool value) => setState(() => _isAvailable = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(_isLoading ? 'Creating...' : 'Create Agent'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}