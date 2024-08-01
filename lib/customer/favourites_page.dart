import 'package:flutter/material.dart';
import 'package:finalproject/customer/nav_bar.dart'; // MyBottomNavBar dosyasının yolu doğru olduğundan emin olun
import 'package:finalproject/customer/favorites_model.dart'; // MyBottomNavBar dosyasının yolu doğru olduğundan emin olun
import 'package:provider/provider.dart';

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
      body: ListView.builder(
        itemCount: favorites.favorites.length,
        itemBuilder: (context, index) {
          final product = favorites.favorites[index];
          return ListTile(
            leading: Image.network(product.imageUrl),
            title: Text(product.name),
            subtitle: Text('₺${product.price.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                favorites.remove(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} favorilerden çıkarıldı'))
                );
              },
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
