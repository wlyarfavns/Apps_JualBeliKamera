class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String category; // 'Kamera DSLR', 'Mirrorless', 'Lensa', 'Aksesoris'
  final double price;
  final String imageUrl;
  final String description;
  final List<String> features;
  final Map<String, String> specs;
  final double rating;
  final int reviewsCount;
  final String reviewText;
  final String reviewUser;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.features,
    required this.specs,
    required this.rating,
    required this.reviewsCount,
    required this.reviewText,
    required this.reviewUser,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String,
      description: json['description'] as String,
      features: (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      specs: (json['specs'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value.toString())) ?? {},
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviews_count'] as int,
      reviewText: json['review_text'] as String,
      reviewUser: json['review_user'] as String,
    );
  }
}
