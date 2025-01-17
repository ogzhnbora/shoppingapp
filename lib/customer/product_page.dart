import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalproject/customer/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:finalproject/seller/product.dart';
import 'package:finalproject/customer/cart_model.dart';
import 'package:finalproject/customer/favorites_model.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/customer/comments_page.dart';

class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? selectedSize;
  bool isSizeSelectorVisible = false;
  double averageRating = 0.0; // Ortalama puan
  int totalReviews = 0; // Toplam yorum sayısı

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
    fetchAverageRating(); // Ortalama puanı al
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

Future<void> fetchAverageRating() async {
  try {
    final productRef = FirebaseFirestore.instance.collection('products').doc(widget.product.id);
    final snapshot = await productRef.get();

    if (snapshot.exists) {
      final data = snapshot.data();
      final reviews = data?['reviews'] as List<dynamic>?;

      if (reviews != null && reviews.isNotEmpty) {
        double totalRating = 0;
        reviews.forEach((review) {
          totalRating += (review['rating'] as num).toDouble();
        });

        setState(() {
          averageRating = totalRating / reviews.length; // Ortalama puan
          totalReviews = reviews.length; // Toplam yorum sayısı
        });
      } else {
        setState(() {
          averageRating = 0.0;
          totalReviews = 0;
        });
      }
    }
  } catch (e) {
    print("Hata: $e");
    setState(() {
      averageRating = 0.0;
      totalReviews = 0;
    });
  }
}

    Widget buildSizeSelector() {
    return Wrap(
      spacing: 10.0,
      children: widget.product.sizes.map((size) {
        return ChoiceChip(
          label: Text(size),
          selected: selectedSize == size,
          onSelected: (selected) {
            setState(() {
              selectedSize = selected ? size : null;
            });
          },
          backgroundColor: Colors.grey[200],
          selectedColor: const Color.fromARGB(255, 197, 130, 137),
          labelStyle: const TextStyle(color: Colors.black),
          side: BorderSide(
            color: selectedSize == size
                ? const Color.fromARGB(255, 197, 130, 137)
                : Colors.transparent,
            width: 2,
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }


  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoritesModel>(context, listen: true);
    final cart = Provider.of<CartModel>(context, listen: true);
    const primaryColor = Color.fromARGB(255, 197, 130, 137);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ArtisanModa',
          style: GoogleFonts.lobster(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(
              favorites.isFavorite(widget.product) ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              if (favorites.isFavorite(widget.product)) {
                favorites.remove(widget.product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.product.name} favorilerden çıkarıldı'),
                    backgroundColor: primaryColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                favorites.add(widget.product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.product.name} favorilere eklendi'),
                    backgroundColor: primaryColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 600,
              width: double.infinity,
              child: widget.product.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 100,
                        );
                      },
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 100,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 21, 16, 140),
                    ),
                  ),
                  const SizedBox(height: 10),
                 Row(
  children: [
    RatingBar.builder(
      initialRating: averageRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      itemSize: 20.0,
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {},
      ignoreGestures: true,
    ),
    const SizedBox(width: 8),
    Text(
      averageRating.toStringAsFixed(1),
      style: const TextStyle(fontSize: 16),
    ),
    const SizedBox(width: 8),
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommentsPage(productId: widget.product.id),
          ),
        );
      },
      child: Text(
        '($totalReviews yorum)', // Tıklanabilir yorum metni
        style: const TextStyle(fontSize: 16, color: Colors.blue),
      ),
    ),
  ],
),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isSizeSelectorVisible = !isSizeSelectorVisible;
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 192, 197, 237),
                      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    label: const Text(
                      'Beden',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isSizeSelectorVisible ? buildSizeSelector() : Container(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₺${widget.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ScaleTransition(
                    scale: _animation,
                    child: ElevatedButton(
                      onPressed: selectedSize == null
                          ? null
                          : () {
                              cart.add(widget.product);
                              _controller.forward();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${widget.product.name} sepete eklendi'),
                                  backgroundColor: primaryColor,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 143, 24, 15),
                        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                      ),
                      child: const Text('Sepete Ekle', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
