import 'cart_item.dart';
import 'dart:convert';

class OrderItem {
  final String? id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  int get productCount => products.length;

  OrderItem({
    this.id,
    required this.amount,
    required this.products,
    DateTime? dateTime,
  }) : dateTime = dateTime ?? DateTime.now();

  OrderItem copyWith({
    String? id,
    double? amount,
    List<CartItem>? products,
    DateTime? dateTime,
  }) {
    return OrderItem(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      products: products ?? this.products,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "amount": amount,
      "products": jsonEncode(products
          .map((p) => p.toJson())
          .toList()), 
      "dateTime": dateTime.toIso8601String(),
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final productsJson = json['products'];

    final productList =
        productsJson is String ? jsonDecode(productsJson) : productsJson;

    return OrderItem(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      products: (productList as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      dateTime: DateTime.parse(json['dateTime']),
    );
  }

}
