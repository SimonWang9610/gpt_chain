import 'dart:convert';

import 'package:gpt_chain/utils/utils.dart';
import 'package:simple_http_api/simple_http_api.dart';

import 'api_tool.dart';

class GoogleSearch extends ApiTool {
  final String cx;
  final String key;
  const GoogleSearch({
    required this.cx,
    required this.key,
    super.description = 'useful for searching online information',
    super.name = 'Google Search',
    super.endpoint = 'customsearch.googleapis.com',
    super.method = 'GET',
  });

  @override
  Future<String?> execute(String input) async {
    final url = Uri.https(
      endpoint,
      '/customsearch/v1',
      {
        'cx': cx,
        'key': key,
        'q': input,
      },
    );
    try {
      final response = await Api.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final map = json.decode(response.body) as Map<String, dynamic>;

      final items = map['items'] as List<dynamic>;

      return items.map((e) => e['title'] as String).join('\n');
    } catch (e) {
      Log.e('GoogleSearch exception', e.toString());
      return null;
    }
  }
}
