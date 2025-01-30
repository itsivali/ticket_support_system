import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agent_provider.dart';
import '../widgets/agent_card.dart';
import '../utils/console_logger.dart';


class AgentListScreen extends StatefulWidget {
  const AgentListScreen({super.key});

  @override
  State<AgentListScreen> createState() => _AgentListScreenState();
}

class _AgentListScreenState extends State<AgentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgentProvider>().fetchAgents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Agents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Agents',
            onPressed: () => context.read<AgentProvider>().fetchAgents(),
          ),
        ],
      ),
      body: Consumer<AgentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, 
                    size: 48, 
                    color: colorScheme.error
                  ),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => provider.fetchAgents(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.agents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, 
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No agents available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: provider.agents.length,
            itemBuilder: (context, index) {
              final agent = provider.agents[index];
              return AgentCard(agent: agent);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ConsoleLogger.info(
            'Navigating to Create Agent screen',
            'Creating new agent from AgentListScreen'
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateAgentScreen()),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('New Agent'),
      ),
    );
  }
}