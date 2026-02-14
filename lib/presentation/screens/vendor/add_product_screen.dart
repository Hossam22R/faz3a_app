import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'إضافة منتج',
      description: 'نموذج إنشاء منتج جديد مع الصور والمواصفات.',
      icon: Icons.add_box_outlined,
    );
  }
}
