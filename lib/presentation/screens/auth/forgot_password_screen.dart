import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'نسيت كلمة المرور',
      description: 'إعادة تعيين كلمة المرور عبر الهاتف/OTP ستُضاف لاحقًا.',
      icon: Icons.lock_reset_outlined,
    );
  }
}
