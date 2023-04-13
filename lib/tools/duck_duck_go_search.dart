import 'package:gpt_chain/tools/api_tool.dart';
import 'package:gpt_chain/tools/search_tool.dart';
import 'package:html/parser.dart';

Map<String, dynamic> _defaultQueryBuilder(String input,
    [SearchAuthentication? authentication]) {
  return {
    'q': input,
    ...?authentication?.toQueryMap(),
  };
}

class DuckDuckGoSearch extends SearchTool {
  const DuckDuckGoSearch({
    super.description = 'useful for searching online information',
    super.name = 'DuckDuckGo Search',
    super.endpoint = 'duckduckgo.com',
    super.method = 'GET',
    super.path = '/html',
    super.queryBuilder = _defaultQueryBuilder,
  });

  @override
  List<SearchResult> parseSearchResults(String body) {
    final doc = parse(body);

    final results = doc.querySelectorAll(".result");

    final parsedResult = <SearchResult>[];

    for (final result in results) {
      final title = result.querySelector(".result__title")?.text;
      final link = result.querySelector(".result__url")?.text;
      final desc = result.querySelector(".result__snippet")?.text;

      if (title != null || link != null || desc != null) {
        parsedResult.add(SearchResult(
          title: title?.trim(),
          link: link?.trim(),
          snippet: desc?.trim(),
        ));
      }

      if (parsedResult.length >= 5) {
        break;
      }
    }
    return parsedResult;
  }
}
