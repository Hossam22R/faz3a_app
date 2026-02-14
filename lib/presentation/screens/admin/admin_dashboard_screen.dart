import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('لوحة الإدارة')),
        body: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: <Widget>[
            _QuickActionCard(
              title: 'إدارة الموردين',
              icon: Icons.store_mall_directory_outlined,
              onTap: () => context.push(AppRoutes.vendorsManagement),
            ),
            _QuickActionCard(
              title: 'موافقة المنتجات',
              icon: Icons.fact_check_outlined,
              onTap: () => context.push(AppRoutes.productsApproval),
            ),
            _QuickActionCard(
              title: 'إدارة الطلبات',
              icon: Icons.inventory_2_outlined,
              onTap: () => context.push(AppRoutes.ordersManagement),
            ),
            _QuickActionCard(
              title: 'تحليلات المنصة',
              icon: Icons.insights_outlined,
              onTap: () => context.push(AppRoutes.analytics),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
