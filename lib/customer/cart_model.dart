import 'package:flutter/foundation.dart';
import '../seller/product.dart';

class CartModel with ChangeNotifier {
  final Map<Product, int> _items = {};

  List<Product> get items => _items.keys.toList();

  double get totalPrice => _items.entries.fold(0.0, (total, entry) => total + entry.key.price * entry.value);

  void add(Product product) {
    if (_items.containsKey(product)) {
      _items[product] = _items[product]! + 1;
    } else {
      _items[product] = 1;
    }
    notifyListeners();
  }

  void remove(Product product) {
    if (_items.containsKey(product)) {
      if (_items[product] == 1) {
        _items.remove(product);
      } else {
        _items[product] = _items[product]! - 1;
      }
      notifyListeners();
    }
  }

  void update(Product product, int quantity) {
    if (quantity <= 0) {
      _items.remove(product);
    } else {
      _items[product] = quantity;
    }
    notifyListeners();
  }

  int getQuantity(Product product) {
    return _items[product] ?? 0;
  }

  int get totalItems {
    return _items.values.fold(0, (total, current) => total + current);
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
