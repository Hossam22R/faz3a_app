import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'تتبع الطلب',
      description: 'Timeline لحالات الطلب من الإنشاء حتى التسليم.',
      icon: Icons.local_shipping_outlined,
    );
  }
}
