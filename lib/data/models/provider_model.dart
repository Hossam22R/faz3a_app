class ProviderModel {
  String id;
  String fullName;
  String photoUrl;
  double rating;
  int completedServices;
  String badgeLevel;
  bool isVerified;
  bool isAvailable;
  String bio;
  List<String> specialties;
  String phone;
  List<String> certifications;
  DateTime joinedDate;
  String nationalId;

  ProviderModel({
    required this.id,
    required this.fullName,
    required this.photoUrl,
    required this.rating,
    required this.completedServices,
    required this.badgeLevel,
    required this.isVerified,
    required this.isAvailable,
    required this.bio,
    required this.specialties,
    required this.phone,
    required this.certifications,
    required this.joinedDate,
    required this.nationalId,
  });

  int yearsOfExperience() {
    return DateTime.now().year - joinedDate.year;
  }

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      photoUrl: json['photoUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      completedServices: json['completedServices'] as int,
      badgeLevel: json['badgeLevel'] as String,
      isVerified: json['isVerified'] as bool,
      isAvailable: json['isAvailable'] as bool,
      bio: json['bio'] as String,
      specialties: List<String>.from(json['specialties'] as List<dynamic>),
      phone: json['phone'] as String,
      certifications: List<String>.from(json['certifications'] as List<dynamic>),
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      nationalId: json['nationalId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'rating': rating,
      'completedServices': completedServices,
      'badgeLevel': badgeLevel,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'bio': bio,
      'specialties': specialties,
      'phone': phone,
      'certifications': certifications,
      'joinedDate': joinedDate.toIso8601String(),
      'nationalId': nationalId,
    };
  }
}