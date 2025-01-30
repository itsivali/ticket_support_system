class PriorityQueue<T> {
  final List<QueueItem<T>> _items = [];
  final int Function(T a, T b) _compareItems;

  PriorityQueue(this._compareItems);

  void enqueue(T item, double priority) {
    _items.add(QueueItem(item, priority));
    _sortQueue();
  }

  T? dequeue() {
    if (_items.isEmpty) return null;
    return _items.removeAt(0).item;
  }

  void _sortQueue() {
    _items.sort((a, b) {
      final comparison = b.priority.compareTo(a.priority);
      if (comparison != 0) return comparison;
      return _compareItems(b.item, a.item);
    });
  }

  bool get isEmpty => _items.isEmpty;
  int get length => _items.length;
  List<T> get items => _items.map((i) => i.item).toList();
}

class QueueItem<T> {
  final T item;
  final double priority;
  final DateTime addedAt;

  QueueItem(this.item, this.priority) : addedAt = DateTime.now();

  double get waitingTime => 
    DateTime.now().difference(addedAt).inMinutes.toDouble();
}