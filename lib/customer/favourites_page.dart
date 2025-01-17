import 'package:flutter/material.dart';
import 'package:finalproject/customer/nav_bar.dart'; // MyBottomNavBar dosyasının yolu doğru olduğundan emin olun
import 'package:finalproject/customer/favorites_model.dart'; // MyBottomNavBar dosyasının yolu doğru olduğundan emin olun
import 'package:provider/provider.dart';
import 'package:finalproject/customer/product_page.dart'; // ProductPage dosyasının yolu doğru olduğundan emin olun

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoritesModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
        automaticallyImplyLeading: false,
      ),
      body: favorites.favorites.isEmpty
          ? const Center(
              child: Text(
                'Favorilerinizde ürün bulunmamaktadır.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // İki sütunlu düzen
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
                childAspectRatio: 0.5, // Kartların boyut oranı
              ),
              itemCount: favorites.favorites.length,
              itemBuilder: (context, index) {
                final product = favorites.favorites[index];
                return GestureDetector(
                  onTap: () {
                    // Ürün detay sayfasına yönlendirme
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductPage(product: product),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10.0),
                            ),
                            child: Image.network(
                              product.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₺${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  favorites.remove(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${product.name} favorilerden çıkarıldı'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: 2,
        onTabChange: (index) {},
      ),
    );
  }
}
