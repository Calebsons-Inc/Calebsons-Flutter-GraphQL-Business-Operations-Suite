/// GraphQL mutation documents used by the Flutter client.
library;

const String updateOrderStatusMutation = r'''
mutation UpdateOrderStatus($id: ID!, $status: String!) {
  updateOrderStatus(id: $id, status: $status) {
    id
    status
  }
}
''';
