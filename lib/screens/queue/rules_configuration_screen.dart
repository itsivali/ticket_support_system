import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/queue_manager.dart' as model;
import '../../providers/queue_provider.dart';
import '../../widgets/loading_overlay.dart';

class RulesConfigurationScreen extends StatefulWidget {
  const RulesConfigurationScreen({super.key});

  @override
  State<RulesConfigurationScreen> createState() => _RulesConfigurationScreenState();
}

class _RulesConfigurationScreenState extends State<RulesConfigurationScreen> {
  bool _isLoading = false;

  Future<void> _showAddRuleDialog(BuildContext context) async {
    String name = '';
    String description = '';
    String priority = 'MEDIUM';
    String condition = 'AVAILABILITY';
    double weight = 1.0;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Assignment Rule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Rule Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['LOW', 'MEDIUM', 'HIGH'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) priority = value;
                },
              ),
              DropdownButtonFormField<String>(
                value: condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: [
                  'AVAILABILITY',
                  'SHIFT_HOURS',
                  'WORKLOAD',
                  'DUE_TIME',
                  'ONLINE_STATUS',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) condition = value;
                },
              ),
              const SizedBox(height: 16),
              Text('Rule Weight: ${weight.toStringAsFixed(1)}'),
              Slider(
                value: weight,
                min: 0.1,
                max: 5.0,
                divisions: 49,
                label: weight.toStringAsFixed(1),
                onChanged: (value) => setState(() => weight = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ADD'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final provider = context.read<QueueProvider>();
      setState(() => _isLoading = true);
      try {
        final rule = model.AssignmentRule(
          id: const Uuid().v4(),
          name: name,
          description: description,
          priority: priority,
          condition: condition,
          isActive: true,
        );
        await provider.addRule(rule);
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
        title: const Text('Assignment Rules'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Consumer<QueueProvider>(
          builder: (context, provider, _) {
            final rules = provider.queueManager?.settings.rules ?? [];

            if (rules.isEmpty) {
              return const Center(
                child: Text('No rules configured'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rules.length,
              itemBuilder: (context, index) {
                final rule = rules[index];
                return Card(
                  child: ExpansionTile(
                    title: Text(rule.name),
                    subtitle: Text(rule.condition),
                    trailing: Switch(
                      value: rule.isActive,
                      onChanged: (value) async {
                        setState(() => _isLoading = true);
                        try {
                          await provider.updateRule(
                            rule.copyWith(isActive: value),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description: ${rule.description}'),
                            Text('Priority: ${rule.priority}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
                                  onPressed: () => _deleteRule(context, rule),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRuleDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteRule(BuildContext context, model.AssignmentRule rule) async {
    final queueProvider = context.read<QueueProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rule'),
        content: Text('Are you sure you want to delete "${rule.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await queueProvider.deleteRule(rule.id);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}