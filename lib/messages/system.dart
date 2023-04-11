import '../tools/base_tool.dart';
import '../prompts/instruction_builder.dart';

class SystemContext {
  final String role;
  final String rules;
  final List<BaseTool> tools;

  SystemContext({
    required this.role,
    required this.rules,
    required this.tools,
  });

  String? _systemContext;

  String get formattedTools {
    final StringBuffer buffer = StringBuffer();

    for (final tool in tools) {
      buffer.writeln(tool.format);
    }
    return buffer.toString();
  }

  String get systemContext {
    _systemContext ??= instructionBuilder(
      role: role,
      rule: rules,
      tools: formattedTools,
    );
    return _systemContext!;
  }

  @override
  String toString() {
    return systemContext;
  }
}
