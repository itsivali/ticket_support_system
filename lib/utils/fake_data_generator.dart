import 'package:faker/faker.dart';
import '../models/ticket.dart';
import '../models/agent.dart';
import '../models/shift_schedule.dart';
import '../models/queued_ticket.dart';
import '../models/queue_manager.dart';

class FakeDataGenerator {
  final Faker _faker = Faker();

  List<Agent> generateAgents(int count) {
    return List.generate(count, (index) {
      return Agent(
        id: _faker.guid.guid(),
        name: _faker.person.name(),
        email: _faker.internet.email(),
        role: _faker.randomGenerator.element(['SUPPORT', 'SUPERVISOR', 'ADMIN']),
        isAvailable: _faker.randomGenerator.boolean(),
        isOnline: _faker.randomGenerator.boolean(),
        skills: _faker.lorem.words(5).toList(),
        currentTickets: [],
        shiftSchedule: generateShiftSchedule(),
        lastAssignment: _faker.date.dateTime(),
      );
    });
  }

  List<Ticket> generateTickets(int count) {
    return List.generate(count, (index) {
      return Ticket(
        id: _faker.guid.guid(),
        title: _faker.lorem.sentence(),
        description: _faker.lorem.sentences(3).join(' '),
        status: _faker.randomGenerator.element(['OPEN', 'IN_PROGRESS', 'CLOSED']),
        priority: _faker.randomGenerator.element(['LOW', 'MEDIUM', 'HIGH']),
        assignedTo: null,
        createdAt: _faker.date.dateTime(),
        dueDate: _faker.date.dateTime(),
        estimatedHours: _faker.randomGenerator.integer(8, min: 1),
        requiredSkills: _faker.lorem.words(3).toList(),
      );
    });
  }

  ShiftSchedule generateShiftSchedule() {
    final now = DateTime.now();
    return ShiftSchedule(
      id: _faker.guid.guid(),
      agentId: _faker.guid.guid(),
      weekdays: List.generate(5, (index) => _faker.randomGenerator.integer(7, min: 1)),
      startTime: DateTime(now.year, now.month, now.day, 9, 0),
      endTime: DateTime(now.year, now.month, now.day, 17, 0),
      isActive: _faker.randomGenerator.boolean(),
    );
  }

  List<QueuedTicket> generateQueuedTickets(List<Ticket> tickets) {
    return tickets.map((ticket) {
      return QueuedTicket(
        id: _faker.guid.guid(),
        ticket: ticket,
        priority: _faker.randomGenerator.decimal(min: 1, scale: 3),
        queuedAt: _faker.date.dateTime(),
      );
    }).toList();
  }

  QueueManager generateQueueManager(List<QueuedTicket> queuedTickets) {
    return QueueManager(
      id: _faker.guid.guid(),
      settings: QueueSettings(
        autoAssignEnabled: _faker.randomGenerator.boolean(),
        maxTicketsPerAgent: 3,
        priorityWeights: {
          'HIGH': 3,
          'MEDIUM': 2,
          'LOW': 1,
        },
      ),
      pendingTickets: queuedTickets,
      agentAssignments: {},
    );
  }
}