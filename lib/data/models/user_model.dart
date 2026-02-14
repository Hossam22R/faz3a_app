import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { customer, vendor, admin }

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? photoUrl;
  final UserType userType;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Customer fields
  final List<String>? savedAddresses;
  final List<String>? wishlist;
  final int loyaltyPoints;

  // Vendor fields
  final String? storeName;
  final String? storeDescription;
  final String? businessLicense;
  final bool? isApproved;
  final String? subscriptionPlan; // free, basic, pro
  final DateTime? subscriptionExpiresAt;
  final double? rating;
  final int? totalSales;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.userType,
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
    this.savedAddresses,
    this.wishlist,
    this.loyaltyPoints = 0,
    this.storeName,
    this.storeDescription,
    this.businessLicense,
    this.isApproved,
    this.subscriptionPlan,
    this.subscriptionExpiresAt,
    this.rating,
    this.totalSales,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'userType': userType.name,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'savedAddresses': savedAddresses,
      'wishlist': wishlist,
      'loyaltyPoints': loyaltyPoints,
      'storeName': storeName,
      'storeDescription': storeDescription,
      'businessLicense': businessLicense,
      'isApproved': isApproved,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionExpiresAt':
          subscriptionExpiresAt != null ? Timestamp.fromDate(subscriptionExpiresAt!) : null,
      'rating': rating,
      'totalSales': totalSales,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      photoUrl: json['photoUrl'] as String?,
      userType: _userTypeFromJson(json['userType']),
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: _dateFromJson(json['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updatedAt']),
      savedAddresses:
          json['savedAddresses'] != null ? List<String>.from(json['savedAddresses'] as List<dynamic>) : null,
      wishlist: json['wishlist'] != null ? List<String>.from(json['wishlist'] as List<dynamic>) : null,
      loyaltyPoints: json['loyaltyPoints'] as int? ?? 0,
      storeName: json['storeName'] as String?,
      storeDescription: json['storeDescription'] as String?,
      businessLicense: json['businessLicense'] as String?,
      isApproved: json['isApproved'] as bool?,
      subscriptionPlan: json['subscriptionPlan'] as String?,
      subscriptionExpiresAt: _dateFromJson(json['subscriptionExpiresAt']),
      rating: (json['rating'] as num?)?.toDouble(),
      totalSales: json['totalSales'] as int?,
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? photoUrl,
    UserType? userType,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? savedAddresses,
    List<String>? wishlist,
    int? loyaltyPoints,
    String? storeName,
    String? storeDescription,
    String? businessLicense,
    bool? isApproved,
    String? subscriptionPlan,
    DateTime? subscriptionExpiresAt,
    double? rating,
    int? totalSales,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      userType: userType ?? this.userType,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      wishlist: wishlist ?? this.wishlist,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      storeName: storeName ?? this.storeName,
      storeDescription: storeDescription ?? this.storeDescription,
      businessLicense: businessLicense ?? this.businessLicense,
      isApproved: isApproved ?? this.isApproved,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      rating: rating ?? this.rating,
      totalSales: totalSales ?? this.totalSales,
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

  static UserType _userTypeFromJson(dynamic value) {
    if (value is! String) {
      return UserType.customer;
    }
    return UserType.values.firstWhere(
      (UserType type) => type.name == value,
      orElse: () => UserType.customer,
    );
  }
}