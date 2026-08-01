# Backend — Dart GraphQL API

Minimum working GraphQL API implemented with only the Dart standard library.

## Running

```bash
dart run backend/server.dart
```

The server binds to `0.0.0.0:8080` by default. Override with the `PORT`
environment variable.

## Endpoint

```
POST /graphql
Content-Type: application/json

{ "query": "<graphql document>", "variables": { ... } }
```

## Schema

See [`schema.graphql`](./schema.graphql).

| Operation                              | Kind     |
| -------------------------------------- | -------- |
| `getOrders(status: OrderStatus)`       | Query    |
| `getOrderById(id: ID!)`                | Query    |
| `getInventory`                         | Query    |
| `updateOrderStatus(id, status)`        | Mutation |

`OrderStatus` is `PENDING | PROCESSING | SHIPPED | DELIVERED`.
`InventoryItem` exposes `lowStockThreshold` and derived `isLowStock`.

## Data

The `data/` folder contains JSON files that act as the simulated database:

- `data/orders.json`
- `data/inventory.json`

Mutations write back to `data/orders.json` on disk.

## Try it

```bash
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"query { getOrders { id status total } }"}'
```

```bash
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation($id:ID!,$status:String!){ updateOrderStatus(id:$id,status:$status){ id status } }","variables":{"id":"ORD-1001","status":"SHIPPED"}}'
```

## Design notes

The server uses a deliberately small GraphQL parser: it extracts only the
top-level field name (`getOrders`, `updateOrderStatus`, ...) and relies on
the `variables` map for all arguments. This is sufficient for the fixed set
of operations in the schema and keeps the implementation dependency-free.
