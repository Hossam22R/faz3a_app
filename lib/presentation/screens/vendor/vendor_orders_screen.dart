import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/cards/order_card.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? vendorId = context.read<AuthProvider>().currentUser?.id;
      if (vendorId != null && vendorId.isNotEmpty) {
        context.read<OrderProvider>().loadVendorOrders(vendorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلبات المورد')),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            if (orderProvider.isLoading && orderProvider.vendorOrders.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (orderProvider.errorMessage != null && orderProvider.vendorOrders.isEmpty) {
              final String? vendorId = context.read<AuthProvider>().currentUser?.id;
              return AppErrorWidget(
                message: orderProvider.errorMessage!,
                onRetry: vendorId == null ? null : () => orderProvider.loadVendorOrders(vendorId),
              );
            }
            if (orderProvider.vendorOrders.isEmpty) {
              return const EmptyState(
                title: 'لا توجد طلبات واردة بعد',
                subtitle: 'ستظهر هنا الطلبات الخاصة بمنتجاتك.',
                icon: Icons.assignment_outlined,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final order = orderProvider.vendorOrders[index];
                return OrderCard(
                  order: order,
                  onTap: () => context.push(AppRoutes.vendorOrderDetailsLocation(order.id)),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: orderProvider.vendorOrders.length,
            );
          },
        ),
      ),
    );
  }
}
