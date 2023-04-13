import 'package:simple_http_api/simple_http_api.dart';
import 'package:gpt_chain/utils/utils.dart';

import 'api_tool.dart';

typedef SearchQueryBuilder = Map<String, dynamic>? Function(String input,
    [SearchAuthentication? authentication]);

abstract class SearchTool extends ApiTool {
  final SearchQueryBuilder? queryBuilder;
  final String path;
  final SearchAuthentication? authentication;
  final bool useHttps;

  const SearchTool({
    required this.path,
    required super.description,
    required super.name,
    required super.endpoint,
    required super.method,
    super.headers,
    super.parser,
    super.inputFormat,
    this.authentication,
    this.queryBuilder,
    this.useHttps = true,
  });

  @override
  Future<String?> execute(String input) async {
    final url = _getUri(input);
    try {
      final response = await Api.get(
        url,
      );

      final result = parseSearchResults(response.body);

      return result.join(',');
    } catch (e) {
      Log.e('SearchTool exception', e.toString());
      return null;
    }
  }

  List<dynamic> parseSearchResults(String body);

  Uri _getUri(String input) {
    if (!useHttps) {
      return Uri.http(
        endpoint,
        path,
        queryBuilder?.call(input, authentication),
      );
    }
    return Uri.https(
      endpoint,
      path,
      queryBuilder?.call(input, authentication),
    );
  }
}

abstract class SearchAuthentication {
  Map<String, dynamic> toQueryMap();
}
