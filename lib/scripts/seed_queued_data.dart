import 'package:faker/faker.dart';
import '../models/ticket.dart';
import '../models/queue_manager.dart';
import '../services/queue_service.dart';
import '../utils/console_logger.dart';

class QueueSeeder {
  final faker = Faker();
  final QueueService _queueService = QueueService();

  Future<void> seedQueueData() async {
    try {
      // Generate random tickets
      final tickets = _generateTickets(20); // Generate 20 tickets

      // Create queue manager with settings
      final queueManager = QueueManager(
        id: faker.guid.guid(),
        settings: QueueSettings(
          autoAssignEnabled: true,
          maxTicketsPerAgent: 3,
          priorityWeights: {
            'HIGH': 3,
            'MEDIUM': 2,
            'LOW': 1,
          },
        ),
        pendingTickets: _generateQueuedTickets(tickets),
        agentAssignments: {},
      );

      // Save to database through service
      await _queueService.saveQueueManager(queueManager);
      ConsoleLogger.info('Queue data seeded successfully');

    } catch (e) {
      ConsoleLogger.error('Error seeding queue data', e.toString());
    }
  }

  List<Ticket> _generateTickets(int count) {
    return List.generate(count, (index) {
      final createdAt = DateTime.now().subtract(
        Duration(days: faker.randomGenerator.integer(30))
      );
      
      return Ticket(
        id: faker.guid.guid(),
        title: faker.lorem.sentence(),
        description: faker.lorem.sentences(3).join(' '),
        status: faker.randomGenerator.element(['OPEN', 'IN_PROGRESS', 'CLOSED']),
        priority: faker.randomGenerator.element(['LOW', 'MEDIUM', 'HIGH']),
        assignedTo: null,
        createdAt: createdAt,
        dueDate: createdAt.add(Duration(days: faker.randomGenerator.integer(14, min: 1))),
        estimatedHours: faker.randomGenerator.integer(8, min: 1),
        requiredSkills: List.generate(
          faker.randomGenerator.integer(3, min: 1),
          (_) => faker.randomGenerator.element([
            'JavaScript', 'Python', 'Java', 'React', 'Flutter', 
            'MongoDB', 'Node.js', 'DevOps', 'AWS'
          ]),
        ),
        lastUpdated: DateTime.now(),
      );
    });
  }

  List<QueuedTicket> _generateQueuedTickets(List<Ticket> tickets) {
    return tickets.where((t) => t.status == 'OPEN').map((ticket) {
      return QueuedTicket(
        id: faker.guid.guid(),
        ticket: ticket,
        priority: _calculatePriority(ticket),
        queuedAt: ticket.createdAt,
      );
    }).toList();
  }

  double _calculatePriority(Ticket ticket) {
    double basePriority = switch(ticket.priority) {
      'HIGH' => 3.0,
      'MEDIUM' => 2.0,
      'LOW' => 1.0,
      _ => 1.0,
    };

    // Increase priority based on waiting time
    final waitingHours = DateTime.now().difference(ticket.createdAt).inHours;
    basePriority += (waitingHours / 24.0);

    // Increase priority for urgent tickets
    final hoursUntilDue = ticket.dueDate.difference(DateTime.now()).inHours;
    if (hoursUntilDue < 24) {
      basePriority *= 1.5;
    }

    return basePriority;
  }
}