import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/agent.dart';
import '../models/ticket.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ticket_support_system.db');

    _database = await openDatabase(path, version: 1, onCreate: _createDB);
    return _database!;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE agents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        online INTEGER NOT NULL,
        shiftStart TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        agentId INTEGER,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(agentId) REFERENCES agents (id)
      )
    ''');
  }

  // Agent CRUD Methods
  Future<int> createAgent(Agent agent) async {
    final db = await instance.database;
    return await db.insert('agents', agent.toMap());
  }

  Future<int> updateAgent(Agent agent) async {
    final db = await instance.database;
    return await db.update('agents', agent.toMap(),
        where: 'id = ?', whereArgs: [agent.id]);
  }

  Future<int> deleteAgent(int id) async {
    final db = await instance.database;
    return await db.delete('agents', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Agent>> getAgents() async {
    final db = await instance.database;
    final result = await db.query('agents');
    return result.map((map) => Agent.fromMap(map)).toList();
  }

  // Ticket CRUD Methods
  Future<int> createTicket(Ticket ticket) async {
    final db = await instance.database;
    return await db.insert('tickets', ticket.toMap());
  }

  Future<int> updateTicket(Ticket ticket) async {
    final db = await instance.database;
    return await db.update('tickets', ticket.toMap(),
        where: 'id = ?', whereArgs: [ticket.id]);
  }

  Future<int> deleteTicket(int id) async {
    final db = await instance.database;
    return await db.delete('tickets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Ticket>> getTickets() async {
    final db = await instance.database;
    final result = await db.query('tickets');
    return result.map((map) => Ticket.fromMap(map)).toList();
  }


  Future<void> assignTicket(Ticket ticket) async {
    final agents = await getAgents();
    final freeAgents = agents.where((a) {
      final shiftEnd = a.shiftStart.add(const Duration(hours: 8));
      return a.online && DateTime.now().isBefore(shiftEnd);
    }).toList();

    if (freeAgents.isNotEmpty) {
      final assignedAgent = freeAgents.first;
      await updateTicket(ticket.copyWith(agentId: assignedAgent.id));
    }
  }
}