class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String categories = '/categories';
  static const String categoryProducts = '/categories/products';
  static const String productDetails = '/product/details';
  static const String productReviews = '/product/reviews';
  static const String search = '/search';

  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/checkout/success';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/details';
  static const String orderTracking = '/orders/tracking';

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
}
