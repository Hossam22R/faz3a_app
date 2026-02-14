# NEMA-STORE-2025-001 - Part 6 Progress

This iteration focuses on route-parameterized navigation and product flow data wiring.

## Added in this iteration

1. **Dynamic route parameters**
   - Replaced static detail routes with parameterized routes:
     - `/categories/:categoryId/products`
     - `/product/:productId`
     - `/product/:productId/reviews`
     - `/orders/:orderId`
     - `/orders/:orderId/tracking`
   - Added route location helpers in `AppRoutes` for safe path generation.

2. **Router updates**
   - Updated `GoRouter` builders to extract and pass path parameters.
   - Category route now supports optional query parameter for display name.

3. **Product data flow expansion**
   - Extended `ProductRepository` and Firebase implementation:
     - `getProductsByCategory(categoryId)`
   - Extended `ProductProvider`:
     - `categoryProducts`
     - `selectedProduct`
     - `loadProductsByCategory`
     - `loadProductDetails`
   - Added stronger loading/error state behavior for category/details fetches.

4. **Screen migrations from static demo routing**
   - `CategoryProductsScreen` now:
     - accepts `categoryId` + optional `categoryName`
     - loads products via provider/repository
   - `ProductDetailsScreen` now:
     - accepts `productId`
     - loads product details via provider/repository
     - routes to product reviews using product-specific path
   - `ProductReviewsScreen` now:
     - accepts `productId`
     - loads reviews for the specific product
   - `OrdersScreen` now navigates with order-specific detail paths.
   - `OrderDetailsScreen` and `OrderTrackingScreen` now accept and display `orderId`.

## Notes

- This phase removes hardcoded navigation for core commerce flows and enables true deep-link-ready paths for category/product/order details.
- Remaining placeholders can now adopt the same route-param + provider pattern incrementally.
