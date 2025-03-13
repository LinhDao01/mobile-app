import 'dart:io';

class Product {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final File? featuredImage;
  final bool isFavorite;
  final int quantity;

  Product({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl = '',
    this.featuredImage,
    this.isFavorite = false,
    this.quantity = 1,
  });

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    File? featuredImage,
    bool? isFavorite,
    int? quantity,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      featuredImage: featuredImage ?? this.featuredImage,
      isFavorite: isFavorite ?? this.isFavorite,
      quantity: quantity ?? this.quantity,
    );
  }

  bool hasFeaturedImage() {
    return featuredImage != null || imageUrl.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'isFavorite': isFavorite,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['imageUrl'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
