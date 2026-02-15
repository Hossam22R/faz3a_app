import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/models/cart_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<void> _loadCart() async {
    final String? userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null && userId.isNotEmpty) {
      await context.read<CartProvider>().loadCart(userId);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCart());
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = context.read<AuthProvider>().currentUser?.id;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        appBar: AppBar(
          title: const Text('السلة'),
          actions: <Widget>[
            IconButton(
              tooltip: 'متابعة التسوق',
              onPressed: () => context.push(AppRoutes.home),
              icon: const Icon(Icons.storefront_outlined),
            ),
          ],
        ),
        body: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            if (cartProvider.isLoading && cartProvider.items.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (cartProvider.errorMessage != null && cartProvider.items.isEmpty) {
              return AppErrorWidget(
                message: cartProvider.errorMessage!,
                onRetry: _loadCart,
              );
            }
            if (cartProvider.items.isEmpty) {
              return _EmptyCartView(
                onContinueShopping: () => context.push(AppRoutes.categories),
              );
            }

            return Column(
              children: <Widget>[
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadCart,
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final double horizontalPadding = constraints.maxWidth > 700
                            ? (constraints.maxWidth - 700) / 2
                            : 16;
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 12),
                          children: <Widget>[
                            _CartSummaryCard(
                              totalItems: cartProvider.totalItems,
                              subtotal: cartProvider.subtotal,
                            ),
                            const SizedBox(height: 10),
                            ...cartProvider.items.map(
                              (CartItemModel item) {
                                final bool canDecrease = userId != null && !cartProvider.isLoading;
                                final bool canIncrease =
                                    userId != null &&
                                        !cartProvider.isLoading &&
                                        (item.maxQuantity == null || item.quantity < item.maxQuantity!);
                                final bool canRemove = userId != null && !cartProvider.isLoading;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _CartItemTile(
                                    item: item,
                                    onRemove: canRemove
                                        ? () => cartProvider.removeItem(userId: userId!, itemId: item.id)
                                        : null,
                                    onDecrease: canDecrease
                                        ? () => cartProvider.updateQuantity(
                                              userId: userId!,
                                              itemId: item.id,
                                              quantity: item.quantity - 1,
                                            )
                                        : null,
                                    onIncrease: canIncrease
                                        ? () => cartProvider.updateQuantity(
                                              userId: userId!,
                                              itemId: item.id,
                                              quantity: item.quantity + 1,
                                            )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                _CartFooter(
                  totalItems: cartProvider.totalItems,
                  subtotal: cartProvider.subtotal,
                  isLoading: cartProvider.isLoading,
                  onCheckout: () => context.push(AppRoutes.checkout),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView({
    required this.onContinueShopping,
  });

  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Expanded(
          child: EmptyState(
            title: 'السلة فارغة',
            subtitle: 'أضف منتجات للمتابعة إلى إتمام الطلب.',
            icon: Icons.shopping_cart_outlined,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onContinueShopping,
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('متابعة التسوق'),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  const _CartSummaryCard({
    required this.totalItems,
    required this.subtotal,
  });

  final int totalItems;
  final double subtotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('عدد المنتجات: $totalItems', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  'المجموع الحالي: ${subtotal.toStringAsFixed(0)} IQD',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onRemove,
    required this.onDecrease,
    required this.onIncrease,
  });

  final CartItemModel item;
  final VoidCallback? onRemove;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 64,
              height: 64,
              color: Colors.black12,
              alignment: Alignment.center,
              child: item.productImage == null || item.productImage!.trim().isEmpty
                  ? const Icon(Icons.image_outlined)
                  : Image.network(
                      item.productImage!,
                      fit: BoxFit.cover,
                      width: 64,
                      height: 64,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.productName.isEmpty ? item.productId : item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'سعر القطعة: ${item.unitPrice.toStringAsFixed(0)} IQD',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                if (item.maxQuantity != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    'المتوفر: ${item.maxQuantity}',
                    style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    _QtyButton(icon: Icons.remove, onTap: onDecrease),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    _QtyButton(icon: Icons.add, onTap: onIncrease),
                    const Spacer(),
                    Text(
                      '${item.totalPrice.toStringAsFixed(0)} IQD',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded),
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 14, color: AppColors.primaryGold),
      ),
    );
  }
}

class _CartFooter extends StatelessWidget {
  const _CartFooter({
    required this.totalItems,
    required this.subtotal,
    required this.isLoading,
    required this.onCheckout,
  });

  final int totalItems;
  final double subtotal;
  final bool isLoading;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          border: Border(
            top: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.2)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('الإجمالي ($totalItems منتج)'),
                const Spacer(),
                Text(
                  '${subtotal.toStringAsFixed(0)} IQD',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryGold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading ? null : onCheckout,
              child: const Text('متابعة إلى إتمام الطلب'),
            ),
          ],
        ),
      ),
    );
  }
}
