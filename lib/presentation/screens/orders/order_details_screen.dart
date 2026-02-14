import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'تفاصيل الطلب',
      description: 'تفاصيل الأصناف، الكلفة، وحالة الشحن للطلب المختار.',
      icon: Icons.description_outlined,
    );
  }
}
