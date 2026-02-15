import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/services/auth_session.dart';
import '../../data/models/user_model.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/analytics_screen.dart';
import '../../presentation/screens/admin/categories_management_screen.dart';
import '../../presentation/screens/admin/finances_screen.dart';
import '../../presentation/screens/admin/orders_management_screen.dart';
import '../../presentation/screens/admin/products_approval_screen.dart';
import '../../presentation/screens/admin/vendors_management_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/categories/categories_screen.dart';
import '../../presentation/screens/categories/category_products_screen.dart';
import '../../presentation/screens/checkout/checkout_screen.dart';
import '../../presentation/screens/checkout/order_success_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/orders/order_details_screen.dart';
import '../../presentation/screens/orders/order_tracking_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/product/product_details_screen.dart';
import '../../presentation/screens/product/product_reviews_screen.dart';
import '../../presentation/screens/profile/add_address_screen.dart';
import '../../presentation/screens/profile/addresses_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/settings_screen.dart';
import '../../presentation/screens/profile/wishlist_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/vendor/add_product_screen.dart';
import '../../presentation/screens/vendor/edit_product_screen.dart';
import '../../presentation/screens/vendor/vendor_ads_screen.dart';
import '../../presentation/screens/vendor/vendor_analytics_screen.dart';
import '../../presentation/screens/vendor/vendor_dashboard_screen.dart';
import '../../presentation/screens/vendor/vendor_finances_screen.dart';
import '../../presentation/screens/vendor/vendor_order_details_screen.dart';
import '../../presentation/screens/vendor/vendor_orders_screen.dart';
import '../../presentation/screens/vendor/vendor_products_screen.dart';

class AppRouter {
  AppRouter._();

  static const Set<String> _publicRoutes = <String>{
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.onboarding,
  };

  static GoRouter createRouter(AuthSession authSession) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: authSession,
      redirect: (context, state) {
        final String location = state.matchedLocation;
        final bool isSplash = location == AppRoutes.splash;
        final bool isPublic = _publicRoutes.contains(location);

        if (!authSession.isReady) {
          return isSplash ? null : AppRoutes.splash;
        }

        if (authSession.isLoggedIn) {
          final String path = location;
          final UserType? userType = authSession.currentUser?.userType;
          final bool wantsAdmin = path.startsWith('/admin');
          final bool wantsVendor = path.startsWith('/vendor');

          if (wantsAdmin && userType != null && userType != UserType.admin) {
            return AppRoutes.home;
          }
          if (wantsVendor &&
              userType != null &&
              userType != UserType.vendor &&
              userType != UserType.admin) {
            return AppRoutes.home;
          }

          if (isSplash || isPublic) {
            return AppRoutes.home;
          }
          return null;
        }

        if (isSplash) {
          return AppRoutes.login;
        }
        if (!isPublic) {
          return AppRoutes.login;
        }
        return null;
      },
      routes: <GoRoute>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.categoryProducts,
        builder: (context, state) => CategoryProductsScreen(
          categoryId: state.pathParameters['categoryId'] ?? '',
          categoryName: state.uri.queryParameters['name'],
        ),
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        builder: (context, state) => ProductDetailsScreen(
          productId: state.pathParameters['productId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.productReviews,
        builder: (context, state) => ProductReviewsScreen(
          productId: state.pathParameters['productId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        builder: (context, state) => OrderSuccessScreen(
          orderId: state.uri.queryParameters['orderId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderDetails,
        builder: (context, state) => OrderDetailsScreen(
          orderId: state.pathParameters['orderId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.orderTracking,
        builder: (context, state) => OrderTrackingScreen(
          orderId: state.pathParameters['orderId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.addresses,
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: AppRoutes.addAddress,
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: AppRoutes.wishlist,
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorDashboard,
        builder: (context, state) => const VendorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorProducts,
        builder: (context, state) => const VendorProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addProduct,
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProduct,
        builder: (context, state) => EditProductScreen(
          productId: state.pathParameters['productId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.vendorOrders,
        builder: (context, state) => const VendorOrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorOrderDetails,
        builder: (context, state) => VendorOrderDetailsScreen(
          orderId: state.pathParameters['orderId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.vendorFinances,
        builder: (context, state) => const VendorFinancesScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorAds,
        builder: (context, state) => const VendorAdsScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorAnalytics,
        builder: (context, state) => const VendorAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorsManagement,
        builder: (context, state) => const VendorsManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.productsApproval,
        builder: (context, state) => const ProductsApprovalScreen(),
      ),
      GoRoute(
        path: AppRoutes.ordersManagement,
        builder: (context, state) => const OrdersManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.categoriesManagement,
        builder: (context, state) => const CategoriesManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.finances,
        builder: (context, state) => const FinancesScreen(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      ],
    );
  }
}
