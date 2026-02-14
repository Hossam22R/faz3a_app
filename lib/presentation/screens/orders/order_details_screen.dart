import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({
    required this.orderId,
    super.key,
  });

  final String orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.orderId.isNotEmpty) {
        context.read<OrderProvider>().loadOrderById(widget.orderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            final OrderModel? order = orderProvider.selectedOrder;

            if (orderProvider.isLoading && order == null) {
              return const Center(child: LoadingIndicator());
            }
            if (orderProvider.errorMessage != null && order == null) {
              return AppErrorWidget(
                message: orderProvider.errorMessage!,
                onRetry: widget.orderId.isEmpty
                    ? null
                    : () => context.read<OrderProvider>().loadOrderById(widget.orderId),
              );
            }
            if (order == null) {
              return const EmptyState(title: 'تعذر العثور على الطلب');
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          order.orderNumber.isEmpty ? '#${order.id}' : order.orderNumber,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text('الحالة: ${_statusLabel(order.status)}'),
                        Text('العناصر: ${order.totalItemsCount}'),
                        Text('المجموع: ${order.total.toStringAsFixed(0)} IQD'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'عناصر الطلب',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.productName.isEmpty ? item.productId : item.productName),
                      subtitle: Text('الكمية: ${item.quantity}'),
                      trailing: Text('${item.totalPrice.toStringAsFixed(0)} IQD'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.push(AppRoutes.orderTrackingLocation(order.id)),
                  child: const Text('تتبع الطلب'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.confirmed:
        return 'تم التأكيد';
      case OrderStatus.processing:
        return 'قيد التجهيز';
      case OrderStatus.shipped:
        return 'قيد الشحن';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغي';
      case OrderStatus.returned:
        return 'مرتجع';
    }
  }
}
