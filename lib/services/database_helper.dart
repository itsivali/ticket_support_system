import 'package:mongo_dart/mongo_dart.dart';
import '../models/agent.dart';
import '../models/ticket.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  late Db db;
  late DbCollection agentCollection;
  late DbCollection ticketCollection;

  DatabaseHelper._init();

  Future<void> init() async {
    // Update the connection string as needed.
    db = await Db.create('mongodb://localhost:27017/ticket_support_system');
    await db.open();
    agentCollection = db.collection('agents');
    ticketCollection = db.collection('tickets');
  }

  // Agent CRUD Methods
  Future<ObjectId> createAgent(Agent agent) async {
    final result = await agentCollection.insertOne(agent.toMap());
    return result.id as ObjectId;
  }

  Future<List<Agent>> getAgents() async {
    final List<Map<String, dynamic>> results = await agentCollection.find().toList();
    return results.map((map) => Agent.fromMap(map)).toList();
  }

  // Ticket CRUD Methods
  Future<ObjectId> createTicket(Ticket ticket) async {
    final result = await ticketCollection.insertOne(ticket.toMap());
    return result.id as ObjectId;
  }

  Future<List<Ticket>> getTickets() async {
    final List<Map<String, dynamic>> results = await ticketCollection.find().toList();
    return results.map((map) => Ticket.fromMap(map)).toList();
  }

  Future<int> updateTicket(Ticket ticket) async {
    // using the _id field from MongoDB
    var id = ticket.id is ObjectId ? ticket.id : ObjectId.fromHexString(ticket.id.toString());
    final result = await ticketCollection.updateOne(
      where.id(id),
      modify.set('agentId', ticket.agentId).set('title', ticket.title).set('description', ticket.description),
    );
    return result.nModified;
  }

  Future<int> deleteTicket(String id) async {
    final result = await ticketCollection.deleteOne(where.id(ObjectId.fromHexString(id)));
    return result.nRemoved;
  }

  Future<void> assignTicket(Ticket ticket) async {
    // Example: assign ticket to the first free agent.
    final agents = await getAgents();
    final freeAgents = agents.where((a) {
      final shiftEnd = a.shiftStart.add(const Duration(hours: 8));
      return a.online && DateTime.now().isBefore(shiftEnd);
    }).toList();

    if (freeAgents.isNotEmpty) {
      final assignedAgent = freeAgents.first;
      Ticket updatedTicket = ticket.copyWith(agentId: assignedAgent.id);
      await updateTicket(updatedTicket);
    }
  }
}