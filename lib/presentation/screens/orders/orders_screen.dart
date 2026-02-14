import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/order_model.dart';
import '../../widgets/cards/order_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const List<OrderModel> _demoOrders = <OrderModel>[
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
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلباتي')),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (BuildContext context, int index) {
            final OrderModel order = _demoOrders[index];
            return OrderCard(
              order: order,
              onTap: () => context.push(AppRoutes.orderDetails),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: _demoOrders.length,
        ),
      ),
    );
  }
}
