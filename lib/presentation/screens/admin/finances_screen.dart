import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/order_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/loading_indicator.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<OrderProvider>().loadAllOrdersForManagement();
    if (!mounted) {
      return;
    }
    await context.read<VendorProvider>().loadVendorsForManagement();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المالية')),
        body: Consumer2<OrderProvider, VendorProvider>(
          builder: (context, orderProvider, vendorProvider, _) {
            final bool loading =
                (orderProvider.isLoading && orderProvider.managementOrders.isEmpty) ||
                    (vendorProvider.isLoading && vendorProvider.vendors.isEmpty);
            if (loading) {
              return const Center(child: LoadingIndicator());
            }
            final String? error = orderProvider.errorMessage ?? vendorProvider.errorMessage;
            if (error != null &&
                orderProvider.managementOrders.isEmpty &&
                vendorProvider.vendors.isEmpty) {
              return AppErrorWidget(
                message: error,
                onRetry: _load,
              );
            }

            final List<OrderModel> orders = orderProvider.managementOrders;
            final List<UserModel> vendors = vendorProvider.vendors;
            final double totalSales =
                orders.fold<double>(0, (double sum, OrderModel order) => sum + order.subtotal);
            final double totalCommission =
                orders.fold<double>(0, (double sum, OrderModel order) => sum + order.platformCommission);
            final double deliveredCommission = orders
                .where((OrderModel order) => order.status == OrderStatus.delivered)
                .fold<double>(0, (double sum, OrderModel order) => sum + order.platformCommission);
            final double pendingCommission = totalCommission - deliveredCommission;
            final int approvedVendors =
                vendors.where((UserModel vendor) => vendor.isApproved == true).length;
            final double subscriptionRevenueEstimate = vendors.fold<double>(
              0,
              (double sum, UserModel vendor) => sum + _subscriptionFee(vendor.subscriptionPlan),
            );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _FinanceRow(label: 'إجمالي المبيعات', value: '${totalSales.toStringAsFixed(0)} IQD'),
                _FinanceRow(label: 'إجمالي عمولة المنصة', value: '${totalCommission.toStringAsFixed(0)} IQD'),
                _FinanceRow(
                  label: 'عمولة محققة (طلبات مكتملة)',
                  value: '${deliveredCommission.toStringAsFixed(0)} IQD',
                ),
                _FinanceRow(
                  label: 'عمولة قيد التحصيل',
                  value: '${pendingCommission.toStringAsFixed(0)} IQD',
                ),
                _FinanceRow(label: 'الموردون المعتمدون', value: '$approvedVendors'),
                _FinanceRow(
                  label: 'إيراد اشتراكات تقديري',
                  value: '${subscriptionRevenueEstimate.toStringAsFixed(0)} IQD',
                ),
                const SizedBox(height: 10),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('ملاحظة'),
                    subtitle: Text(
                      'هذه القيم تشغيلية تقديرية وتعتمد على البيانات الحالية داخل النظام.',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _subscriptionFee(String? plan) {
    switch (plan) {
      case 'basic':
        return 30000;
      case 'pro':
        return 70000;
      default:
        return 0;
    }
  }
}

class _FinanceRow extends StatelessWidget {
  const _FinanceRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
