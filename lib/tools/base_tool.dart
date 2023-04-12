import '../utils/utils.dart';

abstract class BaseTool {
  final String description;
  final String name;
  final String? inputFormat;

  const BaseTool({
    required this.description,
    required this.name,
    this.inputFormat,
  });

  Future<String> run(String input) async {
    String? result;
    try {
      result = await execute(input);
      Log.d('[Tool: $name]: $result');
    } catch (e) {
      Log.e('Error: $e');
    }
    return buildToolPrompt(input, result);
  }

  Future<String?> execute(String input);

  String get format {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('<TOOL>');
    buffer.writeln('<NAME>$name</NAME>');
    buffer.writeln('<DESCRIPTION>$description</DESCRIPTION>');

    if (inputFormat != null) {
      buffer.writeln('<FORMAT>$inputFormat</FORMAT>');
    }

    buffer.writeln('</TOOL>');
    return buffer.toString();
  }
}
