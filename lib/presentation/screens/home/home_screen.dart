import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/theme_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ProductProvider productProvider = context.read<ProductProvider>();
      if (!productProvider.isLoading && productProvider.featuredProducts.isEmpty) {
        productProvider.loadFeaturedProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final AuthProvider authProvider = context.watch<AuthProvider>();

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
              tooltip: 'تسجيل الخروج',
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    },
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const _HeroBanner(),
            const SizedBox(height: 16),
            const SearchBarCustom(),
            const SizedBox(height: 16),
            const _QuickStats(),
            const SizedBox(height: 16),
            const _FeaturedPreview(),
            const SizedBox(height: 16),
            const _QuickModules(),
            const SizedBox(height: 16),
            const _ImplementationNoteCard(),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColors.blueGradient,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('نعمة ستور', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text(
            'كل شي بالبيت بضغطة زر',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(
          child: _StatCard(
            title: 'العمولة',
            value: '10%',
            icon: Icons.percent_rounded,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'التوصيل',
            value: '4-5 أيام',
            icon: Icons.local_shipping_outlined,
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

class _ImplementationNoteCard extends StatelessWidget {
  const _ImplementationNoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Foundation includes phases 1-4 with Firebase wiring, auth flow, and guarded routes.',
      ),
    );
  }
}

class _FeaturedPreview extends StatelessWidget {
  const _FeaturedPreview();

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
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final List<ProductModel> products = productProvider.featuredProducts.isNotEmpty
            ? productProvider.featuredProducts
            : _fallbackProducts;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'منتجات مميزة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (productProvider.isLoading)
              const SizedBox(
                height: 60,
                child: Center(child: LoadingIndicator()),
              )
            else
              SizedBox(
                height: 290,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final ProductModel product = products[index];
                    return SizedBox(
                      width: 240,
                      child: ProductCard(
                        product: product,
                        onTap: () => context.push(AppRoutes.productDetailsLocation(product.id)),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: products.length,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _QuickModules extends StatelessWidget {
  const _QuickModules();

  @override
  Widget build(BuildContext context) {
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
                title: 'لوحة المورد',
                icon: Icons.storefront_outlined,
                onTap: () => context.push(AppRoutes.vendorDashboard),
              ),
            ),
          ],
        ),
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
