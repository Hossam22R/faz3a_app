import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/cards/vendor_card.dart';
import '../../widgets/common/badge_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboard());
  }

  Future<void> _loadDashboard() async {
    final String? vendorId = context.read<AuthProvider>().currentUser?.id;
    if (vendorId == null || vendorId.isEmpty) {
      return;
    }
    await context.read<ProductProvider>().loadVendorProducts(vendorId);
    if (!mounted) {
      return;
    }
    await context.read<OrderProvider>().loadVendorOrders(vendorId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('لوحة المورد')),
        body: Consumer3<AuthProvider, ProductProvider, OrderProvider>(
          builder: (context, authProvider, productProvider, orderProvider, _) {
            final UserModel? user = authProvider.currentUser;
            if (user == null) {
              return const EmptyState(
                title: 'يجب تسجيل الدخول كمورد',
                subtitle: 'سجل الدخول أولاً للوصول إلى لوحة المورد.',
                icon: Icons.storefront_outlined,
              );
            }
            if (user.userType == UserType.customer) {
              return const EmptyState(
                title: 'هذه الواجهة للموردين فقط',
                subtitle: 'أنشئ حساب مورد أو غيّر نوع الحساب للمتابعة.',
                icon: Icons.store_mall_directory_outlined,
              );
            }

            final bool firstLoad = (productProvider.isLoading || orderProvider.isLoading) &&
                productProvider.vendorProducts.isEmpty &&
                orderProvider.vendorOrders.isEmpty;
            if (firstLoad) {
              return const Center(child: LoadingIndicator());
            }

            final List<OrderModel> orders = orderProvider.vendorOrders;
            final int totalProducts = productProvider.vendorProducts.length;
            final int activeProducts = productProvider.vendorProducts.where((p) => p.isActive).length;
            final int pendingOrders = orders.where((OrderModel order) => order.status == OrderStatus.pending).length;
            final int deliveredOrders =
                orders.where((OrderModel order) => order.status == OrderStatus.delivered).length;
            final double grossSales =
                orders.fold<double>(0, (double sum, OrderModel order) => sum + order.subtotal);
            final double netRevenue =
                orders.fold<double>(0, (double sum, OrderModel order) => sum + order.vendorNetAmount);

            return RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  VendorCard(vendor: user),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      BadgeWidget(label: 'الخطة: ${(user.subscriptionPlan ?? 'free').toUpperCase()}'),
                      const BadgeWidget(label: 'عمولة: 10%'),
                      BadgeWidget(label: 'منتجات: $totalProducts'),
                      BadgeWidget(label: 'طلبات معلقة: $pendingOrders'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _VendorStatsCard(
                    totalProducts: totalProducts,
                    activeProducts: activeProducts,
                    pendingOrders: pendingOrders,
                    deliveredOrders: deliveredOrders,
                    grossSales: grossSales,
                    netRevenue: netRevenue,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'إدارة سريعة',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                    children: <Widget>[
                      _VendorActionButton(
                        icon: Icons.inventory_outlined,
                        label: 'منتجاتي',
                        onTap: () => context.push(AppRoutes.vendorProducts),
                      ),
                      _VendorActionButton(
                        icon: Icons.assignment_outlined,
                        label: 'طلبات المورد',
                        onTap: () => context.push(AppRoutes.vendorOrders),
                      ),
                      _VendorActionButton(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'المالية',
                        onTap: () => context.push(AppRoutes.vendorFinances),
                      ),
                      _VendorActionButton(
                        icon: Icons.campaign_outlined,
                        label: 'الإعلانات',
                        onTap: () => context.push(AppRoutes.vendorAds),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      const Text(
                        'آخر الطلبات',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.vendorOrders),
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                  if (orders.isEmpty)
                    const Card(
                      child: ListTile(
                        title: Text('لا توجد طلبات للمورد حالياً'),
                      ),
                    )
                  else
                    ...orders.take(3).map(
                      (OrderModel order) => Card(
                        child: ListTile(
                          title: Text(order.orderNumber.isEmpty ? '#${order.id}' : order.orderNumber),
                          subtitle: Text('الحالة: ${_statusLabel(order.status)}'),
                          trailing: Text('${order.total.toStringAsFixed(0)} IQD'),
                          onTap: () => context.push(AppRoutes.vendorOrderDetailsLocation(order.id)),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'انتظار';
      case OrderStatus.confirmed:
        return 'مؤكد';
      case OrderStatus.processing:
        return 'تجهيز';
      case OrderStatus.shipped:
        return 'شحن';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغي';
      case OrderStatus.returned:
        return 'مرتجع';
    }
  }
}

class _VendorStatsCard extends StatelessWidget {
  const _VendorStatsCard({
    required this.totalProducts,
    required this.activeProducts,
    required this.pendingOrders,
    required this.deliveredOrders,
    required this.grossSales,
    required this.netRevenue,
  });

  final int totalProducts;
  final int activeProducts;
  final int pendingOrders;
  final int deliveredOrders;
  final double grossSales;
  final double netRevenue;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: _VendorStatTile(title: 'المنتجات', value: '$totalProducts')),
                Expanded(child: _VendorStatTile(title: 'المنتجات النشطة', value: '$activeProducts')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(child: _VendorStatTile(title: 'طلبات بانتظار', value: '$pendingOrders')),
                Expanded(child: _VendorStatTile(title: 'طلبات مكتملة', value: '$deliveredOrders')),
              ],
            ),
            const Divider(height: 20),
            _VendorStatLine(label: 'إجمالي المبيعات', value: '${grossSales.toStringAsFixed(0)} IQD'),
            const SizedBox(height: 4),
            _VendorStatLine(label: 'صافي المورد', value: '${netRevenue.toStringAsFixed(0)} IQD'),
          ],
        ),
      ),
    );
  }
}

class _VendorStatTile extends StatelessWidget {
  const _VendorStatTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class _VendorStatLine extends StatelessWidget {
  const _VendorStatLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(label),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _VendorActionButton extends StatelessWidget {
  const _VendorActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
