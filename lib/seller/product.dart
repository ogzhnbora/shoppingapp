import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String userID;
  final String productId;
  final String gender;
  final String fit;
  final List<String> sizes;
  final int reviewCount;
  final int stock;
  final double averageRating; // Ürünün ortalama puanı

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.userID,
    required this.productId,
    required this.gender,
    required this.fit,
    required this.sizes,
    required this.stock,
    this.reviewCount = 0, // Varsayılan değer olarak 0 atandı
        required this.averageRating,

  });

  /// Firestore'dan map yapısını `Product` nesnesine dönüştürür.
  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      userID: data['userID'] ?? '',
      productId: data['productId'] ?? '',
      gender: data['gender'] ?? 'Erkek',
      fit: data['fit'] ?? 'Regular Fit',
      sizes: List<String>.from(data['sizes'] ?? []),
      reviewCount: data['reviewCount'] ?? 0,
      stock: data['stock'] ?? 0,
            averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,

    );
  }

  /// `Product` nesnesini Firestore'a kaydetmek için bir map yapısına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'userID': userID,
      'productId': productId,
      'gender': gender,
      'fit': fit,
      'sizes': sizes,
      'reviewCount': reviewCount,
      'stock': stock,
    };
  }

  /// JSON formatından `Product` nesnesine dönüştürür (SharedPreferences için).
  factory Product.fromJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      userID: data['userID'] ?? '',
      productId: data['productId'] ?? '',
      gender: data['gender'] ?? 'Erkek',
      fit: data['fit'] ?? 'Regular Fit',
      sizes: List<String>.from(data['sizes'] ?? []),
      reviewCount: data['reviewCount'] ?? 0,
      stock: data['stock'] ?? 0,
            averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,

    );
  }

  /// `Product` nesnesini JSON formatına dönüştürür (SharedPreferences için).
  String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'userID': userID,
      'productId': productId,
      'gender': gender,
      'fit': fit,
      'sizes': sizes,
      'reviewCount': reviewCount,
      'stock': stock,
    });
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
