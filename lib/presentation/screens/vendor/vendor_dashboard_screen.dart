import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';
import '../../widgets/cards/vendor_card.dart';
import '../../widgets/common/badge_widget.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  static final UserModel _vendor = UserModel(
    id: 'vendor-1',
    fullName: 'Ali Hasan',
    email: 'vendor@nema.store',
    phone: '+9647000000001',
    userType: UserType.vendor,
    createdAt: DateTime(2025, 1, 1),
    storeName: 'متجر علي',
    storeDescription: 'إلكترونيات ومنتجات منزلية',
    isApproved: true,
    subscriptionPlan: 'pro',
    rating: 4.7,
    totalSales: 142,
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('لوحة المورد')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            VendorCard(vendor: _vendor),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                BadgeWidget(label: 'الخطة: PRO'),
                BadgeWidget(label: 'عمولة: 9%'),
                BadgeWidget(label: 'المبيعات: 142'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
