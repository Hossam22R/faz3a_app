import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/loading_indicator.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    await context.read<VendorProvider>().loadVendorsForManagement();
    await context.read<ProductProvider>().loadPendingProductsForApproval();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تحليلات المنصة')),
        body: Consumer2<VendorProvider, ProductProvider>(
          builder: (context, vendorProvider, productProvider, _) {
            final bool loading =
                (vendorProvider.isLoading && vendorProvider.vendors.isEmpty) ||
                    (productProvider.isLoading && productProvider.pendingProducts.isEmpty);
            if (loading) {
              return const Center(child: LoadingIndicator());
            }

            final String? error = vendorProvider.errorMessage ?? productProvider.errorMessage;
            if (error != null &&
                vendorProvider.vendors.isEmpty &&
                productProvider.pendingProducts.isEmpty) {
              return AppErrorWidget(
                message: error,
                onRetry: _loadData,
              );
            }

            final List<UserModel> vendors = vendorProvider.vendors;
            final int totalVendors = vendors.length;
            final int approvedVendors =
                vendors.where((UserModel vendor) => vendor.isApproved == true).length;
            final int suspendedOrPending = totalVendors - approvedVendors;
            final int pendingProducts = productProvider.pendingProducts.length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    _MetricCard(label: 'إجمالي الموردين', value: '$totalVendors'),
                    _MetricCard(label: 'الموردون المعتمدون', value: '$approvedVendors'),
                    _MetricCard(label: 'موردون معلقون/بانتظار', value: '$suspendedOrPending'),
                    _MetricCard(label: 'منتجات بانتظار الموافقة', value: '$pendingProducts'),
                  ],
                ),
                const SizedBox(height: 16),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('ملاحظة'),
                    subtitle: Text(
                      'هذه لوحة مؤشرات تشغيلية أولية. يمكن توسيعها برسوم زمنية وKPIs مالية مفصلة.',
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
      width: 170,
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
