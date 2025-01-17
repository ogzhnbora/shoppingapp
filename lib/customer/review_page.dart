import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:finalproject/customer/firebase_service.dart';

class ReviewPage extends StatefulWidget {
  final String productId; // Ürün ID'sini al
  const ReviewPage({Key? key, required this.productId}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final FirebaseService firebaseService = FirebaseService();
    double _rating = 0; // Kullanıcının seçtiği yıldız puanı

  final TextEditingController _commentController = TextEditingController();

 Future<void> submitReview(String productId, double rating, String comment) async {
  if (rating > 0 && comment.isNotEmpty) {
    // Hem ürüne hem de kullanıcıya yorumu ekle
    await firebaseService.addReviewToProduct(productId, rating, comment);
    await firebaseService.addReviewToUser(productId, rating, comment);

    // Başarılı bir değerlendirme sonrası kullanıcıya mesaj göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Değerlendirmeniz kaydedildi!")),
    );

    // Geri dön
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lütfen puanlama ve yorum yapın!")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ürün Değerlendir"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ürüne Puan Verin:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
      RatingBar.builder(
  initialRating: 0,
  minRating: 1,
  direction: Axis.horizontal,
  allowHalfRating: false, // Ara yıldızlar kaldırıldı
  itemCount: 5,
  itemBuilder: (context, _) => const Icon(
    Icons.star,
    color: Colors.amber,
  ),
  onRatingUpdate: (rating) {
    setState(() {
      _rating = rating; // Kullanıcının seçtiği puanı kaydet
    });
  },
),
            const SizedBox(height: 20),
            const Text(
              "Yorum Yazın:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Yorumunuzu buraya yazın...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => submitReview(widget.productId, _rating, _commentController.text),
              child: const Text("Gönder"),
            ),
          ],
        ),
      ),
    );
  }
}
