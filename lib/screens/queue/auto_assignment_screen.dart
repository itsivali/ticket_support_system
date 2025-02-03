import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/queue_provider.dart';

class AutoAssignmentScreen extends StatelessWidget {
  const AutoAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Assignment'),
      ),
      body: Consumer<QueueProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Enable Auto Assignment'),
                subtitle: Text(
                  provider.isAutoAssignEnabled
                      ? 'Tickets will be automatically assigned'
                      : 'Manual assignment only',
                ),
                value: provider.isAutoAssignEnabled,
                onChanged: (value) async {
                  await provider.toggleAutoAssign(value);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Assignment Rules'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                  Navigator.pushNamed(context, '/rules-configuration');
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}