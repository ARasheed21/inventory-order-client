
---

# Project Constitution: Full-Stack Monorepo

## Preamble
This document defines the **immutable architectural principles** of the system. Every architectural decision, code review, and PR must align with these laws. Implementation details (libraries, exact paths, third-party tools) are delegated to the accompanying `implementation-guide.md`.

---

## 1. Architectural Sovereignty (Clean Architecture)
- **Dependency Rule**: Source code dependencies must point **inward**. 
  - `Presentation` → `Application` → `Domain` ← `Data`
- **Domain Isolation**: The Domain layer (entities, repository interfaces, use cases) must be **pure Dart**. It must have **zero** imports from Flutter, Web frameworks, or UI libraries.
- **Separation of Concerns**: Business logic, UI, data sources, and infrastructure must be decoupled and independently testable.

## 2. Monorepo Structure
- The project is a single **monorepo** containing exactly **three logical packages**:
  1. **Shared Core**: Contains all business logic, domain models, data sources, and infrastructure.
  2. **Mobile Client**: Contains the mobile-specific UI and application setup.
  3. **Web Client**: Contains the web-specific UI and application setup.
- **Export Integrity**: The Shared Core must expose its public API via a single entry point. Internal `src/` or `lib/` folders must never be imported directly by clients.

## 3. State Management (Reactive & Unidirectional)
- **Reactive State**: All application state must be reactive. UI must automatically rebuild when state changes.
- **Immutability**: State objects must be immutable (`@immutable`). Use `copyWith` for modifications.
- **Async Handling**: All asynchronous operations must expose a standardized loading/error/data state.
- **Source of Truth**: The local database must be the single source of truth for cached data. Network data is a transient upgrade.
- **UI Responsiveness**: Updates to the UI must be optimistic by default, with rollback mechanisms on failure.

## 4. Data Layer Principles
- **Offline-First**: The application must function without a network connection by relying on a local persistent store.
- **Sync Strategy**: The system must synchronize local changes to the backend in the background, handling conflicts gracefully.
- **Real-Time**: The system must support real-time updates via a persistent connection (e.g., WebSockets) with automatic reconnection logic.
- **Error Abstraction**: All failures (Network, Authentication, Server, Validation) must be mapped to a domain-specific sealed class or union type. Raw exceptions must not bubble to the UI.

## 5. Domain Layer Principles
- **Purity**: Domain entities and value objects must be plain Dart classes containing only business logic.
- **Contracts**: Repository interfaces must be defined in the Domain layer. Implementations belong in the Data layer.
- **Use Cases**: Complex business workflows must be encapsulated into single-purpose classes or functions.

## 6. Presentation Principles
- **UI is a Function of State**: The UI must strictly render based on the current state from the State Management layer.
- **Navigation Logic**: Routing must be declarative and centrally defined. Route guards must prevent unauthorized access based on authentication/roles.
- **Shared UI**: Reusable components (buttons, inputs, modals) must be standardized across both Mobile and Web clients where possible.
- **User Feedback**: Every user action must result in immediate visual feedback: loading (skeletons/spinners), success (snackbars/toasts), or error (friendly messages with retry actions).

## 7. Theming & Design System
- **Design Tokens**: Visual properties (colors, spacing, typography, radii) must be defined as centralized variables (tokens).
- **Platform Consistency**: Mobile and Web clients must share the same design tokens to ensure visual consistency across platforms.
- **Adaptation**: Styling must support dark/light mode and responsive layouts natively.

## 8. Security Tenets
- **Credential Storage**: Authentication tokens must be stored in secure, platform-appropriate storage (encrypted where possible).
- **Transport Security**: All network communication with critical endpoints must enforce certificate validation and pinning.
- **Input Sanitization**: User-generated input must be sanitized to prevent injection attacks.
- **Obfuscation**: Release builds must be obfuscated to protect intellectual property and reduce attack surface.

## 9. Testing Mandates
- **Unit Tests**: Domain entities, repository interfaces, and business logic must have unit tests (≥80% coverage for Core package).
- **Widget/Component Tests**: UI components must be tested in isolation using mocks for dependencies.
- **Integration Tests**: Critical user journeys (Auth, Ordering) must be tested end-to-end against a real test backend.
- **CI Gate**: The CI pipeline must not merge code that breaks tests or reduces coverage below the threshold.

## 10. Code Quality & Style
- **Null Safety**: Code must be fully null-safe.
- **Avoid `dynamic`**: Explicit types must be used. `dynamic` is forbidden unless interacting with external unsafe libraries.
- **Finite States**: Use `sealed` classes or unions for finite state machines.
- **Naming**: Follow standard Dart conventions (`UpperCamel` for classes, `lowerCamel` for variables/methods, `snake_case` for files).
- **Documentation**: Public APIs must have `///` doc comments explaining intent and parameters.

## 11. Development Workflow
- **Version Control**: Git branching strategy (e.g., feature branches → PR → `main`).
- **Commits**: Conventional Commits (`feat:`, `fix:`, `chore:`) must be used for automated versioning and changelog generation.
- **Code Reviews**: All code must be peer-reviewed before merging.

---