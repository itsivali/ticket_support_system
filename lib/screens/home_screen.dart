import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import '../models/agent.dart';
import '../models/ticket.dart';
import '../services/database_helper.dart';
import 'agents_screen.dart';
import 'tickets_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> myTabs = const <Tab>[
    Tab(icon: Icon(Icons.people), text: 'Agents'),
    Tab(icon: Icon(Icons.confirmation_number), text: 'Tickets'),
  ];

  final Faker faker = Faker(); 

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: myTabs.length);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addAgent() async {
    Agent agent = Agent(
      name: faker.person.name(),
      online: faker.randomGenerator.boolean(),
      shiftStart: DateTime.now(),
    );
    await DatabaseHelper.instance.createAgent(agent);
    setState(() {});
  }

  void _addTicket() async {
    Ticket ticket = Ticket(
      title: faker.lorem.sentence(),
      description: faker.lorem.sentences(3).join(' '),
      createdAt: DateTime.now(),
    );
    await DatabaseHelper.instance.createTicket(ticket);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISP Ticketing System'),
        bottom: TabBar(controller: _tabController, tabs: myTabs),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AgentsScreen(),
          TicketsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _addAgent();
          } else {
            _addTicket();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}