import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/loading_indicator.dart';

class VendorAnalyticsScreen extends StatefulWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  State<VendorAnalyticsScreen> createState() => _VendorAnalyticsScreenState();
}

class _VendorAnalyticsScreenState extends State<VendorAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? vendorId = context.read<AuthProvider>().currentUser?.id;
      if (vendorId != null && vendorId.isNotEmpty) {
        context.read<ProductProvider>().loadVendorProducts(vendorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تحليلات المورد')),
        body: Consumer<ProductProvider>(
          builder: (context, productProvider, _) {
            if (productProvider.isLoading && productProvider.vendorProducts.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (productProvider.errorMessage != null && productProvider.vendorProducts.isEmpty) {
              final String? vendorId = context.read<AuthProvider>().currentUser?.id;
              return AppErrorWidget(
                message: productProvider.errorMessage!,
                onRetry: vendorId == null
                    ? null
                    : () => context.read<ProductProvider>().loadVendorProducts(vendorId),
              );
            }

            final List<ProductModel> products = productProvider.vendorProducts;
            final int approved = products.where((ProductModel p) => p.status == ProductStatus.approved).length;
            final int pending = products.where((ProductModel p) => p.status == ProductStatus.pending).length;
            final int outOfStock =
                products.where((ProductModel p) => p.status == ProductStatus.outOfStock || p.stock <= 0).length;
            final int rejected = products.where((ProductModel p) => p.status == ProductStatus.rejected).length;

            final double estimatedRevenue = products.fold<double>(
              0,
              (double sum, ProductModel p) => sum + (p.finalPrice * p.ordersCount),
            );
            final double averageRating = products.isEmpty
                ? 0
                : products.fold<double>(0, (double sum, ProductModel p) => sum + p.rating) / products.length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    _MetricCard(label: 'إجمالي المنتجات', value: '${products.length}'),
                    _MetricCard(label: 'مقبولة', value: '$approved'),
                    _MetricCard(label: 'بانتظار الموافقة', value: '$pending'),
                    _MetricCard(label: 'مرفوضة', value: '$rejected'),
                    _MetricCard(label: 'نفاد مخزون', value: '$outOfStock'),
                    _MetricCard(label: 'متوسط التقييم', value: averageRating.toStringAsFixed(2)),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.paid_outlined),
                    title: const Text('إيراد تقديري (حسب ordersCount)'),
                    subtitle: Text('${estimatedRevenue.toStringAsFixed(0)} IQD'),
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
