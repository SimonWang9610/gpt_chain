import 'package:gpt_chain/utils/utils.dart';

import '../tools/base_tool.dart';

import 'ai.dart';
import 'human.dart';

final aiReg = RegExp(r'<AI>(.*?)', multiLine: true, dotAll: true);
final toolReg = RegExp(r'<TOOL>(.*?)</TOOL>', multiLine: true, dotAll: true);
final nameReg = RegExp(r'<NAME>(.*?)</NAME>', multiLine: true, dotAll: true);
final actionReg =
    RegExp(r'<ACTION>(.*?)</ACTION>', multiLine: true, dotAll: true);
final inputReg = RegExp(r'<INPUT>(.*?)</INPUT>', multiLine: true, dotAll: true);

class SerializedMessage {
  final AIMessage? aiMessage;
  final IntermediateMessage? intermediateMessage;

  const SerializedMessage({
    this.aiMessage,
    this.intermediateMessage,
  });

  factory SerializedMessage.fromOutput(String output, List<BaseTool> tools) {
    final toolTag = toolReg.firstMatch(output)?.group(1);

    if (toolTag != null) {
      final name = nameReg.firstMatch(toolTag)?.group(1);
      final action = actionReg.firstMatch(toolTag)?.group(1);
      final input = inputReg.firstMatch(toolTag)?.group(1);

      if (name != null) {
        final found = tools.where((element) => element.name == name);

        if (found.isNotEmpty) {
          final content = action != null && input != null
              ? '$action for $input'
              : action ?? input ?? '';

          return SerializedMessage(
            intermediateMessage: IntermediateMessage(
              content,
              tool: found.first,
            ),
          );
        }
      }
    }

    final index = output.indexOf(aiReg, 0);

    final content =
        index >= 0 ? output.substring(index + '<AI>'.length) : output;

    return SerializedMessage(
      aiMessage: AIMessage(content.trim()),
    );
  }
}

const _attention =
    '(remember that your response MUST follow our FORMAT INSTRUCTIONS, and using AVAILABLE TOOLS if possible)';

Future<String> buildPromptFromMessage(
    HumanMessage message, String history) async {
  final StringBuffer buffer = StringBuffer('$history\n');

  if (message is! IntermediateMessage) {
    buffer.write('The new message is: ${message.content}');

    buffer.write(_attention);
    return buffer.toString();
  } else {
    final toolResult = await message.tool.run(message.content);

    Log.d('Tool result: $toolResult');

    buffer.write(toolResult);
    buffer.write(
        'You may use the given result to respond to the last human message.');
    return buffer.toString();
  }
}
