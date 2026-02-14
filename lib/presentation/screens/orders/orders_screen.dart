import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
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
            if (orderProvider.orders.isEmpty) {
              return const EmptyState(title: 'لا توجد طلبات بعد');
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final order = orderProvider.orders[index];
                return OrderCard(
                  order: order,
                  onTap: () => context.push(AppRoutes.orderDetailsLocation(order.id)),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: orderProvider.orders.length,
            );
          },
        ),
      ),
    );
  }
}
