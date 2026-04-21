import 'dart:convert';

import 'package:http/http.dart' as http;

import '../mock_server/mock_graphql_server.dart';

/// Selects the data source backing [GraphQLClient].
enum GraphQLBackend {
  /// POST the document to a running GraphQL server over HTTP.
  http,

  /// Execute the document against the in-process [MockGraphQLServer].
  mock,
}

/// Minimal GraphQL client built on top of `package:http` and Dart standard
/// libraries. No GraphQL package is used; the body is a plain JSON payload
/// containing `query` and `variables`.
class GraphQLClient {
  GraphQLClient({
    this.endpoint = 'http://localhost:8080/graphql',
    this.backend = GraphQLBackend.mock,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String endpoint;
  final GraphQLBackend backend;
  final http.Client _http;

  /// Executes [document] with optional [variables]. Returns the parsed
  /// `data` map, or throws [GraphQLException] if the server reports errors.
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic> variables = const {},
  }) async {
    final response = await _dispatch(document, variables);

    final errors = response['errors'];
    if (errors is List && errors.isNotEmpty) {
      throw GraphQLException(errors.cast<Map<String, dynamic>>());
    }
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw GraphQLException([
        {'message': 'Malformed GraphQL response: $response'},
      ]);
    }
    return data;
  }

  Future<Map<String, dynamic>> _dispatch(
    String document,
    Map<String, dynamic> variables,
  ) async {
    switch (backend) {
      case GraphQLBackend.mock:
        return MockGraphQLServer.instance.execute(document, variables);
      case GraphQLBackend.http:
        final res = await _http.post(
          Uri.parse(endpoint),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'query': document, 'variables': variables}),
        );
        if (res.statusCode != 200) {
          throw GraphQLException([
            {'message': 'HTTP ${res.statusCode}: ${res.body}'},
          ]);
        }
        return jsonDecode(res.body) as Map<String, dynamic>;
    }
  }

  void dispose() => _http.close();
}

class GraphQLException implements Exception {
  GraphQLException(this.errors);

  final List<Map<String, dynamic>> errors;

  @override
  String toString() =>
      'GraphQLException: ${errors.map((e) => e['message']).join('; ')}';
}
