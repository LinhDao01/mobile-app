import 'package:flutter/foundation.dart';
import '../../models/cart_item.dart';
import '../../models/order_item.dart';
import '../../services/order_service.dart';

class OrderManager with ChangeNotifier {
  final List<OrderItem> _orders = [];
  final OrderService _orderService = OrderService();
  bool _isLoading = false;

  int get orderCount => _orders.length;
  List<OrderItem> get orders => [..._orders];
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedOrders = await _orderService.fetchOrders();
      _orders
        ..clear()
        ..addAll(fetchedOrders);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addOrder(List<CartItem> cartProducts, double total) {
    final newOrder = OrderItem(
      amount: total,
      products: cartProducts,
      dateTime: DateTime.now(),
    );

    _orders.insert(0, newOrder);
    notifyListeners();
  }

  bool hasOrder(String orderId) {
    return _orders.any((order) => order.id == orderId);
  }
}
