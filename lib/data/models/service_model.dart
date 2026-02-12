class ServiceModel {
  final String id;
  final String name;
  final String nameEn;
  final String description;
  final String category;
  final String iconPath;
  final String imageUrl;
  final double basePrice;
  final String priceUnit;
  final int estimatedDuration;
  final bool isAvailable;
  final bool isPopular;
  final bool allowsEmergency;
  final List<String> subServices;
  final double rating;
  final int reviewsCount;
  final List<String> requiredDocuments;

  ServiceModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.category,
    required this.iconPath,
    required this.imageUrl,
    required this.basePrice,
    required this.priceUnit,
    this.estimatedDuration = 60,
    this.isAvailable = true,
    this.isPopular = false,
    this.allowsEmergency = false,
    this.subServices = const [],
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.requiredDocuments = const [],
  });

  String get formattedPrice => '\${basePrice.toStringAsFixed(0)} \$priceUnit';

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'],
      description: json['description'],
      category: json['category'],
      iconPath: json['iconPath'],
      imageUrl: json['imageUrl'],
      basePrice: json['basePrice'].toDouble(),
      priceUnit: json['priceUnit'],
      estimatedDuration: json['estimatedDuration'] ?? 60,
      isAvailable: json['isAvailable'] ?? true,
      isPopular: json['isPopular'] ?? false,
      allowsEmergency: json['allowsEmergency'] ?? false,
      subServices: List<String>.from(json['subServices'] ?? []),
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewsCount: json['reviewsCount'] ?? 0,
      requiredDocuments: List<String>.from(json['requiredDocuments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'description': description,
      'category': category,
      'iconPath': iconPath,
      'imageUrl': imageUrl,
      'basePrice': basePrice,
      'priceUnit': priceUnit,
      'estimatedDuration': estimatedDuration,
      'isAvailable': isAvailable,
      'isPopular': isPopular,
      'allowsEmergency': allowsEmergency,
      'subServices': subServices,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'requiredDocuments': requiredDocuments,
    };
  }
}