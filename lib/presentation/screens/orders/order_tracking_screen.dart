import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({
    required this.orderId,
    super.key,
  });

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تتبع الطلب')),
        body: ListView(
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
                    Text('Order ID: $orderId'),
                    const SizedBox(height: 12),
                    const _TimelineItem(title: 'تم إنشاء الطلب', isDone: true),
                    const _TimelineItem(title: 'تم التأكيد', isDone: true),
                    const _TimelineItem(title: 'قيد التجهيز', isDone: true),
                    const _TimelineItem(title: 'قيد الشحن', isDone: false),
                    const _TimelineItem(title: 'تم التسليم', isDone: false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
