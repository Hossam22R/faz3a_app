import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'إنشاء حساب',
      description: 'نموذج تسجيل العملاء والموردين سيُنفذ في المرحلة التالية.',
      icon: Icons.person_add_alt_1_outlined,
    );
  }
}
