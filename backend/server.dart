import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'resolvers/inventory_resolver.dart';
import 'resolvers/order_resolver.dart';

/// Minimal GraphQL-over-HTTP server implemented with only the Dart standard
/// library.
///
/// Usage:
///   dart run backend/server.dart
///
/// Endpoint: POST /graphql
/// Body:     { "query": "<graphql>", "variables": { ... } }
/// Response: { "data": { "<field>": ... } } or { "errors": [ ... ] }
Future<void> main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  final scriptPath = Platform.script.toFilePath();
  final scriptDir = File(scriptPath).parent.path;
  final ordersPath = '$scriptDir/data/orders.json';
  final inventoryPath = '$scriptDir/data/inventory.json';

  final orderResolver = OrderResolver(ordersPath);
  final inventoryResolver = InventoryResolver(inventoryPath);

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('GraphQL server listening on http://localhost:$port/graphql');

  await for (final request in server) {
    try {
      _applyCorsHeaders(request.response);

      if (request.method == 'OPTIONS') {
        request.response.statusCode = HttpStatus.noContent;
        await request.response.close();
        continue;
      }

      if (request.method != 'POST' || request.uri.path != '/graphql') {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Only POST /graphql is supported.');
        await request.response.close();
        continue;
      }

      final body = await utf8.decoder.bind(request).join();
      final payload = jsonDecode(body) as Map<String, dynamic>;
      final query = (payload['query'] as String?) ?? '';
      final variables =
          (payload['variables'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};

      final result = await executeGraphQL(
        query: query,
        variables: variables,
        orderResolver: orderResolver,
        inventoryResolver: inventoryResolver,
      );

      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(result));
      await request.response.close();
    } catch (e, st) {
      stderr.writeln('Request failed: $e\n$st');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write(
        jsonEncode({
          'errors': [
            {'message': 'Internal server error: $e'},
          ],
        }),
      );
      await request.response.close();
    }
  }
}

void _applyCorsHeaders(HttpResponse response) {
  response.headers.add('Access-Control-Allow-Origin', '*');
  response.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS');
  response.headers.add('Access-Control-Allow-Headers', 'Content-Type');
}

/// Executes a GraphQL query/mutation against the resolvers. Kept as a
/// top-level function so it can be reused by tests or embedded hosts.
Future<Map<String, dynamic>> executeGraphQL({
  required String query,
  required Map<String, dynamic> variables,
  required OrderResolver orderResolver,
  required InventoryResolver inventoryResolver,
}) async {
  final fieldName = _extractTopLevelField(query);
  if (fieldName == null) {
    return {
      'errors': [
        {'message': 'Could not parse top-level field from query.'},
      ],
    };
  }

  try {
    switch (fieldName) {
      case 'getOrders':
        final orders = await orderResolver.getOrders();
        return {
          'data': {'getOrders': orders},
        };
      case 'getOrderById':
        final id = variables['id'] as String?;
        if (id == null) {
          return {
            'errors': [
              {'message': 'Missing required variable: id'},
            ],
          };
        }
        final order = await orderResolver.getOrderById(id);
        return {
          'data': {'getOrderById': order},
        };
      case 'getInventory':
        final items = await inventoryResolver.getInventory();
        return {
          'data': {'getInventory': items},
        };
      case 'updateOrderStatus':
        final id = variables['id'] as String?;
        final status = variables['status'] as String?;
        if (id == null || status == null) {
          return {
            'errors': [
              {'message': 'updateOrderStatus requires id and status'},
            ],
          };
        }
        final updated = await orderResolver.updateOrderStatus(id, status);
        return {
          'data': {'updateOrderStatus': updated},
        };
      default:
        return {
          'errors': [
            {'message': 'Unknown field: $fieldName'},
          ],
        };
    }
  } catch (e) {
    return {
      'errors': [
        {'message': 'Resolver error for $fieldName: $e'},
      ],
    };
  }
}

/// Extracts the first selection-set field name from a GraphQL document, e.g.
/// `query { getOrders { id } }` -> `getOrders`.
String? _extractTopLevelField(String query) {
  final match = RegExp(r'\{\s*([A-Za-z_][A-Za-z0-9_]*)').firstMatch(query);
  return match?.group(1);
}
