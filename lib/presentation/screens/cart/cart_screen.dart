import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'السلة',
      description: 'إدارة عناصر السلة وحساب الإجمالي قبل إتمام الطلب.',
      icon: Icons.shopping_cart_outlined,
    );
  }
}
