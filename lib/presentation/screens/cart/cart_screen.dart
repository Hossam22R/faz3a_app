import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null && userId.isNotEmpty) {
        context.read<CartProvider>().loadCart(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('السلة')),
        body: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            final String? userId = context.read<AuthProvider>().currentUser?.id;
            if (cartProvider.isLoading && cartProvider.items.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (cartProvider.errorMessage != null && cartProvider.items.isEmpty) {
              final String? userId = context.read<AuthProvider>().currentUser?.id;
              return AppErrorWidget(
                message: cartProvider.errorMessage!,
                onRetry: userId == null ? null : () => cartProvider.loadCart(userId),
              );
            }
            if (cartProvider.items.isEmpty) {
              return const EmptyState(
                title: 'السلة فارغة',
                subtitle: 'أضف منتجات للمتابعة إلى إتمام الطلب.',
                icon: Icons.shopping_cart_outlined,
              );
            }

            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (BuildContext context, int index) {
                      final item = cartProvider.items[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      item.productName.isEmpty ? item.productId : item.productName,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: userId == null
                                        ? null
                                        : () => cartProvider.removeItem(
                                              userId: userId,
                                              itemId: item.id,
                                            ),
                                    icon: const Icon(Icons.delete_outline_rounded),
                                  ),
                                ],
                              ),
                              Text('سعر القطعة: ${item.unitPrice.toStringAsFixed(0)} IQD'),
                              const SizedBox(height: 8),
                              Row(
                                children: <Widget>[
                                  IconButton(
                                    onPressed: userId == null
                                        ? null
                                        : () => cartProvider.updateQuantity(
                                              userId: userId,
                                              itemId: item.id,
                                              quantity: item.quantity - 1,
                                            ),
                                    icon: const Icon(Icons.remove_circle_outline_rounded),
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    onPressed: userId == null
                                        ? null
                                        : () => cartProvider.updateQuantity(
                                              userId: userId,
                                              itemId: item.id,
                                              quantity: item.quantity + 1,
                                            ),
                                    icon: const Icon(Icons.add_circle_outline_rounded),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${item.totalPrice.toStringAsFixed(0)} IQD',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: cartProvider.items.length,
                  ),
                ),
                _CartFooter(
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

class _CartFooter extends StatelessWidget {
  const _CartFooter({
    required this.subtotal,
    required this.isLoading,
    required this.onCheckout,
  });

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
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text('المجموع الفرعي'),
                const Spacer(),
                Text(
                  '${subtotal.toStringAsFixed(0)} IQD',
                  style: const TextStyle(fontWeight: FontWeight.w700),
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
