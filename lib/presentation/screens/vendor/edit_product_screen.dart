import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class EditProductScreen extends StatelessWidget {
  const EditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'تعديل المنتج',
      description: 'تحديث السعر، المخزون، الوصف، والصور للمنتج.',
      icon: Icons.edit_note_outlined,
    );
  }
}
