import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/agent_provider.dart';
import '../../models/agent.dart';
import '../../widgets/agent_card.dart';
import '../../widgets/app_drawer.dart';
import 'create_agent_screen.dart';

class AgentListScreen extends StatelessWidget {
  const AgentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agents')),
      body: Consumer<AgentProvider>(
        builder: (context, provider, child) {
          final agents = provider.agents;
          return ListView.builder(
            itemCount: agents.length,
            itemBuilder: (context, index) => AgentCard(agent: agents[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-agent'),
        child: const Icon(Icons.add),
      ),
    );
  }
}