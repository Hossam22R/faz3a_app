import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'تعديل الملف الشخصي',
      description: 'تحديث الاسم والصورة ومعلومات الحساب الأساسية.',
      icon: Icons.edit_outlined,
    );
  }
}
