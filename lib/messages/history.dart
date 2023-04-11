import 'base.dart';

import '../prompts/instruction_builder.dart';

class HistoryContext {
  final List<Message> messages = [];

  void add(Message msg) {
    messages.add(msg);
    _dirty = true;
  }

  void addAll(Iterable<Message> msgs) {
    messages.addAll(msgs);
    _dirty = true;
  }

  void clear() {
    messages.clear();
  }

  bool _dirty = false;

  String? _history;

  @override
  String toString() {
    if (_dirty || _history == null) {
      final joined = messages.join(',');
      _history = historyBuilder(joined);
      _dirty = false;
    }

    return _history ?? '';
  }
}
