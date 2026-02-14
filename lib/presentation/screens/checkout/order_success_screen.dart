import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'تم تأكيد الطلب',
      description: 'شاشة تأكيد نجاح إنشاء الطلب مع رقم التتبع.',
      icon: Icons.check_circle_outline_rounded,
    );
  }
}
