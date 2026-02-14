class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String categories = '/categories';
  static const String categoryProducts = '/categories/:categoryId/products';
  static const String productDetails = '/product/:productId';
  static const String productReviews = '/product/:productId/reviews';
  static const String search = '/search';

  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/checkout/success';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:orderId';
  static const String orderTracking = '/orders/:orderId/tracking';

  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String addresses = '/profile/addresses';
  static const String addAddress = '/profile/addresses/add';
  static const String wishlist = '/profile/wishlist';
  static const String settings = '/profile/settings';

  static const String vendorDashboard = '/vendor/dashboard';
  static const String vendorProducts = '/vendor/products';
  static const String addProduct = '/vendor/products/add';
  static const String editProduct = '/vendor/products/edit';
  static const String vendorOrders = '/vendor/orders';
  static const String vendorOrderDetails = '/vendor/orders/details';
  static const String vendorFinances = '/vendor/finances';
  static const String vendorAds = '/vendor/ads';
  static const String vendorAnalytics = '/vendor/analytics';

  static const String adminDashboard = '/admin/dashboard';
  static const String vendorsManagement = '/admin/vendors';
  static const String productsApproval = '/admin/products-approval';
  static const String ordersManagement = '/admin/orders';
  static const String categoriesManagement = '/admin/categories';
  static const String finances = '/admin/finances';
  static const String analytics = '/admin/analytics';

  static String categoryProductsLocation(
    String categoryId, {
    String? categoryName,
  }) {
    final String encodedCategoryId = Uri.encodeComponent(categoryId);
    final Uri uri = Uri(
      path: '/categories/$encodedCategoryId/products',
      queryParameters: categoryName == null ? null : <String, String>{'name': categoryName},
    );
    return uri.toString();
  }

  static String productDetailsLocation(String productId) {
    return '/product/${Uri.encodeComponent(productId)}';
  }

  static String productReviewsLocation(String productId) {
    return '/product/${Uri.encodeComponent(productId)}/reviews';
  }

  static String orderDetailsLocation(String orderId) {
    return '/orders/${Uri.encodeComponent(orderId)}';
  }

  static String orderTrackingLocation(String orderId) {
    return '/orders/${Uri.encodeComponent(orderId)}/tracking';
  }

  static String orderSuccessLocation(String orderId) {
    return Uri(
      path: orderSuccess,
      queryParameters: <String, String>{'orderId': orderId},
    ).toString();
  }
}
