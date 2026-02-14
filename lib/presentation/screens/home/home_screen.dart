import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final List<ProductModel> _fallbackProducts = <ProductModel>[
    ProductModel(
      id: 'fallback-p1',
      vendorId: 'demo-v1',
      name: 'هاتف ذكي',
      description: 'هاتف سريع بمعالج قوي وكاميرا عالية الدقة.',
      categoryId: 'electronics',
      price: 420000,
      discountPrice: 385000,
      stock: 12,
      images: const <String>[],
      rating: 4.7,
      ordersCount: 110,
      createdAt: DateTime(2025, 1, 5),
    ),
    ProductModel(
      id: 'fallback-p2',
      vendorId: 'demo-v1',
      name: 'ماكينة قهوة',
      description: 'تحضير سريع للقهوة مع تحكم في درجة النكهة.',
      categoryId: 'home',
      price: 130000,
      stock: 8,
      images: const <String>[],
      rating: 4.3,
      ordersCount: 64,
      createdAt: DateTime(2025, 2, 3),
    ),
    ProductModel(
      id: 'fallback-p3',
      vendorId: 'demo-v2',
      name: 'حقيبة لابتوب',
      description: 'تصميم عملي مبطن لحماية اللابتوب أثناء النقل.',
      categoryId: 'fashion',
      price: 35000,
      stock: 20,
      images: const <String>[],
      rating: 4.4,
      ordersCount: 49,
      createdAt: DateTime(2025, 1, 20),
    ),
    ProductModel(
      id: 'fallback-p4',
      vendorId: 'demo-v2',
      name: 'سماعات بلوتوث',
      description: 'صوت نقي مع بطارية تدوم طوال اليوم.',
      categoryId: 'electronics',
      price: 45000,
      discountPrice: 39000,
      stock: 18,
      images: const <String>[],
      rating: 4.6,
      ordersCount: 96,
      createdAt: DateTime(2025, 1, 8),
    ),
    ProductModel(
      id: 'fallback-p5',
      vendorId: 'demo-v3',
      name: 'دراجة أطفال',
      description: 'دراجة متينة وآمنة للأطفال بعجلات مساعدة.',
      categoryId: 'kids',
      price: 115000,
      stock: 6,
      images: const <String>[],
      rating: 4.2,
      ordersCount: 31,
      createdAt: DateTime(2025, 2, 9),
    ),
    ProductModel(
      id: 'fallback-p6',
      vendorId: 'demo-v3',
      name: 'كتاب تطوير ذات',
      description: 'كتاب عملي لتنظيم الوقت وتحسين الإنتاجية اليومية.',
      categoryId: 'books',
      price: 18000,
      stock: 24,
      images: const <String>[],
      rating: 4.1,
      ordersCount: 27,
      createdAt: DateTime(2025, 1, 29),
    ),
  ];

  static final List<CategoryModel> _fallbackCategories = <CategoryModel>[
    CategoryModel(
      id: 'electronics',
      name: 'Electronics',
      nameAr: 'إلكترونيات',
      createdAt: DateTime(2025, 1, 1),
    ),
    CategoryModel(
      id: 'fashion',
      name: 'Fashion',
      nameAr: 'أزياء',
      createdAt: DateTime(2025, 1, 1),
    ),
    CategoryModel(
      id: 'home',
      name: 'Home',
      nameAr: 'منزل ومطبخ',
      createdAt: DateTime(2025, 1, 1),
    ),
    CategoryModel(
      id: 'kids',
      name: 'Kids',
      nameAr: 'ألعاب أطفال',
      createdAt: DateTime(2025, 1, 1),
    ),
    CategoryModel(
      id: 'books',
      name: 'Books',
      nameAr: 'كتب وموسوعات',
      createdAt: DateTime(2025, 1, 1),
    ),
    CategoryModel(
      id: 'gifts',
      name: 'Gifts',
      nameAr: 'هدايا وهوايات',
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHomeData());
  }

  Future<void> _loadHomeData() async {
    final ProductProvider productProvider = context.read<ProductProvider>();
    final CategoryProvider categoryProvider = context.read<CategoryProvider>();
    await Future.wait(<Future<void>>[
      productProvider.loadFeaturedProducts(),
      categoryProvider.loadRootCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final UserType? userType = authProvider.currentUser?.userType;
    final String displayName = (authProvider.currentUser?.fullName.trim().isNotEmpty ?? false)
        ? authProvider.currentUser!.fullName
        : 'ضيفنا';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        appBar: AppBar(
          centerTitle: false,
          title: Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_rounded, color: AppColors.primaryDark, size: 18),
              ),
              const SizedBox(width: 8),
              const Text('نعمة ستور', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'المفضلة',
              onPressed: () => context.push(AppRoutes.wishlist),
              icon: const Icon(Icons.favorite_border_rounded),
            ),
            IconButton(
              tooltip: 'السلة',
              onPressed: () => context.push(AppRoutes.cart),
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
          ],
        ),
        body: Consumer2<ProductProvider, CategoryProvider>(
          builder: (context, productProvider, categoryProvider, _) {
            final bool firstLoad = (productProvider.isLoading || categoryProvider.isLoading) &&
                productProvider.featuredProducts.isEmpty &&
                categoryProvider.categories.isEmpty;
            if (firstLoad) {
              return const Center(child: LoadingIndicator());
            }

            final List<ProductModel> products = productProvider.featuredProducts.isNotEmpty
                ? productProvider.featuredProducts
                : _fallbackProducts;
            final List<CategoryModel> categories = categoryProvider.categories.isNotEmpty
                ? categoryProvider.categories
                : _fallbackCategories;

            return RefreshIndicator(
              onRefresh: _loadHomeData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _TopSearchStrip(
                    userName: displayName,
                    onSearchTap: () => context.push(AppRoutes.search),
                    onOrdersTap: () => context.push(AppRoutes.orders),
                  ),
                  const SizedBox(height: 16),
                  _HeroShowcase(
                    onPrimaryTap: () => context.push(AppRoutes.categories),
                    onSecondaryTap: () => context.push(AppRoutes.search),
                  ),
                  const SizedBox(height: 16),
                  const _BenefitCardsRow(),
                  const SizedBox(height: 18),
                  _SectionHeader(
                    title: 'تسوق حسب الفئة',
                    onMoreTap: () => context.push(AppRoutes.categories),
                  ),
                  const SizedBox(height: 16),
                  _CategoryStrip(categories: categories),
                  const SizedBox(height: 18),
                  _SectionHeader(
                    title: 'الأكثر مبيعًا',
                    onMoreTap: () => context.push(AppRoutes.search),
                  ),
                  const SizedBox(height: 16),
                  _BestSellersGrid(
                    products: products,
                    onProductTap: (String productId) => context.push(AppRoutes.productDetailsLocation(productId)),
                  ),
                  const SizedBox(height: 18),
                  const _SubscribeCard(),
                  const SizedBox(height: 18),
                  _RoleQuickActions(userType: userType),
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

class _TopSearchStrip extends StatelessWidget {
  const _TopSearchStrip({
    required this.userName,
    required this.onSearchTap,
    required this.onOrdersTap,
  });

  final String userName;
  final VoidCallback onSearchTap;
  final VoidCallback onOrdersTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'أهلاً $userName',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: <Widget>[
                  Icon(Icons.search_rounded, color: AppColors.primaryGold),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ابحث عن منتجك',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  ),
                  Icon(Icons.tune_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _MiniAction(
                icon: Icons.receipt_long_outlined,
                label: 'طلباتي',
                onTap: onOrdersTap,
              ),
              const SizedBox(width: 8),
              _MiniAction(
                icon: Icons.person_outline_rounded,
                label: 'حسابي',
                onTap: () => context.push(AppRoutes.profile),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 16, color: AppColors.primaryGold),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroShowcase extends StatelessWidget {
  const _HeroShowcase({
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF082042), Color(0xFF0A2D58), Color(0xFF0F3E74)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'تسوق مريح وسريع مع\nتوصيل داخل العراق',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اطلب كل ما تحتاجه من منتجات موثوقة وبأسعار منافسة في دقائق.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPrimaryTap,
                        child: const Text('تسوق الآن'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onSecondaryTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.55)),
                        ),
                        child: const Text('الأكثر مبيعًا'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_shipping_rounded, color: AppColors.primaryDark, size: 40),
          ),
        ],
      ),
    );
  }
}

class _BenefitCardsRow extends StatelessWidget {
  const _BenefitCardsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(
          child: _BenefitCard(
            icon: Icons.local_shipping_outlined,
            title: 'توصيل سريع',
            subtitle: '4-5 أيام داخل العراق',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _BenefitCard(
            icon: Icons.verified_outlined,
            title: 'دفع آمن',
            subtitle: 'خيارات دفع مرنة',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _BenefitCard(
            icon: Icons.inventory_2_outlined,
            title: 'منتجات متنوعة',
            subtitle: 'جودة مضمونة',
          ),
        ),
      ],
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.primaryGold),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onMoreTap,
  });

  final String title;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        TextButton(
          onPressed: onMoreTap,
          child: const Text('عرض الكل'),
        ),
      ],
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
  });

  final List<CategoryModel> categories;

  IconData _iconFor(String key) {
    final String normalized = key.toLowerCase();
    if (normalized.contains('elect') || normalized.contains('إلكتر')) {
      return Icons.devices_other_rounded;
    }
    if (normalized.contains('fashion') || normalized.contains('أزي')) {
      return Icons.checkroom_rounded;
    }
    if (normalized.contains('home') || normalized.contains('منزل') || normalized.contains('مطبخ')) {
      return Icons.kitchen_rounded;
    }
    if (normalized.contains('kids') || normalized.contains('طفل') || normalized.contains('ألعاب')) {
      return Icons.toys_rounded;
    }
    if (normalized.contains('book') || normalized.contains('كتب')) {
      return Icons.menu_book_rounded;
    }
    if (normalized.contains('gift') || normalized.contains('هدايا')) {
      return Icons.card_giftcard_rounded;
    }
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          final CategoryModel category = categories[index];
          final String label = category.nameAr ?? category.name;
          return InkWell(
            onTap: () => context.push(
              AppRoutes.categoryProductsLocation(
                category.id,
                categoryName: label,
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              width: 96,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_iconFor(label), color: AppColors.primaryGold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: categories.length,
      ),
    );
  }
}

