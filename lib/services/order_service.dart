import 'dart:convert';
import '../../models/order_item.dart';
import '../../models/cart_item.dart';
import 'pocketbase_client.dart';

class OrderService {
  Future<OrderItem?> saveOrder(OrderItem order) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record?.id;

      if (userId == null) {
        throw Exception("User not logged in yet!");
      }

      final productsJson =
          order.products.map((product) => product.toJson()).toList();

      final record = await pb.collection('orders').create(body: {
        'amount': order.amount,
        'products': jsonEncode(productsJson),
        'dateTime': order.dateTime.toIso8601String(),
        'userId': userId,
      });

      return OrderItem(
        id: record.id,
        amount: order.amount,
        products: order.products,
        dateTime: order.dateTime,
      );
    } catch (e) {
      print('Error when save the order: $e');
      rethrow;
    }
  }

  Future<List<OrderItem>> fetchOrders({bool filteredByUser = false}) async {
    final List<OrderItem> orders = [];
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record?.id;

      if (filteredByUser && userId == null) {
        throw Exception("User not logged in yet!");
      }

      final filterQuery = filteredByUser ? 'userId="$userId"' : null;

      final result = await pb.collection('orders').getFullList(
            filter: filterQuery,
            sort: '-dateTime',
          );

      for (final record in result) {
        try {
          String productsStr = record.data['products'];

          if (!productsStr.contains('"id"') && productsStr.contains('id:')) {
            productsStr = productsStr.replaceAllMapped(
              RegExp(r'([{,])\s*([a-zA-Z0-9_]+)\s*:'),
              (match) => '${match.group(1)}"${match.group(2)}":',
            );
          }

          final List<dynamic> productsJson = jsonDecode(productsStr);

          final products = productsJson
              .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'] is int
                        ? item['price'].toDouble()
                        : item['price'],
                    imageUrl: item['imageUrl'],
                  ))
              .toList();

          orders.add(OrderItem(
            id: record.id,
            amount: record.data['amount'],
            dateTime: DateTime.parse(record.data['dateTime']),
            products: products,
          ));
        } catch (e) {
          print("Error when parse the order ${record.id}: $e");
        }
      }

      return orders;
    } catch (e) {
      print("Error when fetch the order(s): $e");
      return [];
    }
  }
}
