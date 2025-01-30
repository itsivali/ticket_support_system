class QueueManager {
    final String id;
    final List<QueuedTicket> pendingTickets;
    final QueueSettings settings;
    final DateTime lastAssignmentCheck;
  
    QueueManager({
      required this.id,
      required this.pendingTickets,
      required this.settings,
      required this.lastAssignmentCheck,
    });
  
    factory QueueManager.fromJson(Map<String, dynamic> json) {
      return QueueManager(
        id: json['_id'] ?? '',
        pendingTickets: (json['pendingTickets'] as List? ?? [])
            .map((ticket) => QueuedTicket.fromJson(ticket))
            .toList(),
        settings: QueueSettings.fromJson(json['settings'] ?? {}),
        lastAssignmentCheck: DateTime.parse(json['lastAssignmentCheck'] ?? DateTime.now().toIso8601String()),
      );
    }
  
    Map<String, dynamic> toJson() => {
      'pendingTickets': pendingTickets.map((t) => t.toJson()).toList(),
      'settings': settings.toJson(),
      'lastAssignmentCheck': lastAssignmentCheck.toIso8601String(),
    };
  
    bool canAssignTicketTo(String agentId, DateTime dueDate) {
      // Assignment logic implementation
      return true;
    }
  }