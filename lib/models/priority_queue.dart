class PriorityQueue<T> {
  final List<_QueueItem<T>> _items = [];
  final int Function(T a, T b) _compare;

  PriorityQueue(this._compare);

  void enqueue(T item, double priority) {
    _items.add(_QueueItem(item, priority));
    _items.sort((a, b) {
      final priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;
      return _compare(a.item, b.item);
    });
  }

  T? dequeue() {
    if (_items.isEmpty) return null;
    return _items.removeAt(0).item;
  }

  List<T> get items => _items.map((item) => item.item).toList();
  bool get isEmpty => _items.isEmpty;
  int get length => _items.length;
}

class _QueueItem<T> {
  final T item;
  final double priority;

  _QueueItem(this.item, this.priority);
}