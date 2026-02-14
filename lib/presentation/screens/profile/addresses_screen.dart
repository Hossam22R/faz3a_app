import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'العناوين',
      description: 'إدارة عناوين التوصيل وتحديد العنوان الافتراضي.',
      icon: Icons.location_on_outlined,
    );
  }
}
