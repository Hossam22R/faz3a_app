import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class VendorAdsScreen extends StatelessWidget {
  const VendorAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'إعلانات المورد',
      description: 'اختيار باقات الإعلان (برونزي/فضي/ذهبي) وإدارتها.',
      icon: Icons.campaign_outlined,
    );
  }
}
