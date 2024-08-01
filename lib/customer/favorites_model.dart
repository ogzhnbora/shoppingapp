import 'package:flutter/material.dart';
import 'package:finalproject/seller/product.dart';

class FavoritesModel with ChangeNotifier {
  List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  void add(Product product) {
    if (!_favorites.contains(product)) {
      _favorites.add(product);
      notifyListeners();
    }
  }

  void remove(Product product) {
    if (_favorites.contains(product)) {
      _favorites.remove(product);
      notifyListeners();
    }
  }

  bool isFavorite(Product product) {
    return _favorites.contains(product);
  }
}
