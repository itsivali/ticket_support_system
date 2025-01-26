class TicketListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support Tickets'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          return ListView.builder(
            itemCount: ticketProvider.tickets.length,
            itemBuilder: (context, index) {
              final ticket = ticketProvider.tickets[index];
              return TicketCard(ticket: ticket);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
        child: Icon(Icons.add),
      ),
    );
  }
}