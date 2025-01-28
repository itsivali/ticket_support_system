import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_card.dart';
import 'screens/create_ticket_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketProvider>()
        ..fetchTickets()
        ..fetchAgents();
    });
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TicketProvider>().fetchTickets(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.primaryColor,
              ),
              child: const Text(
                'Ticket System',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('All Tickets'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tickets');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/chat');
              },
            ),
          ],
        ),
      ),
      body: Consumer<TicketProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = provider.tickets;
          final openCount = tickets.where((t) => t.status == 'OPEN').length;
          final inProgressCount = tickets.where((t) => t.status == 'IN_PROGRESS').length;
          final closedCount = tickets.where((t) => t.status == 'CLOSED').length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildStatCard('Open', openCount, Colors.orange),
                    const SizedBox(width: 8),
                    _buildStatCard('In Progress', inProgressCount, Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatCard('Closed', closedCount, Colors.green),
                  ],
                ),
              ),
              Expanded(
                child: tickets.isEmpty
                    ? const Center(
                        child: Text('No tickets available'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) => TicketCard(
                          ticket: tickets[index],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TicketProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticket Support System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/create-ticket': (context) => const CreateTicketScreen(),
      },
    );
  }
}