// Dart: lib/screens/agents_screen.dart
import 'package:flutter/material.dart';
import '../models/agent.dart';
import '../services/database_helper.dart';

class AgentsScreen extends StatelessWidget {
  const AgentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Agent>>(
      future: DatabaseHelper.instance.getAgents(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading agents'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final agents = snapshot.data!;
        return ListView.builder(
          itemCount: agents.length,
          itemBuilder: (context, index) {
            final agent = agents[index];
            final shiftEnd = agent.shiftStart.add(const Duration(hours: 8));
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(agent.name),
              subtitle: Text('Shift: ${agent.shiftStart.hour}:${agent.shiftStart.minute} - ${shiftEnd.hour}:${shiftEnd.minute}'),
              trailing: Icon(agent.online ? Icons.wifi : Icons.wifi_off),
            );
          },
        );
      },
    );
  }
}