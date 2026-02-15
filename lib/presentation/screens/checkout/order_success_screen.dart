import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    this.orderId,
    super.key,
  });

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تم تأكيد الطلب')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.check_circle_outline_rounded, size: 70, color: Colors.green),
                const SizedBox(height: 12),
                const Text(
                  'تم تأكيد طلبك بنجاح',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  orderId == null || orderId!.isEmpty
                      ? 'سيتم تحديث حالة الطلب من لوحة الطلبات.'
                      : 'رقم الطلب: $orderId',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: orderId == null || orderId!.isEmpty
                        ? null
                        : () => context.go(AppRoutes.orderDetailsLocation(orderId!)),
                    child: const Text('عرض تفاصيل الطلب'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go(AppRoutes.orders),
                    child: const Text('الذهاب إلى طلباتي'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('العودة إلى الرئيسية'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
