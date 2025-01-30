import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/agent.dart';
import '../models/ticket.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_card.dart';

class AgentDetailsScreen extends StatelessWidget {
  final Agent agent;

  const AgentDetailsScreen({super.key, required this.agent});

  Widget _buildTicketStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agent: ${agent.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TicketProvider>().fetchTickets(),
          ),
        ],
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          final assignedTickets = ticketProvider.tickets
              .where((ticket) => ticket.assignedTo == agent.id)
              .toList();

          final openTickets = assignedTickets
              .where((ticket) => ticket.status == 'OPEN')
              .length;
          final inProgressTickets = assignedTickets
              .where((ticket) => ticket.status == 'IN_PROGRESS')
              .length;
          final closedTickets = assignedTickets
              .where((ticket) => ticket.status == 'CLOSED')
              .length;

          return Column(
            children: [
              // Agent Info Card
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: agent.isAvailable ? Colors.green : Colors.grey,
                      child: const Icon(Icons.person, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agent.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(agent.email),
                          Chip(
                            label: Text(agent.role),
                            avatar: const Icon(Icons.work),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Ticket Statistics
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTicketStatCard(
                        'Open',
                        openTickets,
                        Icons.fiber_new,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTicketStatCard(
                        'In Progress',
                        inProgressTickets,
                        Icons.trending_up,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTicketStatCard(
                        'Closed',
                        closedTickets,
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Tickets List
              Expanded(
                child: assignedTickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No tickets assigned',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: assignedTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = assignedTickets[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                ticket.status == 'OPEN'
                                    ? Icons.fiber_new
                                    : ticket.status == 'IN_PROGRESS'
                                        ? Icons.trending_up
                                        : Icons.check_circle,
                                color: ticket.status == 'OPEN'
                                    ? Colors.orange
                                    : ticket.status == 'IN_PROGRESS'
                                        ? Colors.blue
                                        : Colors.green,
                              ),
                              title: Text(ticket.title),
                              subtitle: Text(
                                'Priority: ${ticket.priority} • Status: ${ticket.status}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/ticket-details',
                                arguments: ticket,
                              ),
                            ),
                          );
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