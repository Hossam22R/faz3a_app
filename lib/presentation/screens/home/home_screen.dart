import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/cards/order_card.dart';
import '../../widgets/cards/product_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/inputs/search_bar_custom.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHomeData());
  }

  Future<void> _loadHomeData() async {
    final ProductProvider productProvider = context.read<ProductProvider>();
    final CategoryProvider categoryProvider = context.read<CategoryProvider>();
    final OrderProvider orderProvider = context.read<OrderProvider>();
    final String? userId = context.read<AuthProvider>().currentUser?.id;

    final List<Future<void>> tasks = <Future<void>>[
      productProvider.loadFeaturedProducts(),
      categoryProvider.loadRootCategories(),
    ];
    if (userId != null && userId.isNotEmpty) {
      tasks.add(orderProvider.loadOrders(userId));
    }
    await Future.wait(tasks);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final UserType? userType = authProvider.currentUser?.userType;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.homeTitle),
          actions: <Widget>[
            IconButton(
              tooltip: 'تبديل الثيم',
              onPressed: themeProvider.toggleTheme,
              icon: Icon(themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            ),
            IconButton(
              tooltip: 'الملف الشخصي',
              onPressed: () => context.push(AppRoutes.profile),
              icon: const Icon(Icons.person_outline_rounded),
            ),
          ],
        ),
        body: Consumer3<ProductProvider, CategoryProvider, OrderProvider>(
          builder: (context, productProvider, categoryProvider, orderProvider, _) {
            final bool firstLoad = (productProvider.isLoading ||
                    categoryProvider.isLoading ||
                    orderProvider.isLoading) &&
                productProvider.featuredProducts.isEmpty &&
                categoryProvider.categories.isEmpty &&
                orderProvider.orders.isEmpty;
            if (firstLoad) {
              return const Center(child: LoadingIndicator());
            }

            return RefreshIndicator(
              onRefresh: _loadHomeData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _HeroBanner(userName: authProvider.currentUser?.fullName),
                  const SizedBox(height: 16),
                  _SearchEntry(onTap: () => context.push(AppRoutes.search)),
                  const SizedBox(height: 16),
                  _OverviewStats(
                    categoriesCount: categoryProvider.categories.length,
                    featuredProductsCount: productProvider.featuredProducts.length,
                    myOrdersCount: orderProvider.orders.length,
                  ),
                  const SizedBox(height: 16),
                  _CategoriesPreview(
                    categories: categoryProvider.categories,
                    isLoading: categoryProvider.isLoading,
                    errorMessage: categoryProvider.errorMessage,
                  ),
                  const SizedBox(height: 16),
                  _FeaturedPreview(
                    products: productProvider.featuredProducts,
                    isLoading: productProvider.isLoading,
                    errorMessage: productProvider.errorMessage,
                  ),
                  const SizedBox(height: 16),
                  _RecentOrdersPreview(
                    orders: orderProvider.orders,
                    isLoading: orderProvider.isLoading,
                    errorMessage: orderProvider.errorMessage,
                  ),
                  const SizedBox(height: 16),
                  _QuickModules(userType: userType),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context) {
    final String greetingName = (userName == null || userName!.trim().isEmpty) ? 'ضيفنا' : userName!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColors.blueGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('أهلاً $greetingName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('نعمة ستور', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'كل شي بالبيت بضغطة زر',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SearchEntry extends StatelessWidget {
  const _SearchEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: IgnorePointer(
        child: SearchBarCustom(
          hintText: 'ابحث في المعرض...',
        ),
      ),
    );
  }
}

class _OverviewStats extends StatelessWidget {
  const _OverviewStats({
    required this.categoriesCount,
    required this.featuredProductsCount,
    required this.myOrdersCount,
  });

  final int categoriesCount;
  final int featuredProductsCount;
  final int myOrdersCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        SizedBox(
          width: 160,
          child: _StatCard(
            title: 'التصنيفات',
            value: '$categoriesCount',
            icon: Icons.category_outlined,
          ),
        ),
        SizedBox(
          width: 160,
          child: _StatCard(
            title: 'المنتجات المميزة',
            value: '$featuredProductsCount',
            icon: Icons.star_border_rounded,
          ),
        ),
        SizedBox(
          width: 160,
          child: _StatCard(
            title: 'طلباتي',
            value: '$myOrdersCount',
            icon: Icons.receipt_long_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.primaryGold),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CategoriesPreview extends StatelessWidget {
  const _CategoriesPreview({
    required this.categories,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<CategoryModel> categories;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading && categories.isEmpty) {
      return const SizedBox(
        height: 90,
        child: Center(child: LoadingIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text(
              'المعرض',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push(AppRoutes.categories),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        if (errorMessage != null && categories.isEmpty)
          Card(
            child: ListTile(
              title: const Text('تعذر تحميل التصنيفات'),
              subtitle: Text(errorMessage!),
            ),
          )
        else if (categories.isEmpty)
          const Card(
            child: ListTile(
              title: Text('لا توجد تصنيفات متاحة حالياً'),
            ),
          )
        else
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                final CategoryModel category = categories[index];
                return ActionChip(
                  label: Text(category.nameAr ?? category.name),
                  onPressed: () => context.push(
                    AppRoutes.categoryProductsLocation(
                      category.id,
                      categoryName: category.nameAr ?? category.name,
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: categories.length,
            ),
          ),
      ],
    );
  }
}

class _FeaturedPreview extends StatelessWidget {
  const _FeaturedPreview({
    required this.products,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<ProductModel> products;
  final bool isLoading;
  final String? errorMessage;

  static final List<ProductModel> _fallbackProducts = <ProductModel>[
    ProductModel(
      id: 'demo-p1',
      vendorId: 'demo-v1',
      name: 'سماعات لاسلكية',
      description: 'منتج تجريبي لعرض بنية الواجهة',
      categoryId: 'electronics',
      price: 45000,
      discountPrice: 39000,
      stock: 15,
      images: <String>[],
      createdAt: DateTime(2025, 1, 1),
    ),
    ProductModel(
      id: 'demo-p2',
      vendorId: 'demo-v2',
      name: 'خلاط مطبخ',
      description: 'منتج تجريبي لعرض بنية الواجهة',
      categoryId: 'home',
      price: 62000,
      stock: 8,
      images: <String>[],
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> resolved = products.isNotEmpty ? products : _fallbackProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text(
              'منتجات مميزة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push(AppRoutes.search),
              child: const Text('بحث متقدم'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (isLoading)
          const SizedBox(
            height: 60,
            child: Center(child: LoadingIndicator()),
          )
        else ...<Widget>[
          if (errorMessage != null && products.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  title: const Text('تعذر تحميل المنتجات من الخادم'),
                  subtitle: Text(errorMessage!),
                ),
              ),
            ),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final ProductModel product = resolved[index];
                return SizedBox(
                  width: 240,
                  child: ProductCard(
                    product: product,
                    onTap: () => context.push(AppRoutes.productDetailsLocation(product.id)),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: resolved.length,
            ),
          ),
        ],
      ],
    );
  }
}

class _RecentOrdersPreview extends StatelessWidget {
  const _RecentOrdersPreview({
    required this.orders,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<OrderModel> orders;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final List<OrderModel> recent = orders.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text(
              'آخر الطلبات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push(AppRoutes.orders),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        if (isLoading && orders.isEmpty)
          const SizedBox(
            height: 70,
            child: Center(child: LoadingIndicator()),
          )
        else if (errorMessage != null && orders.isEmpty)
          Card(
            child: ListTile(
              title: const Text('تعذر تحميل الطلبات'),
              subtitle: Text(errorMessage!),
            ),
          )
        else if (recent.isEmpty)
          const Card(
            child: ListTile(
              title: Text('لا توجد طلبات حالياً'),
              subtitle: Text('ابدأ التسوق وسيظهر سجل الطلبات هنا.'),
            ),
          )
        else
          ...recent.map(
            (OrderModel order) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OrderCard(
                order: order,
                onTap: () => context.push(AppRoutes.orderDetailsLocation(order.id)),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickModules extends StatelessWidget {
  const _QuickModules({
    required this.userType,
  });

  final UserType? userType;

  @override
  Widget build(BuildContext context) {
    final bool canOpenVendor = userType == UserType.vendor || userType == UserType.admin;
    final bool canOpenAdmin = userType == UserType.admin;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _ModuleButton(
                title: 'التصنيفات',
                icon: Icons.category_outlined,
                onTap: () => context.push(AppRoutes.categories),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModuleButton(
                title: 'السلة',
                icon: Icons.shopping_cart_outlined,
                onTap: () => context.push(AppRoutes.cart),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _ModuleButton(
                title: 'طلباتي',
                icon: Icons.list_alt_outlined,
                onTap: () => context.push(AppRoutes.orders),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModuleButton(
                title: 'الملف الشخصي',
                icon: Icons.person_outline_rounded,
                onTap: () => context.push(AppRoutes.profile),
              ),
            ),
          ],
        ),
        if (canOpenVendor) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _ModuleButton(
                  title: 'لوحة المورد',
                  icon: Icons.storefront_outlined,
                  onTap: () => context.push(AppRoutes.vendorDashboard),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModuleButton(
                  title: 'طلبات المورد',
                  icon: Icons.assignment_outlined,
                  onTap: () => context.push(AppRoutes.vendorOrders),
                ),
              ),
            ],
          ),
        ],
        if (canOpenAdmin) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _ModuleButton(
                  title: 'لوحة الإدارة',
                  icon: Icons.admin_panel_settings_outlined,
                  onTap: () => context.push(AppRoutes.adminDashboard),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModuleButton(
                  title: 'موافقة المنتجات',
                  icon: Icons.fact_check_outlined,
                  onTap: () => context.push(AppRoutes.productsApproval),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ModuleButton extends StatelessWidget {
  const _ModuleButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: AppColors.primaryGold),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
            const Icon(Icons.chevron_left_rounded),
          ],
        ),
      ),
    );
  }
}
