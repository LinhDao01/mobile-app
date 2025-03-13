import 'package:flutter/foundation.dart';

import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';

class CartManager with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final CartDatabase _cartDb = CartDatabase.instance;

  int get productCount {
    return _items.length;
  }

  Map<String, CartItem> get products {
    return {..._items};
  }

  Iterable<MapEntry<String, CartItem>> get productEntries {
    return {..._items}.entries;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> addItem(Product product) async {
    if (_items.containsKey(product.id)) {
      final updatedItem = _items[product.id]!.copyWith(
        quantity: _items[product.id]!.quantity + 1,
      );
      _items.update(product.id!, (existingItem) => updatedItem);

      await _cartDb.insertCartItem(updatedItem);
    } else {
      final newItem = CartItem(
        id: product.id!,
        title: product.title,
        imageUrl: product.imageUrl,
        quantity: 1,
        price: product.price,
      );
      _items.putIfAbsent(product.id!, () => newItem);
      await _cartDb.insertCartItem(newItem);
    }
    notifyListeners();
  }

  Future<void> addItems({required Product product, int quantity = 1}) async {
    if (_items.containsKey(product.id)) {
      final updatedItem = _items[product.id]!.copyWith(
        quantity: _items[product.id]!.quantity + quantity,
      );
      _items.update(product.id!, (existingItem) => updatedItem);

      await _cartDb.insertCartItem(updatedItem);
    } else {
      final newItem = CartItem(
        id: product.id!,
        title: product.title,
        imageUrl: product.imageUrl,
        quantity: quantity,
        price: product.price,
      );
      _items.putIfAbsent(product.id!, () => newItem);
      await _cartDb.insertCartItem(newItem);
    }
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    _items.remove(productId);
    await _cartDb.deleteItem('cart', productId);
    notifyListeners();
  }

  Future<void> clearCart() async {
    _items.clear();
    await _cartDb.clearCart();
    notifyListeners();
  }

  Future<void> loadCartItems() async {
    final dbItems = await _cartDb.getCartItems();
    _items.clear();
    for (var item in dbItems) {
      _items[item.id] = item;
    }
    notifyListeners();
  }
}
