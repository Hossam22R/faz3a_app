import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductStatus { pending, approved, rejected, outOfStock }
enum AdPackage { none, bronze, silver, gold }

class ProductModel {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final String categoryId;
  final double price;
  final double? discountPrice;
  final int stock;
  final List<String> images;
  final ProductStatus status;
  final bool isActive;
  final AdPackage adPackage;
  final DateTime? adExpiresAt;
  final double rating;
  final int reviewsCount;
  final int viewsCount;
  final int ordersCount;
  final Map<String, dynamic>? specifications;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.images,
    this.status = ProductStatus.pending,
    this.isActive = true,
    this.adPackage = AdPackage.none,
    this.adExpiresAt,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.viewsCount = 0,
    this.ordersCount = 0,
    this.specifications,
    this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  double get finalPrice => discountPrice ?? price;

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  int get discountPercentage {
    if (!hasDiscount) {
      return 0;
    }
    return (((price - discountPrice!) / price) * 100).round();
  }

  bool get isInStock => stock > 0;

  bool get isFeatured {
    return adPackage != AdPackage.none && (adExpiresAt?.isAfter(DateTime.now()) ?? false);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'price': price,
      'discountPrice': discountPrice,
      'stock': stock,
      'images': images,
      'status': status.name,
      'isActive': isActive,
      'adPackage': adPackage.name,
      'adExpiresAt': adExpiresAt != null ? Timestamp.fromDate(adExpiresAt!) : null,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'viewsCount': viewsCount,
      'ordersCount': ordersCount,
      'specifications': specifications,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      vendorId: json['vendorId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      stock: json['stock'] as int,
      images: List<String>.from(json['images'] as List<dynamic>),
      status: _productStatusFromJson(json['status']),
      isActive: json['isActive'] as bool? ?? true,
      adPackage: _adPackageFromJson(json['adPackage']),
      adExpiresAt: _dateFromJson(json['adExpiresAt']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      viewsCount: json['viewsCount'] as int? ?? 0,
      ordersCount: json['ordersCount'] as int? ?? 0,
      specifications: (json['specifications'] as Map?)?.cast<String, dynamic>(),
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List<dynamic>) : null,
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updatedAt']),
    );
  }

  ProductModel copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    String? categoryId,
    double? price,
    double? discountPrice,
    int? stock,
    List<String>? images,
    ProductStatus? status,
    bool? isActive,
    AdPackage? adPackage,
    DateTime? adExpiresAt,
    double? rating,
    int? reviewsCount,
    int? viewsCount,
    int? ordersCount,
    Map<String, dynamic>? specifications,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      stock: stock ?? this.stock,
      images: images ?? this.images,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      adPackage: adPackage ?? this.adPackage,
      adExpiresAt: adExpiresAt ?? this.adExpiresAt,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      ordersCount: ordersCount ?? this.ordersCount,
      specifications: specifications ?? this.specifications,
      tags: tags ?? this.tags,
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

  static ProductStatus _productStatusFromJson(dynamic value) {
    if (value is! String) {
      return ProductStatus.pending;
    }
    return ProductStatus.values.firstWhere(
      (ProductStatus status) => status.name == value,
      orElse: () => ProductStatus.pending,
    );
  }

  static AdPackage _adPackageFromJson(dynamic value) {
    if (value is! String) {
      return AdPackage.none;
    }
    return AdPackage.values.firstWhere(
      (AdPackage adPackage) => adPackage.name == value,
      orElse: () => AdPackage.none,
    );
  }
}
