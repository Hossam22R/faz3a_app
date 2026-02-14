# Nema Store - Technical Foundation (Phases 1-2)

This repository now contains the initial implementation baseline for **Nema Store**, following the submitted architecture report.

## What is implemented

- App bootstrap:
  - `lib/main.dart`
  - `lib/app.dart`
- Core design system:
  - `core/constants` (colors, strings, assets, routes, API constants)
  - `core/theme` (app theme + typography tokens)
- Routing and app composition:
  - `config/routes/app_router.dart`
  - `config/dependency_injection/injection_container.dart`
- Presentation layer scaffolding:
  - Core screens: Splash, Login, Home
  - Auth: Register, Forgot Password
  - Customer flow modules: Categories, Product, Cart, Checkout, Orders, Profile, Search
  - Vendor modules: Dashboard, Products, Orders, Finances, Ads, Analytics
  - Admin modules: Dashboard, Vendors, Product Approval, Orders, Categories, Finances, Analytics
  - Shared widget library:
    - Buttons (`primary`, `secondary`, `icon`, `add_to_cart`)
    - Cards (`product`, `category`, `order`, `vendor`)
    - Inputs (`custom_text_field`, `search_bar`, `dropdown`, `image_picker`)
    - Common (`custom_app_bar`, `loading`, `empty/error states`, `rating`, `badge`, `shimmer`)
    - Dialogs (`confirmation`, `info`, `loading`)
  - Base providers:
    - `theme`, `auth`, `product`, `cart`, `order`, `vendor`
    - `category`, `address`, `review`
- Data layer foundation:
  - Enhanced `UserModel`
  - `ProductModel`
  - `CategoryModel`
  - `AddressModel`
  - `CartItemModel`
  - `ReviewModel`
  - `AdPackageModel`
  - Upgraded `OrderModel` with status/payment/items support
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

1. Implement concrete repositories against Firestore and Firebase Auth.
2. Replace placeholder screens with real UI widgets and feature logic.
3. Add form validation + state handling for auth, checkout, and vendor product CRUD.
4. Implement admin and vendor analytics data pipelines.
5. Add unit, widget, and integration tests, then wire CI checks.

## Notes

- This is an architecture-first baseline, intentionally lightweight and extensible.
- Platform folders (`android`, `ios`, `web`) are expected to be generated/managed in a full Flutter workspace setup.
