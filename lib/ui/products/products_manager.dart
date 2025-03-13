import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../models/product.dart';
import '../../services/product_service.dart';

class ProductsManager with ChangeNotifier {
  final ProductService _productsService = ProductService();
  List<Product> _items = [];

  int get itemCount {
    return _items.length;
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (err) {
      return null;
    }
  }

  Future<void> addProduct(Product product) async {
    final newProduct = await _productsService.addProduct(product);
    if (newProduct != null) {
      _items.add(newProduct);
      notifyListeners();
    }
  }

  // void addProduct(Product product) {
  //   _items.add(
  //     product.copyWith(id: 'p${DateTime.now().toIso8601String()}'),
  //   );
  //   notifyListeners();
  // }

  Future<void> fetchProducts() async {
    _items = await _productsService.fetchProducts();
    notifyListeners();
  }

  Future<void> fetchUserProducts() async {
    _items = await _productsService.fetchProducts(filteredByUser: true);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final index = _items.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      // _items[index] = product;
      final updatedProduct = await _productsService.updateProduct(product);
      if (updatedProduct != null) {
        _items[index] = updatedProduct;
        notifyListeners();
      }
      // notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0 && await _productsService.deleteProduct(id)) {
      _items.removeAt(index);
      notifyListeners();
    }
  }
}
