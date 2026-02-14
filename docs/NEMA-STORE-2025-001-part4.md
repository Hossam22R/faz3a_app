# NEMA-STORE-2025-001 - Part 4 Progress

This iteration introduces Firebase wiring and authentication plumbing.

## Added in this iteration

1. **Dependency container wiring**
   - Added `AppDependencies` static container.
   - `setupDependencies()` now registers data source, repositories, and auth session.

2. **Firebase repository implementations**
   - `FirebaseAuthRepository`
   - `FirebaseProductRepository`
   - `FirebaseCategoryRepository`
   - `FirebaseOrderRepository`
   - `FirebaseVendorRepository`
   - `FirebaseAddressRepository`
   - `FirebaseReviewRepository`
   - `FirebaseCartRepository`
   - `FirebasePaymentRepository`

3. **Auth session + app-level providers**
   - Added `AuthSession` (`ChangeNotifier`) based on auth stream.
   - `NemaStoreApp` now uses `MultiProvider` for auth/domain providers.

4. **Route guards**
   - Router now redirects based on:
     - auth readiness
     - authenticated vs unauthenticated state
     - role checks for `/admin/*` and `/vendor/*` routes.

5. **Auth flow screens**
   - Login screen now performs actual repository-backed sign-in.
   - Register screen now performs repository-backed account creation.
   - Forgot password screen now triggers Firebase reset email.

6. **Firebase bootstrap**
   - App startup attempts `Firebase.initializeApp()`.
   - Repositories gracefully guard usage when Firebase is not configured.

## Notes

- This phase establishes backend wiring and route protection foundation.
- Advanced role policy, claims-based authorization, and deep-link guards are left for follow-up iterations.
