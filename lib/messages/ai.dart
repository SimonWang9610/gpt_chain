import 'base.dart';

class AIMessage extends Message {
  const AIMessage(super.content);

  @override
  String toString() {
    return '<AI>$content</AI>\n';
  }
}
