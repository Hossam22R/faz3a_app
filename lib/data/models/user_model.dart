class UserModel {
  String id;
  String fullName;
  String email;
  String phone;
  String photoUrl;
  String city;
  String area;
  int loyaltyPoints;
  DateTime createdAt;
  List<String> savedAddresses;
  List<String> familyMembers;
  String userType;
  bool isVerified;
  bool isActive;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.city,
    required this.area,
    required this.loyaltyPoints,
    required this.createdAt,
    required this.savedAddresses,
    required this.familyMembers,
    required this.userType,
    required this.isVerified,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      photoUrl: json['photoUrl'],
      city: json['city'],
      area: json['area'],
      loyaltyPoints: json['loyaltyPoints'],
      createdAt: DateTime.parse(json['createdAt']),
      savedAddresses: List<String>.from(json['savedAddresses']),
      familyMembers: List<String>.from(json['familyMembers']),
      userType: json['userType'],
      isVerified: json['isVerified'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'city': city,
      'area': area,
      'loyaltyPoints': loyaltyPoints,
      'createdAt': createdAt.toIso8601String(),
      'savedAddresses': savedAddresses,
      'familyMembers': familyMembers,
      'userType': userType,
      'isVerified': isVerified,
      'isActive': isActive,
    };
  }
}