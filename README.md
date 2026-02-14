# Nema Store - Technical Foundation (Phase 1)

This repository now contains the initial implementation baseline for **Nema Store**, following the submitted architecture report.

## What is implemented in this phase

- App bootstrap:
  - `lib/main.dart`
  - `lib/app.dart`
- Core design system:
  - `core/constants` (colors, strings, assets, routes, API constants)
  - `core/theme` (app theme + typography tokens)
- Routing and app composition:
  - `config/routes/app_router.dart`
  - `config/dependency_injection/injection_container.dart`
- Initial presentation layer:
  - Splash screen
  - Login screen
  - Home screen
  - Base providers (`theme`, `auth`, `product`, `cart`, `order`, `vendor`)
- Data layer foundation:
  - Enhanced `UserModel`
  - New `ProductModel`
  - Repository contracts
  - Remote/local data source skeletons
- Domain layer skeleton:
  - Base entity/repository/use-case contracts

## Architecture direction

The project follows:

- **Clean Architecture**
- **MVVM-style state management** using `Provider`
- **GoRouter** for navigation
- **Firebase-first backend integration** strategy

## Next implementation steps

1. Complete remaining models (`Category`, `Address`, `Review`, `AdPackage`, etc.)
2. Build authentication and onboarding flows.
3. Implement repositories against Firestore and Firebase Auth.
4. Add vendor dashboard modules.
5. Add admin panel modules (Flutter web).
6. Add unit, widget, and integration tests.

## Notes

- This is an architecture-first baseline, intentionally lightweight and extensible.
- Platform folders (`android`, `ios`, `web`) are expected to be generated/managed in a full Flutter workspace setup.
