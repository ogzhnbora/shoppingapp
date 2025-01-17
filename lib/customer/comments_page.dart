import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsPage extends StatelessWidget {
  final String productId;

  const CommentsPage({Key? key, required this.productId}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchComments() async {
    final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    final snapshot = await productRef.get();

    if (snapshot.exists) {
      final data = snapshot.data();
      final reviews = data?['reviews'] as List<dynamic>? ?? [];
      return reviews.map((review) => Map<String, dynamic>.from(review)).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yorumlar"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchComments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Yorumlar yüklenirken bir hata oluştu."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Bu ürün için henüz yorum yapılmamış."));
          }

          final comments = snapshot.data!;
          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.grey[700]),
                  title: Text("Puan: ${comment['rating']}"),
                  subtitle: Text(comment['comment'] ?? "Yorum yok"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
