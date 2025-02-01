class QueueSettings {
  final bool autoAssignEnabled;
  final int maxTicketsPerAgent;
  final Duration reassignmentDelay;
  final Map<String, int> priorityWeights;
  final int maxQueueSize;
  final bool allowManualClaims;
  final Duration autoAssignInterval;

  const QueueSettings({
    this.autoAssignEnabled = true,
    this.maxTicketsPerAgent = 3,
    this.reassignmentDelay = const Duration(minutes: 15),
    this.priorityWeights = const {
      'HIGH': 3,
      'MEDIUM': 2,
      'LOW': 1,
    },
    this.maxQueueSize = 100,
    this.allowManualClaims = true,
    this.autoAssignInterval = const Duration(minutes: 5),
  });

  factory QueueSettings.fromJson(Map<String, dynamic> json) {
    return QueueSettings(
      autoAssignEnabled: json['autoAssignEnabled'] ?? true,
      maxTicketsPerAgent: json['maxTicketsPerAgent'] ?? 3,
      reassignmentDelay: Duration(
        minutes: json['reassignmentDelayMinutes'] ?? 15
      ),
      priorityWeights: Map<String, int>.from(
        json['priorityWeights'] ?? const {
          'HIGH': 3,
          'MEDIUM': 2,
          'LOW': 1,
        }
      ),
      maxQueueSize: json['maxQueueSize'] ?? 100,
      allowManualClaims: json['allowManualClaims'] ?? true,
      autoAssignInterval: Duration(
        minutes: json['autoAssignIntervalMinutes'] ?? 5
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'autoAssignEnabled': autoAssignEnabled,
    'maxTicketsPerAgent': maxTicketsPerAgent,
    'reassignmentDelayMinutes': reassignmentDelay.inMinutes,
    'priorityWeights': priorityWeights,
    'maxQueueSize': maxQueueSize,
    'allowManualClaims': allowManualClaims,
    'autoAssignIntervalMinutes': autoAssignInterval.inMinutes,
  };

  QueueSettings copyWith({
    bool? autoAssignEnabled,
    int? maxTicketsPerAgent,
    Duration? reassignmentDelay,
    Map<String, int>? priorityWeights,
    int? maxQueueSize,
    bool? allowManualClaims,
    Duration? autoAssignInterval,
  }) {
    return QueueSettings(
      autoAssignEnabled: autoAssignEnabled ?? this.autoAssignEnabled,
      maxTicketsPerAgent: maxTicketsPerAgent ?? this.maxTicketsPerAgent,
      reassignmentDelay: reassignmentDelay ?? this.reassignmentDelay,
      priorityWeights: priorityWeights ?? this.priorityWeights,
      maxQueueSize: maxQueueSize ?? this.maxQueueSize,
      allowManualClaims: allowManualClaims ?? this.allowManualClaims,
      autoAssignInterval: autoAssignInterval ?? this.autoAssignInterval,
    );
  }

  bool isValid() {
    return maxTicketsPerAgent > 0 &&
           maxQueueSize > 0 &&
           priorityWeights.isNotEmpty &&
           priorityWeights.values.every((weight) => weight > 0);
  }

  int getPriorityWeight(String priority) {
    return priorityWeights[priority] ?? 1;
  }
}