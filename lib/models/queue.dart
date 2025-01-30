class Queue {
  final String id;
  final List<QueuedTicket> tickets;
  final QueueSettings settings;

  Queue({
    required this.id,
    required this.tickets,
    required this.settings,
  });

  factory Queue.fromJson(Map<String, dynamic> json) {
    return Queue(
      id: json['_id'] ?? '',
      tickets: (json['tickets'] as List? ?? [])
          .map((ticket) => QueuedTicket.fromJson(ticket))
          .toList(),
      settings: QueueSettings.fromJson(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'tickets': tickets.map((t) => t.toJson()).toList(),
    'settings': settings.toJson(),
  };
}

class QueuedTicket {
  final String ticketId;
  final String priority;
  final DateTime addedAt;

  QueuedTicket({
    required this.ticketId,
    required this.priority,
    required this.addedAt,
  });

  factory QueuedTicket.fromJson(Map<String, dynamic> json) {
    return QueuedTicket(
      ticketId: json['ticketId'] ?? '',
      priority: json['priority'] ?? 'MEDIUM',
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'ticketId': ticketId,
    'priority': priority,
    'addedAt': addedAt.toIso8601String(),
  };
}

class QueueSettings {
  final bool autoAssign;
  final int maxTicketsPerAgent;
  final Map<String, int> priorityWeights;

  QueueSettings({
    this.autoAssign = true,
    this.maxTicketsPerAgent = 3,
    this.priorityWeights = const {
      'HIGH': 3,
      'MEDIUM': 2,
      'LOW': 1
    },
  });

  factory QueueSettings.fromJson(Map<String, dynamic> json) {
    return QueueSettings(
      autoAssign: json['autoAssign'] ?? true,
      maxTicketsPerAgent: json['maxTicketsPerAgent'] ?? 3,
      priorityWeights: Map<String, int>.from(json['priorityWeights'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'autoAssign': autoAssign,
    'maxTicketsPerAgent': maxTicketsPerAgent,
    'priorityWeights': priorityWeights,
  };
}