# Walkthrough — Setup, Run, and Test

End-to-end guide for bringing the Calebsons Flutter + GraphQL business
operations suite up locally. Follow the sections in order the first time
through.

## 1. Prerequisites

| Tool        | Version    | Check               |
| ----------- | ---------- | ------------------- |
| Dart SDK    | `^3.11.4`  | `dart --version`    |
| Flutter SDK | stable     | `flutter --version` |
| Git         | any recent | `git --version`     |
| `curl`      | any        | `curl --version`    |

Flutter ships its own Dart SDK, so installing Flutter satisfies both. On
macOS: `brew install --cask flutter`. Verify the toolchain:

```bash
flutter doctor
```

Resolve any red items for the platforms you want to target (iOS,
Android, web, desktop). For this walkthrough `web` or `macos` is enough.

## 2. Get the code

```bash
git clone <your-remote> calebsons
cd calebsons/calebsons_inc/calebsons_flutter_graphql_business_operations_suite
```

All commands below assume this directory as the working root unless
noted otherwise.

## 3. Run the backend

The backend is a dependency-free Dart HTTP server implementing GraphQL
manually over `POST /graphql`.

```bash
dart run backend/server.dart
```

Expected output:

```
GraphQL server listening on http://localhost:8080/graphql
```

Override the port with `PORT=9000 dart run backend/server.dart`. Leave
this terminal open and use a second one for the frontend.

### Smoke-test the API with curl

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

The mutation writes back to `backend/data/orders.json`.

## 4. Run the frontend

The frontend was generated with `flutter create` and has the full set of
platform folders already committed, so no additional scaffolding step is
required.

```bash
cd frontend
flutter pub get
flutter run            # pick a device/target when prompted
```

Common targeted runs:

```bash
flutter run -d chrome          # web
flutter run -d macos           # macOS desktop
flutter run -d <deviceId>      # use 'flutter devices' to list
```

### Mock vs. real backend

By default `AppState` constructs a client with `GraphQLBackend.mock`, so
the app runs fully offline against `MockGraphQLServer`. To hit the Dart
backend from step 3 instead, edit `frontend/lib/main.dart`:

```dart
final state = AppState(
  client: GraphQLClient(backend: GraphQLBackend.http),
);
```

The default endpoint is `http://localhost:8080/graphql`. Override with
`GraphQLClient(backend: GraphQLBackend.http, endpoint: '...')`.

## 5. Run the tests

### Frontend

```bash
cd frontend
flutter analyze
flutter test
```

Expected: `No issues found!` and `All tests passed!`.

### Backend

```bash
dart analyze backend
dart format --set-exit-if-changed backend
```

A `backend/test/` directory is not included; `dart test backend` is a
no-op until tests are added.

### Full suite via helper script

From the project root:

```bash
bash cicd/scripts/test.sh
```

This runs `dart analyze` against `backend/`, then `flutter pub get`,
`flutter analyze`, and `flutter test` inside `frontend/`.

### Auto-format everything

```bash
bash cicd/scripts/format.sh
```

## 6. Exercising the app manually

With the app running (mock or http backend):

1. **Dashboard** tab — open orders count, total revenue, low-stock list.
2. **Orders** tab — tap any row to open the details screen. Change the
   status via the dropdown; the list reflects the new status on return.
3. **Inventory** tab — low-stock items (< 10 units) are highlighted.
4. Pull to refresh on any list to re-query.

## 7. Troubleshooting

| Symptom                             | Fix                                                                                 |
| ----------------------------------- | ----------------------------------------------------------------------------------- |
| `flutter: command not found`        | Add the Flutter `bin/` to your `PATH`.                                              |
| `Address already in use` on backend | `PORT=9090 dart run backend/server.dart` or kill the old process.                   |
| Frontend can't reach the backend    | Confirm step 4 switched the client to `GraphQLBackend.http`.                        |
| Stale mutation data                 | Reset `backend/data/orders.json` from git: `git checkout backend/data/orders.json`. |
| Platform build errors (iOS/Android) | Run `flutter doctor` and resolve toolchain items for that target.                   |

## 8. Next steps

- Point CI at `cicd/github_actions/flutter_ci.yml` and
  `cicd/github_actions/backend_ci.yml` by copying them into
  `.github/workflows/` at the repo root.
- Add a new GraphQL operation by updating the documents in
  `frontend/lib/graphql/`, the dispatch in `backend/server.dart`, the
  parallel case in `frontend/lib/mock_server/mock_graphql_server.dart`,
  and any new resolver methods under `backend/resolvers/`.
