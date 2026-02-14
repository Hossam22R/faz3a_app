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
            Text(order.status.name),
          ],
        ),
      ),
    );
  }
}
