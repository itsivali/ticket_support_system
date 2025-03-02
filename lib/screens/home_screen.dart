import 'package:flutter/material.dart';
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

  void _addAgent() {
    // trigger a dialog or screen to create an Agent
  }

  void _addTicket() {
    // trigger a dialog or screen to create a Ticket
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