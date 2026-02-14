import 'package:flutter/material.dart';

import '../../widgets/common/module_placeholder_screen.dart';

class VendorFinancesScreen extends StatelessWidget {
  const VendorFinancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'مالية المورد',
      description: 'الأرباح، العمولات، والتحويلات المالية للمورد.',
      icon: Icons.account_balance_wallet_outlined,
    );
  }
}
