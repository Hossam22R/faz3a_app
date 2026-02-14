import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class VendorOrderDetailsScreen extends StatelessWidget {
  const VendorOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'تفاصيل طلب المورد',
      description: 'عرض عناصر الطلب ومعلومات الشحن والعمولة.',
      icon: Icons.receipt_outlined,
    );
  }
}
