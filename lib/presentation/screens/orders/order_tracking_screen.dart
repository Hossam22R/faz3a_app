import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({
    required this.orderId,
    super.key,
  });

  final String orderId;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  static const List<_TimelineStep> _steps = <_TimelineStep>[
    _TimelineStep(status: OrderStatus.pending, title: 'تم إنشاء الطلب'),
    _TimelineStep(status: OrderStatus.confirmed, title: 'تم التأكيد'),
    _TimelineStep(status: OrderStatus.processing, title: 'قيد التجهيز'),
    _TimelineStep(status: OrderStatus.shipped, title: 'قيد الشحن'),
    _TimelineStep(status: OrderStatus.delivered, title: 'تم التسليم'),
  ];

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
        appBar: AppBar(title: const Text('تتبع الطلب')),
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

            final int currentIndex = _steps.indexWhere((step) => step.status == order.status);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Timeline الطلب',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text('Order ID: ${order.id}'),
                        Text('الحالة الحالية: ${_statusLabel(order.status)}'),
                        if (order.status == OrderStatus.cancelled && order.cancelReason != null) ...<Widget>[
                          const SizedBox(height: 4),
                          Text('سبب الإلغاء: ${order.cancelReason}'),
                        ],
                        const SizedBox(height: 12),
                        ...List<Widget>.generate(_steps.length, (int index) {
                          final bool isDone = currentIndex >= 0 ? index <= currentIndex : false;
                          return _TimelineItem(title: _steps[index].title, isDone: isDone);
                        }),
                      ],
                    ),
                  ),
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

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.isDone,
  });

  final String title;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isDone ? Colors.green : null,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
    );
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.status,
    required this.title,
  });

  final OrderStatus status;
  final String title;
}
