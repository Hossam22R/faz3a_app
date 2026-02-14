import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../config/dependency_injection/app_dependencies.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const double _deliveryFee = 3000;

  String? _selectedAddressId;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cashOnDelivery;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final String? userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null || userId.isEmpty) {
      return;
    }
    final CartProvider cartProvider = context.read<CartProvider>();
    final AddressProvider addressProvider = context.read<AddressProvider>();

    if (cartProvider.items.isEmpty) {
      await cartProvider.loadCart(userId);
    }
    await addressProvider.loadAddresses(userId);
    if (!mounted) {
      return;
    }
    if (_selectedAddressId == null && addressProvider.addresses.isNotEmpty) {
      final AddressModel address = addressProvider.addresses.firstWhere(
        (AddressModel item) => item.isDefault,
        orElse: () => addressProvider.addresses.first,
      );
      setState(() {
        _selectedAddressId = address.id;
      });
    }
  }

  Future<void> _placeOrder() async {
    final String? userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
      );
      return;
    }

    final CartProvider cartProvider = context.read<CartProvider>();
    final AddressProvider addressProvider = context.read<AddressProvider>();
    final OrderProvider orderProvider = context.read<OrderProvider>();

    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السلة فارغة')),
      );
      return;
    }
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر عنوان التوصيل أولاً')),
      );
      return;
    }

    final AddressModel? selectedAddress = _findAddressById(
      addresses: addressProvider.addresses,
      addressId: _selectedAddressId!,
    );
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('العنوان المحدد غير صالح')),
      );
      return;
    }

    final String orderId = 'ord_${DateTime.now().microsecondsSinceEpoch}';
    final String orderNumber = 'NS-${DateTime.now().millisecondsSinceEpoch}';
    final double subtotal = cartProvider.subtotal;
    final double total = subtotal + _deliveryFee;

    final OrderModel order = OrderModel(
      id: orderId,
      orderNumber: orderNumber,
      userId: userId,
      vendorId: 'multi-vendor',
      items: cartProvider.items,
      subtotal: subtotal,
      deliveryFee: _deliveryFee,
      total: total,
      paymentMethod: _toOrderPaymentMethod(_selectedPaymentMethod),
      addressId: selectedAddress.id,
      addressSnapshot: <String, dynamic>{
        'label': selectedAddress.label,
        'fullName': selectedAddress.fullName,
        'phone': selectedAddress.phone,
        'city': selectedAddress.city,
        'area': selectedAddress.area,
        'street': selectedAddress.street,
        'building': selectedAddress.building,
        'landmark': selectedAddress.landmark,
      },
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    final bool orderSaved = await orderProvider.placeOrder(order);
    if (!mounted) {
      return;
    }
    if (!orderSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderProvider.errorMessage ?? 'فشل إنشاء الطلب')),
      );
      return;
    }

    try {
      await AppDependencies.paymentRepository.processPayment(
        amount: total,
        method: _selectedPaymentMethod,
        orderId: order.id,
      );
      await cartProvider.clearCart(userId);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    context.go(AppRoutes.orderSuccessLocation(order.id));
  }

  OrderPaymentMethod _toOrderPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        return OrderPaymentMethod.cashOnDelivery;
      case PaymentMethod.zainCash:
        return OrderPaymentMethod.zainCash;
      case PaymentMethod.asiaHawala:
        return OrderPaymentMethod.asiaHawala;
    }
  }

  String _paymentLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        return 'الدفع عند الاستلام';
      case PaymentMethod.zainCash:
        return 'Zain Cash';
      case PaymentMethod.asiaHawala:
        return 'Asia Hawala';
    }
  }

  AddressModel? _findAddressById({
    required List<AddressModel> addresses,
    required String addressId,
  }) {
    for (final AddressModel address in addresses) {
      if (address.id == addressId) {
        return address;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إتمام الطلب')),
        body: Consumer3<CartProvider, AddressProvider, OrderProvider>(
          builder: (context, cartProvider, addressProvider, orderProvider, _) {
            if (cartProvider.isLoading || addressProvider.isLoading) {
              return const Center(child: LoadingIndicator());
            }
            if (cartProvider.errorMessage != null && cartProvider.items.isEmpty) {
              return AppErrorWidget(
                message: cartProvider.errorMessage!,
                onRetry: _loadInitialData,
              );
            }
            if (addressProvider.errorMessage != null && addressProvider.addresses.isEmpty) {
              return AppErrorWidget(
                message: addressProvider.errorMessage!,
                onRetry: _loadInitialData,
              );
            }
            if (cartProvider.items.isEmpty) {
              return EmptyState(
                title: 'السلة فارغة',
                subtitle: 'أضف منتجات أولاً قبل إتمام الطلب.',
                icon: Icons.shopping_cart_outlined,
              );
            }

            final double subtotal = cartProvider.subtotal;
            final double total = subtotal + _deliveryFee;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                const Text(
                  'عنوان التوصيل',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (addressProvider.addresses.isEmpty)
                  Card(
                    child: ListTile(
                      title: const Text('لا توجد عناوين محفوظة'),
                      subtitle: const Text('أضف عنوان توصيل للمتابعة'),
                      trailing: TextButton(
                        onPressed: () => context.push(AppRoutes.addAddress),
                        child: const Text('إضافة'),
                      ),
                    ),
                  )
                else
                  ...addressProvider.addresses.map(
                    (AddressModel address) => RadioListTile<String>(
                      value: address.id,
                      groupValue: _selectedAddressId,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedAddressId = value;
                        });
                      },
                      title: Text(address.label),
                      subtitle: Text(address.compactAddress),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'طريقة الدفع',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...PaymentMethod.values.map(
                  (PaymentMethod method) => RadioListTile<PaymentMethod>(
                    value: method,
                    groupValue: _selectedPaymentMethod,
                    onChanged: (PaymentMethod? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                    title: Text(_paymentLabel(method)),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات الطلب (اختياري)',
                    hintText: 'أي تفاصيل إضافية للمندوب أو التوصيل',
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: <Widget>[
                        _SummaryRow(
                          label: 'المجموع الفرعي',
                          value: '${subtotal.toStringAsFixed(0)} IQD',
                        ),
                        const SizedBox(height: 6),
                        _SummaryRow(
                          label: 'التوصيل',
                          value: '${_deliveryFee.toStringAsFixed(0)} IQD',
                        ),
                        const Divider(),
                        _SummaryRow(
                          label: 'الإجمالي',
                          value: '${total.toStringAsFixed(0)} IQD',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: orderProvider.isLoading ? null : _placeOrder,
                  child: orderProvider.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('تأكيد الطلب'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
      fontSize: isBold ? 16 : 14,
    );
    return Row(
      children: <Widget>[
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}
