import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../data/models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/cards/order_card.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    final String? userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null && userId.isNotEmpty) {
      await context.read<OrderProvider>().loadOrders(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلباتي')),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
              return const Center(child: LoadingIndicator());
            }
            if (orderProvider.errorMessage != null && orderProvider.orders.isEmpty) {
              return AppErrorWidget(
                message: orderProvider.errorMessage!,
                onRetry: _loadOrders,
              );
            }

            final List<OrderModel> allOrders = orderProvider.orders;
            if (allOrders.isEmpty) {
              return const EmptyState(title: 'لا توجد طلبات بعد');
            }

            final List<OrderModel> filteredOrders = _statusFilter == null
                ? allOrders
                : allOrders.where((OrderModel order) => order.status == _statusFilter).toList();
            final int activeOrdersCount = allOrders
                .where(
                  (OrderModel order) =>
                      order.status != OrderStatus.delivered &&
                      order.status != OrderStatus.cancelled,
                )
                .length;
            final int deliveredCount =
                allOrders.where((OrderModel order) => order.status == OrderStatus.delivered).length;

            return RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _OrdersSummary(
                    totalCount: allOrders.length,
                    activeCount: activeOrdersCount,
                    deliveredCount: deliveredCount,
                  ),
                  const SizedBox(height: 12),
                  _OrderStatusFilters(
                    selected: _statusFilter,
                    onChanged: (OrderStatus? status) {
                      setState(() {
                        _statusFilter = status;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (filteredOrders.isEmpty)
                    const EmptyState(
                      title: 'لا توجد طلبات بهذه الحالة',
                      subtitle: 'غيّر الفلتر لعرض طلبات أخرى.',
                    )
                  else
                    ...filteredOrders.map(
                      (OrderModel order) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OrderCard(
                          order: order,
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
}

class _OrdersSummary extends StatelessWidget {
  const _OrdersSummary({
    required this.totalCount,
    required this.activeCount,
    required this.deliveredCount,
  });

  final int totalCount;
  final int activeCount;
  final int deliveredCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _SummaryStat(title: 'إجمالي الطلبات', value: '$totalCount'),
            ),
            Expanded(
              child: _SummaryStat(title: 'طلبات نشطة', value: '$activeCount'),
            ),
            Expanded(
              child: _SummaryStat(title: 'طلبات مكتملة', value: '$deliveredCount'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
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

class _OrderStatusFilters extends StatelessWidget {
  const _OrderStatusFilters({
    required this.selected,
    required this.onChanged,
  });

  final OrderStatus? selected;
  final ValueChanged<OrderStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        ChoiceChip(
          label: const Text('الكل'),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
        ...OrderStatus.values.map(
          (OrderStatus status) => ChoiceChip(
            label: Text(_statusLabel(status)),
            selected: selected == status,
            onSelected: (_) => onChanged(status),
          ),
        ),
      ],
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
