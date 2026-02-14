import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'إضافة عنوان',
      description: 'نموذج إدخال عنوان جديد مع نقطة الخريطة.',
      icon: Icons.add_location_alt_outlined,
    );
  }
}
