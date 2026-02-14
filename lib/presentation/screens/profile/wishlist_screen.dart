import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'المفضلة',
      description: 'قائمة المنتجات المحفوظة للمراجعة والشراء لاحقًا.',
      icon: Icons.favorite_border_rounded,
    );
  }
}
