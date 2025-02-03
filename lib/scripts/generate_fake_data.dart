import 'package:flutter/material.dart';
import '../utils/fake_data_generator.dart';
import '../models/ticket.dart';
import '../models/agent.dart';
import '../models/shift_schedule.dart';
import '../models/queued_ticket.dart';
import '../models/queue_manager.dart';

void main() {
  final fakeDataGenerator = FakeDataGenerator();

  // Generate fake agents
  final agents = fakeDataGenerator.generateAgents(10);
  print('Generated Agents:');
  agents.forEach((agent) => print(agent));

  // Generate fake tickets
  final tickets = fakeDataGenerator.generateTickets(20);
  print('Generated Tickets:');
  tickets.forEach((ticket) => print(ticket));

  // Generate fake queued tickets
  final queuedTickets = fakeDataGenerator.generateQueuedTickets(tickets);
  print('Generated Queued Tickets:');
  queuedTickets.forEach((queuedTicket) => print(queuedTicket));

  // Generate fake queue manager
  final queueManager = fakeDataGenerator.generateQueueManager(queuedTickets);
  print('Generated Queue Manager:');
  print(queueManager);

  // Generate fake shift schedules
  final shiftSchedules = agents.map((agent) => fakeDataGenerator.generateShiftSchedule()).toList();
  print('Generated Shift Schedules:');
  shiftSchedules.forEach((schedule) => print(schedule));
}