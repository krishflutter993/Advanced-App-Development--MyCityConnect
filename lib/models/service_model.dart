class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double rating;
  final String phone;
  final String description;

  ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.phone,
    required this.description,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['image'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      phone: json['phone'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
