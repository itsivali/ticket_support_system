import 'package:flutter/material.dart';
import '../models/agent.dart';

class AgentCard extends StatelessWidget {
  final Agent agent;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onStatusChanged;

  const AgentCard({
    super.key,
    required this.agent,
    this.onEdit,
    this.onDelete,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const Divider(),
              _buildStatusSection(),
              if (agent.skills.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildSkillsSection(),
              ],
              const SizedBox(height: 8),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            agent.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agent.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                agent.role,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        _buildStatusIndicator(),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: agent.isOnline ? Colors.green[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 12,
            color: agent.isOnline ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            agent.isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              color: agent.isOnline ? Colors.green[700] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatusItem(
          icon: Icons.assignment,
          label: 'Tickets',
          value: agent.currentTickets.length.toString(),
        ),
        _buildStatusItem(
          icon: Icons.access_time,
          label: 'Available',
          value: agent.isAvailable ? 'Yes' : 'No',
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text('$label: $value'),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: agent.skills.map((skill) {
        return Chip(
          label: Text(
            skill,
            style: const TextStyle(fontSize: 12),
          ),
          padding: const EdgeInsets.all(4),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onStatusChanged != null)
          Switch(
            value: agent.isAvailable,
            onChanged: onStatusChanged,
          ),
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Agent'),
                  content: Text('Are you sure you want to delete ${agent.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete?.call();
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}