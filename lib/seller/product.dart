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
    this.reviewCount = 0, // Varsayılan değer olarak 0 atandı
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      userID: data['userID'],
      productId: data['productId'] ?? '',
      gender: data['gender'] ?? 'Erkek',
      fit: data['fit'] ?? 'Regular Fit',
      sizes: List<String>.from(data['sizes'] ?? []),
      reviewCount: data['reviewCount'] ?? 0, // Varsayılan değer olarak 0 atandı
    );
  }

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
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
