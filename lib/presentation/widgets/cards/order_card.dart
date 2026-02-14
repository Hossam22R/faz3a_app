import 'package:flutter/material.dart';

import '../../../data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    required this.order,
    this.onTap,
    super.key,
  });

  final OrderModel order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(order.orderNumber.isEmpty ? '#${order.id}' : order.orderNumber),
        subtitle: Text('العناصر: ${order.totalItemsCount}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text('${order.total.toStringAsFixed(0)} IQD'),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _statusLabel(order.status),
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'انتظار';
      case OrderStatus.confirmed:
        return 'مؤكد';
      case OrderStatus.processing:
        return 'تجهيز';
      case OrderStatus.shipped:
        return 'شحن';
      case OrderStatus.delivered:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
      case OrderStatus.returned:
        return 'مرتجع';
    }
  }
}
