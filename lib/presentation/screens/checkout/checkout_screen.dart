import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'إتمام الطلب',
      description: 'اختيار العنوان، طريقة الدفع، ومراجعة الطلب النهائي.',
      icon: Icons.receipt_long_outlined,
    );
  }
}
