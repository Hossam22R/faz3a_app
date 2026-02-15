import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class VendorOrderDetailsScreen extends StatefulWidget {
  const VendorOrderDetailsScreen({
    required this.orderId,
    super.key,
  });

  final String orderId;

  @override
  State<VendorOrderDetailsScreen> createState() => _VendorOrderDetailsScreenState();
}

class _VendorOrderDetailsScreenState extends State<VendorOrderDetailsScreen> {
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
        appBar: AppBar(title: const Text('تفاصيل طلب المورد')),
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
              return const EmptyState(title: 'تعذر تحميل تفاصيل الطلب');
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          order.orderNumber.isEmpty ? '#${order.id}' : order.orderNumber,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text('الحالة الحالية: ${_statusLabel(order.status)}'),
                        Text('العناصر: ${order.totalItemsCount}'),
                        Text('الإجمالي: ${order.total.toStringAsFixed(0)} IQD'),
                        Text('عمولة المنصة: ${order.platformCommission.toStringAsFixed(0)} IQD'),
                        Text('صافي المورد: ${order.vendorNetAmount.toStringAsFixed(0)} IQD'),
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
                const Text(
                  'تحديث الحالة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _StatusActionButton(
                      label: 'تأكيد',
                      onPressed: orderProvider.isLoading
                          ? null
                          : () => _updateStatus(OrderStatus.confirmed),
                    ),
                    _StatusActionButton(
                      label: 'قيد التجهيز',
                      onPressed: orderProvider.isLoading
                          ? null
                          : () => _updateStatus(OrderStatus.processing),
                    ),
                    _StatusActionButton(
                      label: 'شحن',
                      onPressed: orderProvider.isLoading
                          ? null
                          : () => _updateStatus(OrderStatus.shipped),
                    ),
                    _StatusActionButton(
                      label: 'تم التسليم',
                      onPressed: orderProvider.isLoading
                          ? null
                          : () => _updateStatus(OrderStatus.delivered),
                    ),
                    _StatusActionButton(
                      label: 'إلغاء',
                      isOutlined: true,
                      onPressed: orderProvider.isLoading
                          ? null
                          : () => _updateStatus(
                                OrderStatus.cancelled,
                                cancelReason: 'Cancelled by vendor',
                              ),
                    ),
                  ],
                ),
                if (order.cancelReason != null && order.cancelReason!.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Text('سبب الإلغاء: ${order.cancelReason!}'),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _updateStatus(OrderStatus status, {String? cancelReason}) async {
    final OrderProvider orderProvider = context.read<OrderProvider>();
    final bool ok = await orderProvider.updateStatus(
      orderId: widget.orderId,
      status: status,
      cancelReason: cancelReason,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'تم تحديث حالة الطلب' : (orderProvider.errorMessage ?? 'فشل تحديث الحالة'),
        ),
      ),
    );
    if (ok) {
      await context.read<OrderProvider>().loadOrderById(widget.orderId);
    }
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

class _StatusActionButton extends StatelessWidget {
  const _StatusActionButton({
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
