# Calebsons Flutter + GraphQL — Business Operations Suite

## Overview
A cross-platform business operations suite built with Flutter and GraphQL. Includes dashboards, task management, inventory tracking, and offline support.

## Tech Stack
- Flutter
- GraphQL (Hasura / Apollo)
- Dart
- SQLite (offline)
- Web + Desktop + Mobile

## Features
- Real-time dashboards
- Task + inventory management
- Offline-first sync
- Multi-platform deployment
- Adaptive UI layouts

## Architecture
```mermaid
flowchart TD
    APP[Flutter App (Mobile/Web/Desktop)] --> GQL[GraphQL API]
    GQL --> DB[Postgres]
    APP --> SQLITE[Local SQLite - Offline Cache]
    GQL --> SUBS[Realtime Subscriptions]
    SUBS --> APP
    INFRA[GraphQL Host + Flutter Build Targets] -.-> GQL
```

## Setup
    flutter pub get
    flutter run

## Deployment
- Web build
- iOS/Android builds
- Desktop builds

## Roadmap
- Add messaging module
- Add workspace roles
