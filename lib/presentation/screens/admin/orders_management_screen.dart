import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/cards/order_card.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAllOrdersForManagement();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة الطلبات')),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            if (orderProvider.isLoading && orderProvider.managementOrders.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (orderProvider.errorMessage != null && orderProvider.managementOrders.isEmpty) {
              return AppErrorWidget(
                message: orderProvider.errorMessage!,
                onRetry: () => context.read<OrderProvider>().loadAllOrdersForManagement(),
              );
            }
            if (orderProvider.managementOrders.isEmpty) {
              return const EmptyState(
                title: 'لا توجد طلبات للعرض',
                icon: Icons.assignment_turned_in_outlined,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final OrderModel order = orderProvider.managementOrders[index];
                return Column(
                  children: <Widget>[
                    OrderCard(
                      order: order,
                      onTap: () => context.push(AppRoutes.orderDetailsLocation(order.id)),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: <Widget>[
                        _ActionChipButton(
                          label: 'تأكيد',
                          onTap: () => _updateStatus(order.id, OrderStatus.confirmed),
                        ),
                        _ActionChipButton(
                          label: 'تجهيز',
                          onTap: () => _updateStatus(order.id, OrderStatus.processing),
                        ),
                        _ActionChipButton(
                          label: 'شحن',
                          onTap: () => _updateStatus(order.id, OrderStatus.shipped),
                        ),
                        _ActionChipButton(
                          label: 'تسليم',
                          onTap: () => _updateStatus(order.id, OrderStatus.delivered),
                        ),
                        _ActionChipButton(
                          label: 'إلغاء',
                          onTap: () => _updateStatus(
                            order.id,
                            OrderStatus.cancelled,
                            cancelReason: 'Cancelled by admin',
                          ),
                          isDanger: true,
                        ),
                      ],
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: orderProvider.managementOrders.length,
            );
          },
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    String orderId,
    OrderStatus status, {
    String? cancelReason,
  }) async {
    final OrderProvider orderProvider = context.read<OrderProvider>();
    final bool ok = await orderProvider.updateStatus(
      orderId: orderId,
      status: status,
      cancelReason: cancelReason,
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'تم تحديث الحالة' : (orderProvider.errorMessage ?? 'فشل تحديث الحالة'),
        ),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: isDanger ? Colors.red.withOpacity(0.12) : null,
    );
  }
}
