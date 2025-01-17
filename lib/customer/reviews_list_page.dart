import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'review_page.dart';

class ReviewsListPage extends StatelessWidget {
  final List<String> products; // Ürün ID'leri listesi

  const ReviewsListPage({Key? key, required this.products}) : super(key: key);

  Future<Map<String, dynamic>> _fetchProductDetails(String productId) async {
    final productSnapshot = await FirebaseFirestore.instance.collection('products').doc(productId).get();
    if (productSnapshot.exists) {
      return productSnapshot.data()!;
    } else {
      throw Exception("Ürün bulunamadı");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Değerlendirme Yap"),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final productId = products[index];
          return FutureBuilder<Map<String, dynamic>>(
            future: _fetchProductDetails(productId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  title: Text("Yükleniyor..."),
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const ListTile(
                  title: Text("Ürün bilgisi alınamadı"),
                );
              }

              final productData = snapshot.data!;
              return ListTile(
                leading: productData['imageUrl'] != null
                    ? Image.network(productData['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported, size: 50),
                title: Text(productData['name'] ?? "Ürün adı bulunamadı"),
                subtitle: Text("₺${productData['price'].toStringAsFixed(2)}"),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewPage(productId: productId),
                      ),
                    );
                  },
                  child: const Text("Değerlendir"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
