import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/cards/order_card.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const List<OrderModel> _fallbackOrders = <OrderModel>[
    OrderModel(
      id: 'ord-1001',
      orderNumber: 'NS-1001',
      userId: 'u1',
      vendorId: 'v1',
      items: <CartItemModel>[
        CartItemModel(
          id: 'it-1',
          userId: 'u1',
          productId: 'p1',
          productName: 'سماعات لاسلكية',
          unitPrice: 39000,
          quantity: 1,
          createdAt: DateTime(2025, 1, 1),
        ),
      ],
      status: OrderStatus.processing,
      subtotal: 39000,
      total: 42000,
      deliveryFee: 3000,
      createdAt: DateTime(2025, 1, 2),
    ),
    OrderModel(
      id: 'ord-1002',
      orderNumber: 'NS-1002',
      userId: 'u1',
      vendorId: 'v2',
      items: <CartItemModel>[
        CartItemModel(
          id: 'it-2',
          userId: 'u1',
          productId: 'p2',
          productName: 'خلاط مطبخ',
          unitPrice: 62000,
          quantity: 1,
          createdAt: DateTime(2025, 1, 1),
        ),
      ],
      status: OrderStatus.delivered,
      subtotal: 62000,
      total: 65000,
      deliveryFee: 3000,
      createdAt: DateTime(2025, 1, 3),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null && userId.isNotEmpty) {
        context.read<OrderProvider>().loadOrders(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلباتي')),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            final List<OrderModel> orders =
                orderProvider.orders.isNotEmpty ? orderProvider.orders : _fallbackOrders;

            if (orderProvider.isLoading) {
              return const Center(child: LoadingIndicator());
            }
            if (orderProvider.errorMessage != null && orderProvider.orders.isEmpty) {
              final String? userId = context.read<AuthProvider>().currentUser?.id;
              return AppErrorWidget(
                message: orderProvider.errorMessage!,
                onRetry: userId == null
                    ? null
                    : () => context.read<OrderProvider>().loadOrders(userId),
              );
            }
            if (orders.isEmpty) {
              return const EmptyState(title: 'لا توجد طلبات بعد');
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final OrderModel order = orders[index];
                return OrderCard(
                  order: order,
                  onTap: () => context.push(AppRoutes.orderDetails),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: orders.length,
            );
          },
        ),
      ),
    );
  }
}
