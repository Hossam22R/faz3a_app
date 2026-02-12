import 'package:json_annotation/json_annotation.dart';

part 'provider_model.g.dart';

@JsonSerializable()
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

  factory ProviderModel.fromJson(Map<String, dynamic> json) => _$ProviderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderModelToJson(this);
}