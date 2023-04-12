import 'dart:convert';

import 'package:simple_http_api/simple_http_api.dart';

import '../utils/utils.dart';
import 'base_tool.dart';

typedef ApiResultParser = String Function(ApiResponse);

String _defaultApiResultParser(ApiResponse response) {
  return response.body;
}

class ApiTool extends BaseTool {
  final String endpoint;
  final String method;
  final Map<String, String>? headers;
  final ApiResultParser parser;

  const ApiTool({
    required super.description,
    required super.name,
    required this.endpoint,
    required this.method,
    this.headers,
    this.parser = _defaultApiResultParser,
    super.inputFormat = 'must be a valid JSON string',
  });

  @override
  Future<String?> execute(String input) async {
    final url = Uri.parse(endpoint);

    ApiResponse? response;
    try {
      switch (method) {
        case 'GET':
          response = await Api.get(
            url,
            headers: headers,
          );
          break;
        case 'POST':
          response = await Api.post(
            url,
            headers: headers,
            body: json.encode(input),
          );
          break;
        case 'PUT':
          response = await Api.put(
            url,
            headers: headers,
            body: json.encode(input),
          );
          break;
        case 'DELETE':
          response = await Api.delete(
            url,
            headers: headers,
            body: json.encode(input),
          );
          break;
        default:
          throw Exception('Invalid method: $method');
      }
    } catch (e) {
      Log.e('Error: $e');
    }

    return response != null ? parser.call(response) : null;
  }
}
