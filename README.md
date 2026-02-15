# Nema Store - Technical Foundation (Phases 1-21)

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
  - dynamic route params for category/product/order flows
- Presentation layer scaffolding:
  - Core screens: Splash, Login, Home
  - Auth: Register, Forgot Password
  - Customer flow modules: Categories, Product, Cart, Checkout, Orders, Profile, Search
  - Vendor modules: Dashboard, Products, Orders, Finances, Ads, Analytics
  - Admin modules: Dashboard, Vendors, Product Approval, Orders, Categories, Finances, Analytics
  - Provider-backed screens now active:
    - Home featured products
    - Categories list
    - Category products grid (by `categoryId`)
    - Product details (by `productId`)
    - Cart management (repository-backed quantity/remove)
    - Checkout flow (address + payment + order creation)
    - Order success screen with details navigation
    - Orders list
    - Order details + tracking (by `orderId`)
    - Product reviews list (by `productId`)
    - Vendor product management:
      - vendor product list
      - add product form
      - edit product form (by `productId`)
    - Admin moderation flows:
      - vendors management (approve/suspend)
      - products approval (approve/reject pending products)
    - Analytics and admin overview:
      - vendor analytics screen (operational KPIs)
      - admin analytics screen (platform moderation KPIs)
      - admin dashboard quick actions
    - Operational orders management:
      - vendor orders list
      - vendor order details + status actions
      - admin orders management + status actions
    - Profile and account management:
      - profile overview screen
      - edit profile form (persisted via repository)
      - addresses list + add address form
      - wishlist screen
      - settings screen (theme + reset password + logout)
    - Additional operational modules:
      - onboarding experience (multi-step)
      - search screen (query filter on available products)
      - vendor ads management (assign ad packages to products)
      - vendor finances dashboard
      - admin finances dashboard
      - admin categories management list
    - UX completion pass for core flows:
      - home marketplace hub (categories + featured + recent orders + refresh)
      - orders page with status filters and KPI summary
      - vendor dashboard with live stats and quick actions
      - localized order status chips across order cards
      - product details with quantity controls and related products
      - search with category filters and sort options
      - admin dashboard with live KPIs and operational alerts
      - visual redesign of home opening experience to match premium dark/gold storefront style
        (hero banner, feature cards, category strip, best-sellers grid, subscription callout)
      - premium style consistency pass for:
        - categories page
        - category products listing
        - cart page
  - Shared widget library:
    - Buttons (`primary`, `secondary`, `icon`, `add_to_cart`)
    - Cards (`product`, `category`, `order`, `vendor`)
    - Inputs (`custom_text_field`, `search_bar`, `dropdown`, `image_picker`)
    - Common (`custom_app_bar`, `loading`, `empty/error states`, `rating`, `badge`, `shimmer`)
    - Dialogs (`confirmation`, `info`, `loading`)
  - Base providers:
    - `theme`, `auth`, `product`, `cart`, `order`, `vendor`
    - `category`, `address`, `review`
  - Unit tests:
    - `test/unit_tests/cart_provider_test.dart`
    - `test/unit_tests/product_provider_admin_test.dart`
    - `test/unit_tests/vendor_provider_test.dart`
    - `test/unit_tests/order_provider_management_test.dart`
    - `test/unit_tests/auth_provider_profile_test.dart`
  - Widget tests:
    - `test/widget_tests/badge_widget_test.dart`
  - Integration tests:
    - `integration_test/app_smoke_test.dart`
- Data layer foundation:
  - Enhanced `UserModel`
  - `ProductModel`
  - `CategoryModel`
  - `AddressModel`
  - `CartItemModel`
  - `ReviewModel`
  - `AdPackageModel`
  - Upgraded `OrderModel` with status/payment/items support
  - Firebase-backed repository implementations for:
    - auth
    - products
    - categories
    - orders
    - addresses
    - reviews
    - cart
    - vendors
    - payment status writes
  - Remote data source helpers for collection access
  - Offline demo fallback store when Firebase is unavailable
- Domain layer skeleton:
  - Base entity/repository/use-case contracts
- CI:
  - `.github/workflows/flutter_ci.yml` to run analyze + unit/widget/integration tests

## Architecture direction

The project follows:

- **Clean Architecture**
- **MVVM-style state management** using `Provider`
- **GoRouter** for navigation
- **Firebase-first backend integration** strategy

## Next implementation steps

1. Harden role-based route policies and deep-link safeguards.
2. Add deeper coverage for auth/cart/checkout integration scenarios.
3. Add audit trails for moderation and order status transitions.
4. Complete production Firebase setup and environment-specific configs.

## Notes

- This is an architecture-first baseline, intentionally lightweight and extensible.
- Platform folders (`android`, `ios`, `web`) are expected to be generated/managed in a full Flutter workspace setup.
