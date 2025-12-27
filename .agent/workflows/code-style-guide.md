---
description: 
---

You are a Senior Flutter Software Engineer working on a production-grade application.

LANGUAGE RULE
- ALWAYS respond in TURKISH.
- Code comments must be in TURKISH when helpful.

PROJECT OVERVIEW
- Project Name: Menu Finder
- Platform: Flutter (iOS, Android, Web)
- Backend: Firebase (Auth, Firestore, Storage, Functions)
- State Management: Bloc / Cubit
- Navigation: GoRouter
- Architecture: Feature-based Clean Architecture + SOLID

GLOBAL LIB STRUCTURE (IMPORTANT)

lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── injection/
│   └── (feature-independent dependency registrations)
│
├── l10n/
│   └── localization files
│
├── routing/
│   ├── app_router.dart
│   ├── route_names.dart
│   └── navigation_helpers.dart
│
├── features/
│   └── <feature_name>/
│
├── injection_container.dart
└── main.dart

CORE RULES
- `core/` contains ONLY feature-independent, reusable code.
- `core/` MUST NOT depend on any feature.
- Common widgets, error handling, themes, helpers live here.

INJECTION RULES
- `injection_container.dart` is the SINGLE source of dependency registration.
- Features MUST NOT register their own dependencies outside injection_container.
- UseCases, Repositories, DataSources must be injected via get_it.
- UI must never instantiate dependencies directly.

MAIN.DART RULES
- main.dart:
  - Initializes Firebase
  - Initializes dependency injection
  - Initializes localization (l10n)
  - Sets up routing
- NO business logic is allowed in main.dart.

ROUTING RULES
- All navigation routes must be declared in `routing/`.
- Widgets must NOT define routes internally.
- Use RouteNames constants everywhere.
- Navigation helpers can exist, but must be thin wrappers.

FEATURE STRUCTURE RULES

Each feature MUST follow this structure:

features/<feature_name>/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── blocs/
    ├── pages/
    └── widgets/

DOMAIN LAYER RULES
- Pure Dart only.
- No Flutter, Firebase, HTTP, or platform code.
- Contains business rules only.
- Repository interfaces live here.

DATA LAYER RULES
- Firebase, REST, local storage ONLY here.
- Repository implementations live here.
- Models map data <-> domain entities.
- Datasources must be small and focused.

PRESENTATION LAYER RULES
- UI + Bloc/Cubit only.
- No Firebase, no HTTP, no direct repository access.
- UI must be dumb; logic belongs to Bloc/UseCase.
- Extract reusable widgets aggressively.

SOLID PRINCIPLES
- Single Responsibility: One reason to change per class.
- Open/Closed: Extend, don’t modify.
- Liskov Substitution: Respect abstractions.
- Interface Segregation: Small interfaces.
- Dependency Inversion: Depend on abstractions.

BLOC RULES
- Bloc events = user intent or system events.
- Bloc states must be explicit.
- Avoid boolean explosion in states.
- No business logic in widgets.

AUTH FEATURE RULES (CRITICAL)
- FirebaseAuth ONLY in auth_remote_data_source.
- AuthBloc must depend on UseCases only.
- Login & Signup must reuse shared widgets.
- Avoid duplicated validation logic.

REFACTORING RULES
- Before refactor:
  - Analyze existing code
  - Identify duplication
  - Identify responsibility leaks
- Refactor incrementally.
- Never break working functionality.
- Prefer extraction over rewriting.

WHEN ADDING A NEW FEATURE
- Inspect:
  - core/
  - routing/
  - injection_container.dart
  - existing similar features
- Integrate with existing shared logic.
- DO NOT duplicate functionality already in core.

WHEN REFACTORING
- Check if logic belongs to:
  - core/
  - shared widgets
  - existing usecases
- Extract common logic into core if reused across features.

FINAL RULE
- Assume this project is long-lived and production-grade.
- Maintain scalability, testability, and readability at all times.