class _BestSellersGrid extends StatelessWidget {
  const _BestSellersGrid({
    required this.products,
    required this.onProductTap,
  });

  final List<ProductModel> products;
  final ValueChanged<String> onProductTap;

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> topProducts = products.take(8).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topProducts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (BuildContext context, int index) {
        final ProductModel product = topProducts[index];
        return _BestSellerCard(
          product: product,
          onTap: () => onProductTap(product.id),
        );
      },
    );
  }
}

class _BestSellerCard extends StatelessWidget {
  const _BestSellerCard({
    required this.product,
    required this.onTap,
  });

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: product.images.isEmpty
                      ? const Icon(Icons.image_outlined, size: 34)
                      : Image.network(
                          product.images.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 34),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(
              '${product.finalPrice.toStringAsFixed(0)} IQD',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'تم الطلب ${product.ordersCount} مرة',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscribeCard extends StatelessWidget {
  const _SubscribeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF5A451C), Color(0xFF8D6F2D), Color(0xFFB78F3B)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'اشترك في تنبيهات العروض',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'عروض يومية على منتجات مختارة داخل التطبيق',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.primaryGold,
            ),
            child: const Text('اشترك'),
          ),
        ],
      ),
    );
  }
}

class _RoleQuickActions extends StatelessWidget {
  const _RoleQuickActions({
    required this.userType,
  });

  final UserType? userType;

  @override
  Widget build(BuildContext context) {
    final bool vendorOrAdmin = userType == UserType.vendor || userType == UserType.admin;
    final bool adminOnly = userType == UserType.admin;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _QuickActionChip(
          label: 'طلباتي',
          icon: Icons.list_alt_outlined,
          onTap: () => context.push(AppRoutes.orders),
        ),
        _QuickActionChip(
          label: 'العناوين',
          icon: Icons.location_on_outlined,
          onTap: () => context.push(AppRoutes.addresses),
        ),
        if (vendorOrAdmin)
          _QuickActionChip(
            label: 'لوحة المورد',
            icon: Icons.storefront_outlined,
            onTap: () => context.push(AppRoutes.vendorDashboard),
          ),
        if (adminOnly)
          _QuickActionChip(
            label: 'لوحة الإدارة',
            icon: Icons.admin_panel_settings_outlined,
            onTap: () => context.push(AppRoutes.adminDashboard),
          ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: AppColors.cardBackground,
      side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.22)),
      avatar: Icon(icon, size: 16, color: AppColors.primaryGold),
      label: Text(label),
    );
  }
}
