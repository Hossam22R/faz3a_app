import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/loading_indicator.dart';

class VendorFinancesScreen extends StatefulWidget {
  const VendorFinancesScreen({super.key});

  @override
  State<VendorFinancesScreen> createState() => _VendorFinancesScreenState();
}

class _VendorFinancesScreenState extends State<VendorFinancesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final String? vendorId = context.read<AuthProvider>().currentUser?.id;
    if (vendorId == null || vendorId.isEmpty) {
      return;
    }
    await context.read<OrderProvider>().loadVendorOrders(vendorId);
    if (!mounted) {
      return;
    }
    await context.read<ProductProvider>().loadVendorProducts(vendorId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مالية المورد')),
        body: Consumer2<OrderProvider, ProductProvider>(
          builder: (context, orderProvider, productProvider, _) {
            final bool loading =
                (orderProvider.isLoading && orderProvider.vendorOrders.isEmpty) ||
                    (productProvider.isLoading && productProvider.vendorProducts.isEmpty);
            if (loading) {
              return const Center(child: LoadingIndicator());
            }
            final String? error = orderProvider.errorMessage ?? productProvider.errorMessage;
            if (error != null &&
                orderProvider.vendorOrders.isEmpty &&
                productProvider.vendorProducts.isEmpty) {
              return AppErrorWidget(
                message: error,
                onRetry: _load,
              );
            }

            final List<OrderModel> orders = orderProvider.vendorOrders;
            final List<ProductModel> products = productProvider.vendorProducts;
            final double grossSales = orders.fold<double>(0, (double s, OrderModel o) => s + o.subtotal);
            final double commission = orders.fold<double>(0, (double s, OrderModel o) => s + o.platformCommission);
            final double net = orders.fold<double>(0, (double s, OrderModel o) => s + o.vendorNetAmount);
            final double deliveredNet = orders
                .where((OrderModel o) => o.status == OrderStatus.delivered)
                .fold<double>(0, (double s, OrderModel o) => s + o.vendorNetAmount);
            final double pendingNet = net - deliveredNet;
            final double adSpend = products.fold<double>(0, (double s, ProductModel p) => s + _adCost(p.adPackage));

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _FinanceTile(label: 'إجمالي المبيعات (قبل العمولة)', value: '${grossSales.toStringAsFixed(0)} IQD'),
                _FinanceTile(label: 'عمولة المنصة', value: '${commission.toStringAsFixed(0)} IQD'),
                _FinanceTile(label: 'صافي المورد', value: '${net.toStringAsFixed(0)} IQD'),
                _FinanceTile(label: 'صافي مسلّم (طلبات مكتملة)', value: '${deliveredNet.toStringAsFixed(0)} IQD'),
                _FinanceTile(label: 'صافي قيد التحصيل', value: '${pendingNet.toStringAsFixed(0)} IQD'),
                _FinanceTile(
                  label: 'تكلفة الباقات الإعلانية (تقديرية شهرية)',
                  value: '${adSpend.toStringAsFixed(0)} IQD',
                ),
                const SizedBox(height: 10),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('ملاحظة'),
                    subtitle: Text(
                      'الأرقام المعروضة تشغيلية/تقديرية وتعتمد على البيانات الحالية المتاحة.',
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

  double _adCost(AdPackage adPackage) {
    switch (adPackage) {
      case AdPackage.none:
        return 0;
      case AdPackage.bronze:
        return 50000;
      case AdPackage.silver:
        return 100000;
      case AdPackage.gold:
        return 200000;
    }
  }
}

class _FinanceTile extends StatelessWidget {
  const _FinanceTile({
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
