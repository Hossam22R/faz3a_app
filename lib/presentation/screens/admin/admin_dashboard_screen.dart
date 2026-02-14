import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/loading_indicator.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboard());
  }

  Future<void> _loadDashboard() async {
    final OrderProvider orderProvider = context.read<OrderProvider>();
    final VendorProvider vendorProvider = context.read<VendorProvider>();
    final ProductProvider productProvider = context.read<ProductProvider>();
    await Future.wait(<Future<void>>[
      orderProvider.loadAllOrdersForManagement(),
      vendorProvider.loadVendorsForManagement(),
      productProvider.loadPendingProductsForApproval(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('لوحة الإدارة')),
        body: Consumer3<OrderProvider, VendorProvider, ProductProvider>(
          builder: (context, orderProvider, vendorProvider, productProvider, _) {
            final bool firstLoad = (orderProvider.isLoading ||
                    vendorProvider.isLoading ||
                    productProvider.isLoading) &&
                orderProvider.managementOrders.isEmpty &&
                vendorProvider.vendors.isEmpty &&
                productProvider.pendingProducts.isEmpty;
            if (firstLoad) {
              return const Center(child: LoadingIndicator());
            }

            final String? errorMessage = orderProvider.errorMessage ??
                vendorProvider.errorMessage ??
                productProvider.errorMessage;
            if (errorMessage != null &&
                orderProvider.managementOrders.isEmpty &&
                vendorProvider.vendors.isEmpty &&
                productProvider.pendingProducts.isEmpty) {
              return AppErrorWidget(
                message: errorMessage,
                onRetry: _loadDashboard,
              );
            }

            final List<OrderModel> orders = orderProvider.managementOrders;
            final List<UserModel> vendors = vendorProvider.vendors;
            final int approvedVendors =
                vendors.where((UserModel vendor) => vendor.isApproved == true).length;
            final int pendingOrSuspendedVendors = vendors.length - approvedVendors;
            final int pendingProducts = productProvider.pendingProducts.length;
            final int activeOrders = orders
                .where(
                  (OrderModel order) =>
                      order.status != OrderStatus.delivered &&
                      order.status != OrderStatus.cancelled &&
                      order.status != OrderStatus.returned,
                )
                .length;
            final double grossSales = orders.fold<double>(
              0,
              (double sum, OrderModel order) => sum + order.subtotal,
            );
            final double platformCommission = orders.fold<double>(
              0,
              (double sum, OrderModel order) => sum + order.platformCommission,
            );

            final List<String> alerts = <String>[
              if (pendingProducts > 0)
                'يوجد $pendingProducts منتج بانتظار الموافقة.',
              if (pendingOrSuspendedVendors > 0)
                'يوجد $pendingOrSuspendedVendors مورد يحتاج إجراء إداري.',
              if (activeOrders > 0) 'يوجد $activeOrders طلب نشط يحتاج متابعة.',
            ];

            return RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      _MetricCard(label: 'إجمالي الموردين', value: '${vendors.length}'),
                      _MetricCard(label: 'موردون معتمدون', value: '$approvedVendors'),
                      _MetricCard(label: 'منتجات قيد الموافقة', value: '$pendingProducts'),
                      _MetricCard(label: 'طلبات نشطة', value: '$activeOrders'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: <Widget>[
                          _StatLine(
                            title: 'إجمالي المبيعات',
                            value: '${grossSales.toStringAsFixed(0)} IQD',
                          ),
                          const SizedBox(height: 6),
                          _StatLine(
                            title: 'عمولة المنصة',
                            value: '${platformCommission.toStringAsFixed(0)} IQD',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'إجراءات سريعة',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                      _QuickActionCard(
                        title: 'إدارة التصنيفات',
                        icon: Icons.category_outlined,
                        onTap: () => context.push(AppRoutes.categoriesManagement),
                      ),
                      _QuickActionCard(
                        title: 'المالية',
                        icon: Icons.account_balance_wallet_outlined,
                        onTap: () => context.push(AppRoutes.finances),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'تنبيهات تشغيلية',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (alerts.isEmpty)
                    const Card(
                      child: ListTile(
                        title: Text('لا توجد تنبيهات حالياً'),
                        subtitle: Text('كل المؤشرات الأساسية مستقرة.'),
                      ),
                    )
                  else
                    ...alerts.map(
                      (String message) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.notification_important_outlined),
                          title: Text(message),
                        ),
                      ),
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
                        onPressed: () => context.push(AppRoutes.ordersManagement),
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                  if (orders.isEmpty)
                    const Card(
                      child: ListTile(
                        title: Text('لا توجد طلبات بعد'),
                      ),
                    )
                  else
                    ...orders.take(3).map(
                      (OrderModel order) => Card(
                        child: ListTile(
                          title: Text(
                            order.orderNumber.isEmpty ? '#${order.id}' : order.orderNumber,
                          ),
                          subtitle: Text('الحالة: ${_statusLabel(order.status)}'),
                          trailing: Text('${order.total.toStringAsFixed(0)} IQD'),
                          onTap: () => context.push(AppRoutes.orderDetailsLocation(order.id)),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(title),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
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
