import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String? productImage;
  final double unitPrice;
  final int quantity;
  final int? maxQuantity;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.unitPrice,
    required this.quantity,
    this.maxQuantity,
    required this.createdAt,
    this.updatedAt,
  });

  double get totalPrice => unitPrice * quantity;
  bool get exceedsStock => maxQuantity != null && quantity > maxQuantity!;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'maxQuantity': maxQuantity,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String? ?? '',
      productImage: json['productImage'] as String?,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
      maxQuantity: json['maxQuantity'] as int?,
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updatedAt']),
    );
  }

  CartItemModel copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    String? productImage,
    double? unitPrice,
    int? quantity,
    int? maxQuantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
