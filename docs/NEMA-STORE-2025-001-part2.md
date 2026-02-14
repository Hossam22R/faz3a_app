# NEMA-STORE-2025-001 - Part 2 Progress

This document extends the baseline established in Part 1.

## Added in this iteration

1. **Marketplace data models**
   - `CategoryModel`
   - `AddressModel`
   - `CartItemModel`
   - `ReviewModel`
   - `AdPackageModel`
   - `OrderModel` upgraded to support:
     - order status lifecycle
     - payment methods
     - order items list
     - commission calculations
     - backward compatibility for legacy order payloads

2. **Repository contracts**
   - `CategoryRepository`
   - `AddressRepository`
   - `CartRepository`
   - `ReviewRepository`

3. **Provider scaffolding**
   - `CategoryProvider`
   - `AddressProvider`
   - `ReviewProvider`

4. **Presentation module scaffolding**
   - Auth + Onboarding screens
   - Customer flow screens
   - Vendor dashboard screens
   - Admin panel screens
   - Shared `ModulePlaceholderScreen` for consistent stubs

5. **Routing expansion**
   - Added full route constants and GoRouter entries for customer, vendor, and admin modules.

6. **Tests**
   - Added model-focused unit tests for category and order compatibility paths.

## Deferred to next iteration

1. Concrete Firebase data-source implementations per repository.
2. Real feature UI (forms/lists/cards) replacing placeholders.
3. Role-based access/guards for routes.
4. End-to-end checkout and order lifecycle integration.
