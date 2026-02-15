import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_item_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

enum OrderPaymentMethod {
  cashOnDelivery,
  zainCash,
  asiaHawala,
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final String vendorId;
  final List<CartItemModel> items;
  final OrderStatus status;
  final OrderPaymentMethod paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double commissionRate;
  final double total;
  final String? addressId;
  final Map<String, dynamic>? addressSnapshot;
  final String? notes;
  final String? cancelReason;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.vendorId,
    required this.items,
    this.status = OrderStatus.pending,
    this.paymentMethod = OrderPaymentMethod.cashOnDelivery,
    required this.subtotal,
    this.deliveryFee = 0,
    this.discount = 0,
    this.commissionRate = 0.10,
    required this.total,
    this.addressId,
    this.addressSnapshot,
    this.notes,
    this.cancelReason,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
  });

  // Backward compatibility for older callers.
  String get orderId => id;

  double get platformCommission => subtotal * commissionRate;
  double get vendorNetAmount => subtotal - platformCommission;
  int get totalItemsCount => items.fold<int>(0, (int sum, CartItemModel item) => sum + item.quantity);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'orderId': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'vendorId': vendorId,
      'items': items.map((CartItemModel item) => item.toJson()).toList(),
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'commissionRate': commissionRate,
      'platformCommission': platformCommission,
      'total': total,
      'addressId': addressId,
      'addressSnapshot': addressSnapshot,
      'notes': notes,
      'cancelReason': cancelReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final List<CartItemModel> parsedItems = (json['items'] as List<dynamic>?)
            ?.map((dynamic item) => CartItemModel.fromJson((item as Map).cast<String, dynamic>()))
            .toList() ??
        _itemsFromLegacyJson(json);

    final double legacyPrice = (json['price'] as num?)?.toDouble() ?? 0;
    final int legacyQty = json['quantity'] as int? ?? 1;
    final double derivedSubtotal = parsedItems.isNotEmpty ? parsedItems.fold<double>(0, (double s, CartItemModel i) => s + i.totalPrice) : legacyPrice * legacyQty;

    return OrderModel(
      id: (json['id'] ?? json['orderId']) as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      items: parsedItems,
      status: _statusFromJson(json['status']),
      paymentMethod: _paymentFromJson(json['paymentMethod']),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? derivedSubtotal,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0.10,
      total: (json['total'] as num?)?.toDouble() ?? derivedSubtotal,
      addressId: json['addressId'] as String?,
      addressSnapshot: (json['addressSnapshot'] as Map?)?.cast<String, dynamic>(),
      notes: json['notes'] as String?,
      cancelReason: json['cancelReason'] as String?,
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updatedAt']),
      deliveredAt: _dateFromJson(json['deliveredAt']),
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    String? vendorId,
    List<CartItemModel>? items,
    OrderStatus? status,
    OrderPaymentMethod? paymentMethod,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? commissionRate,
    double? total,
    String? addressId,
    Map<String, dynamic>? addressSnapshot,
    String? notes,
    String? cancelReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      vendorId: vendorId ?? this.vendorId,
      items: items ?? this.items,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      commissionRate: commissionRate ?? this.commissionRate,
      total: total ?? this.total,
      addressId: addressId ?? this.addressId,
      addressSnapshot: addressSnapshot ?? this.addressSnapshot,
      notes: notes ?? this.notes,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  static List<CartItemModel> _itemsFromLegacyJson(Map<String, dynamic> json) {
    final String? productId = json['productId'] as String?;
    if (productId == null || productId.isEmpty) {
      return const <CartItemModel>[];
    }
    final int qty = json['quantity'] as int? ?? 1;
    final double price = (json['price'] as num?)?.toDouble() ?? 0;
    return <CartItemModel>[
      CartItemModel(
        id: '${json['orderId'] ?? json['id']}_item_0',
        userId: json['userId'] as String? ?? '',
        productId: productId,
        productName: json['productName'] as String? ?? '',
        unitPrice: price,
        quantity: qty,
        createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      ),
    ];
  }

  static OrderStatus _statusFromJson(dynamic value) {
    if (value is! String) {
      return OrderStatus.pending;
    }
    return OrderStatus.values.firstWhere(
      (OrderStatus s) => s.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  static OrderPaymentMethod _paymentFromJson(dynamic value) {
    if (value is! String) {
      return OrderPaymentMethod.cashOnDelivery;
    }
    return OrderPaymentMethod.values.firstWhere(
      (OrderPaymentMethod m) => m.name == value,
      orElse: () => OrderPaymentMethod.cashOnDelivery,
    );
  }

  static DateTime? _dateFromJson(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}