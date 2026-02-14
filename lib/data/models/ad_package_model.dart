import 'package:cloud_firestore/cloud_firestore.dart';

enum AdPackageType { bronze, silver, gold }

class AdPackageModel {
  final String id;
  final AdPackageType type;
  final String name;
  final int monthlyPriceIqd;
  final int maxFeaturedProducts;
  final int priorityLevel;
  final List<String> features;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AdPackageModel({
    required this.id,
    required this.type,
    required this.name,
    required this.monthlyPriceIqd,
    required this.maxFeaturedProducts,
    required this.priorityLevel,
    required this.features,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type.name,
      'name': name,
      'monthlyPriceIqd': monthlyPriceIqd,
      'maxFeaturedProducts': maxFeaturedProducts,
      'priorityLevel': priorityLevel,
      'features': features,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory AdPackageModel.fromJson(Map<String, dynamic> json) {
    return AdPackageModel(
      id: json['id'] as String,
      type: _typeFromJson(json['type']),
      name: json['name'] as String,
      monthlyPriceIqd: json['monthlyPriceIqd'] as int,
      maxFeaturedProducts: json['maxFeaturedProducts'] as int? ?? 1,
      priorityLevel: json['priorityLevel'] as int? ?? 0,
      features: List<String>.from(json['features'] as List<dynamic>? ?? <dynamic>[]),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updatedAt']),
    );
  }

  AdPackageModel copyWith({
    String? id,
    AdPackageType? type,
    String? name,
    int? monthlyPriceIqd,
    int? maxFeaturedProducts,
    int? priorityLevel,
    List<String>? features,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdPackageModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      monthlyPriceIqd: monthlyPriceIqd ?? this.monthlyPriceIqd,
      maxFeaturedProducts: maxFeaturedProducts ?? this.maxFeaturedProducts,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
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

  static AdPackageType _typeFromJson(dynamic value) {
    if (value is! String) {
      return AdPackageType.bronze;
    }
    return AdPackageType.values.firstWhere(
      (AdPackageType type) => type.name == value,
      orElse: () => AdPackageType.bronze,
    );
  }
}
