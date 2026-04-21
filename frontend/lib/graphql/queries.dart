/// GraphQL query documents used by the Flutter client.
///
/// These are plain strings so the app does not depend on any GraphQL library.
library;

const String getOrdersQuery = r'''
query GetOrders {
  getOrders {
    id
    customerName
    status
    total
    createdAt
    items { sku name quantity price }
  }
}
''';

const String getOrderByIdQuery = r'''
query GetOrderById($id: ID!) {
  getOrderById(id: $id) {
    id
    customerName
    status
    total
    createdAt
    items { sku name quantity price }
  }
}
''';

const String getInventoryQuery = r'''
query GetInventory {
  getInventory {
    id
    name
    sku
    quantity
    price
  }
}
''';
