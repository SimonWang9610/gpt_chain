import 'dart:convert';

import 'package:gpt_chain/tools/search_tool.dart';

import 'api_tool.dart';

class GoogleSearchAuthentication implements SearchAuthentication {
  final String cx;
  final String key;

  const GoogleSearchAuthentication({
    required this.cx,
    required this.key,
  });

  @override
  Map<String, dynamic> toQueryMap() {
    return {
      'cx': cx,
      'key': key,
    };
  }
}

Map<String, dynamic> _defaultQueryBuilder(String input,
    [SearchAuthentication? authentication]) {
  return {
    'q': input,
    ...?authentication?.toQueryMap(),
  };
}

class GoogleSearch extends SearchTool {
  const GoogleSearch({
    super.description = 'useful for searching online information',
    super.name = 'Google Search',
    super.endpoint = 'customsearch.googleapis.com',
    super.method = 'GET',
    super.path = '/customsearch/v1',
    super.headers = const {
      'Content-Type': 'application/json',
    },
    super.queryBuilder = _defaultQueryBuilder,
    super.authentication,
    super.inputFormat,
  });

  @override
  List<SearchResult> parseSearchResults(String body) {
    final data = json.decode(body) as Map<String, dynamic>;

    final items = data['items'] as List<dynamic>;

    final parsedResult = <SearchResult>[];

    for (final item in items) {
      final title = item['title'] as String?;
      final link = item['link'] as String?;
      final desc = item['snippet'] as String?;

      if (title != null || link != null || desc != null) {
        parsedResult.add(SearchResult(
          title: title,
          link: link,
          snippet: desc,
        ));
      }

      if (parsedResult.length >= 5) {
        break;
      }
    }

    return parsedResult;
  }
}
