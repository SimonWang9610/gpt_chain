import '../utils/utils.dart';

abstract class BaseTool {
  final String description;
  final String name;

  const BaseTool({
    required this.description,
    required this.name,
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

  String get format => '''
  <TOOL>
    <NAME>$name</NAME>
    <DESCRIPTION>$description</DESCRIPTION>
  </TOOL>
  ''';
}
