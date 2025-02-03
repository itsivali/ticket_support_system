import 'package:mongo_dart/mongo_dart.dart';
import '../models/shift_schedule.dart';
import '../utils/console_logger.dart';
import '../utils/fake_data_generator.dart';

void main() async {
  try {
    final fakeDataGenerator = FakeDataGenerator();
    
    // Generate fake agents with shifts
    ConsoleLogger.info('Generating agents...');
    final agents = fakeDataGenerator.generateAgents(10);
    final shiftSchedules = agents.map((agent) {
      final shift = fakeDataGenerator.generateShiftSchedule(agentId: agent.id);
      return ShiftSchedule(
        id: shift.id,
        agentId: agent.id,
        weekdays: shift.weekdays,
        startTime: shift.startTime,
        endTime: shift.endTime,
        isActive: shift.isActive,
        scheduleType: shift.scheduleType,
      );
    }).toList();

    // Generate tickets and queue
    ConsoleLogger.info('Generating tickets...');
    final tickets = fakeDataGenerator.generateTickets(20);
    
    ConsoleLogger.info('Generating queued tickets...');
    final queuedTickets = fakeDataGenerator.generateQueuedTickets(tickets);
    
    ConsoleLogger.info('Generating queue manager...');
    final generatedQueueManager = fakeDataGenerator.generateQueueManager(queuedTickets);

    // Print generated data summary
    ConsoleLogger.info('\nGenerated Data Summary:');
    ConsoleLogger.info('Agents: ${agents.length}');
    ConsoleLogger.info('Shifts: ${shiftSchedules.length}');
    ConsoleLogger.info('Tickets: ${tickets.length}');
    ConsoleLogger.info('Queued Tickets: ${queuedTickets.length}');
    ConsoleLogger.info('Queue Manager Settings:');
    ConsoleLogger.info('- Auto Assign: ${generatedQueueManager.settings.autoAssignEnabled}');
    ConsoleLogger.info('- Max Tickets Per Agent: ${generatedQueueManager.settings.maxTicketsPerAgent}');

    ConsoleLogger.info('Connecting to MongoDB...');
    final db = await Db.create('mongodb://localhost:27017/ticket_support_system');
    await db.open();
    ConsoleLogger.info('Connected to MongoDB');

    final agentsCollection = db.collection('agents');
    final ticketsCollection = db.collection('tickets');
    final shiftSchedulesCollection = db.collection('shift_schedules');
    final queueManagerCollection = db.collection('queue_manager');

    ConsoleLogger.info('Saving agents to MongoDB...');
    await agentsCollection.insertAll(agents.map((agent) => agent.toJson()).toList());

    ConsoleLogger.info('Saving tickets to MongoDB...');
    await ticketsCollection.insertAll(tickets.map((ticket) => ticket.toJson()).toList());

    ConsoleLogger.info('Saving shift schedules to MongoDB...');
    await shiftSchedulesCollection.insertAll(shiftSchedules.map((schedule) => schedule.toJson()).toList());

    ConsoleLogger.info('Saving queue manager to MongoDB...');
    await queueManagerCollection.insertOne(generatedQueueManager.toJson());

    ConsoleLogger.info('Fake data generation and saving to MongoDB completed successfully.');
  } catch (e) {
    ConsoleLogger.error('Error generating fake data', e.toString());
  }
}