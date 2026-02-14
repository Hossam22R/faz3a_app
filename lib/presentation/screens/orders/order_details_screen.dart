import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
    required this.orderId,
    super.key,
  });

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'تفاصيل الطلب',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      const Text('تفاصيل الأصناف، الكلفة، وحالة الشحن للطلب المختار.'),
                      const SizedBox(height: 8),
                      Text('Order ID: $orderId'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: orderId.isEmpty
                    ? null
                    : () => context.push(AppRoutes.orderTrackingLocation(orderId)),
                child: const Text('تتبع الطلب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
