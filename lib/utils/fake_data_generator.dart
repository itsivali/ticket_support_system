import 'package:faker/faker.dart';
import '../models/ticket.dart' as ticket_model;
import '../models/agent.dart';
import '../models/shift_schedule.dart';
import '../models/queue_manager.dart';
import '../models/queue_manager.dart' as queue_manager_model;
import '../models/queue_manager.dart' as queue_manager_model show AssignmentRule;

class QueueSettings {
  final bool autoAssignEnabled;
  final int maxTicketsPerAgent; 
  final Map<String, int> priorityWeights;
  final List<AssignmentRule> rules;

  QueueSettings({
    required this.autoAssignEnabled,
    required this.maxTicketsPerAgent,
    required this.priorityWeights,
    required this.rules,
  });
}

class AssignmentRule {
  final String id;
  final String name;
  final String description;
  final String condition; // AVAILABILITY, SHIFT_HOURS, WORKLOAD
  final String priority;
  final bool isActive;

  AssignmentRule({
    required this.id,
    required this.name,  
    required this.description,
    required this.condition,
    required this.priority,
    this.isActive = true,
  });
}

class FakeDataGenerator {
  final Faker _faker = Faker();

  List<String> _generateRandomAgentSkills() {
    final skillCount = _faker.randomGenerator.integer(3, min: 1);
    final shuffledSkills = List<String>.from([
      'JavaScript', 'Python', 'Java', 'Docker', 'AWS', 'React', 'Angular', 'Vue', 'Node.js', 'MongoDB'
    ])..shuffle();
    return shuffledSkills.take(skillCount).toList();
  }


  List<Agent> generateAgents(int count) {
    return List.generate(count, (index) {
      final agentId = _faker.guid.guid();
      return Agent(
        id: agentId,
        name: _faker.person.name(),
        email: _faker.internet.email(),
        role: _faker.randomGenerator.element(['SUPPORT', 'SUPERVISOR', 'ADMIN']),
        isAvailable: _faker.randomGenerator.boolean(),
        isOnline: _faker.randomGenerator.boolean(),
        skills: _generateRandomAgentSkills(),
        currentTickets: [],
        shiftSchedule: generateShiftSchedule(agentId: agentId),
        lastAssignment: _getRandomPastDate(maxDaysAgo: 7),
      );
    });
  }

  List<ticket_model.Ticket> generateTickets(int count) {
    return List.generate(count, (index) {
      final createdAt = _getRandomPastDate();
      return ticket_model.Ticket(
        id: _faker.guid.guid(),
        title: _faker.lorem.sentence(),
        description: _faker.lorem.sentences(3).join(' '),
        status: _faker.randomGenerator.element(['OPEN', 'IN_PROGRESS', 'CLOSED']),
        priority: _faker.randomGenerator.element(['LOW', 'MEDIUM', 'HIGH']),
        assignedTo: null,
        createdAt: createdAt,
        dueDate: _getRandomFutureDate(),
        estimatedHours: _faker.randomGenerator.integer(8, min: 1),
        requiredSkills: _faker.lorem.words(3).toList(),
        lastUpdated: _faker.date.dateTime(),
      );
    });
  }

  ShiftSchedule generateShiftSchedule({required String agentId}) {
    final now = DateTime.now();
    return ShiftSchedule(
      id: _faker.guid.guid(),
      agentId: agentId,
      weekdays: List.generate(5, (index) => _faker.randomGenerator.integer(7, min: 1)),
      startTime: DateTime(now.year, now.month, now.day, 9, 0),
      endTime: DateTime(now.year, now.month, now.day, 17, 0),
      isActive: _faker.randomGenerator.boolean(),
      scheduleType: _faker.randomGenerator.element(['FIXED', 'FLEXIBLE', 'ROTATING']),
    );
  }

  List<queue_manager_model.QueuedTicket> generateQueuedTickets(List<ticket_model.Ticket> tickets) {
    return tickets.map((ticket) {
      return queue_manager_model.QueuedTicket(
        id: _faker.guid.guid(),
        ticket: queue_manager_model.Ticket(
          id: ticket.id,
          title: ticket.title,
          status: ticket.status,
          priority: ticket.priority,
          assignedTo: ticket.assignedTo,
          createdAt: ticket.createdAt,
          dueDate: ticket.dueDate,
        ),
        priority: _faker.randomGenerator.decimal(min: 1, scale: 3),
        queuedAt: _faker.date.dateTime(),
      );
    }).toList();
  }

  QueueManager generateQueueManager(List<QueuedTicket> queuedTickets) {
    return QueueManager(
      id: _faker.guid.guid(),
      settings: queue_manager_model.QueueSettings(
        autoAssignEnabled: _faker.randomGenerator.boolean(),
        maxTicketsPerAgent: 3,
        priorityWeights: {
          'LOW': 1,
          'MEDIUM': 2,
          'HIGH': 3,
        },
        rules: [
          queue_manager_model.AssignmentRule(
            id: '1',
            name: 'Availability Check',
            description: 'Check if agent is available',
            condition: 'AVAILABILITY',
            priority: 'HIGH',
          ),
          queue_manager_model.AssignmentRule(
            id: '2', 
            name: 'Working Hours',
            description: 'Check agent working hours',
            condition: 'SHIFT_HOURS',
            priority: 'HIGH',
          ),
          queue_manager_model.AssignmentRule(
            id: '3',
            name: 'Workload Balance', 
            description: 'Balance ticket distribution',  
            condition: 'WORKLOAD',
            priority: 'MEDIUM',
          ),
        ],
      ),
      pendingTickets: queuedTickets,
      agentAssignments: {},
      lastAssignmentCheck: _getRandomPastDate(),
    );
  }

  DateTime _getRandomFutureDate() {
    final now = DateTime.now();
    final daysToAdd = _faker.randomGenerator.integer(14, min: 1);
    return now.add(Duration(days: daysToAdd));
  }

  DateTime _getRandomPastDate({int maxDaysAgo = 30}) {
    final now = DateTime.now();
    final daysAgo = _faker.randomGenerator.integer(maxDaysAgo);
    return now.subtract(Duration(days: daysAgo));
  }

  
}