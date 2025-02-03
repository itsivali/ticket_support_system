class QueueSettings {
  bool autoAssign;

  QueueSettings({
    this.autoAssign = false,
  });

  QueueSettings copyWith({bool? autoAssign}) {
    return QueueSettings(
      autoAssign: autoAssign ?? this.autoAssign,
    );
  }
}