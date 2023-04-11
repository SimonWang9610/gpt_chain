import 'package:gpt_chain/tools/base_tool.dart';

import 'base.dart';

class HumanMessage extends Message {
  final bool isIntermediate;

  const HumanMessage(super.content, {this.isIntermediate = false});

  @override
  String toString() {
    return '<HUMAN>$content</HUMAN>\n';
  }
}

class IntermediateMessage extends HumanMessage {
  final BaseTool tool;
  const IntermediateMessage(
    super.content, {
    super.isIntermediate = true,
    required this.tool,
  });
}
