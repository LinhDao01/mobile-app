import 'package:flutter/material.dart';
import 'package:myshop/models/order_item.dart';
import 'package:myshop/services/order_service.dart';
import 'package:myshop/ui/orders/order_manager.dart';
import 'package:provider/provider.dart';

import 'cart_manager.dart';
import 'cart_item_card.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartManager>();
    final orderService = OrderService();

    Future<void> _handleOrderNow() async {
      if (cart.totalAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty!')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final cartProducts = cart.products.values.toList();

        final newOrder = await orderService.saveOrder(
          OrderItem(
            amount: cart.totalAmount,
            products: cartProducts,
            dateTime: DateTime.now(),
          ),
        );

        if (newOrder != null) {
          context
              .read<OrderManager>()
              .addOrder(newOrder.products, newOrder.amount);

          await cart.clearCart();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to place order. Please try again.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                CartSummary(
                  cart: cart,
                  onOrderNowPressed: _handleOrderNow,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: CartItemList(cart),
                )
              ],
            ),
    );
  }
}

class CartItemList extends StatelessWidget {
  const CartItemList(this.cart, {super.key});

  final CartManager cart;

  @override
  Widget build(BuildContext context) {
    return cart.productCount > 0
        ? ListView(
            children: cart.productEntries
                .map(
                  (entry) => CartItemCard(
                    productID: entry.key,
                    cartItem: entry.value,
                  ),
                )
                .toList(),
          )
        : const Center(child: Text('Your cart is empty!'));
  }
}

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.cart,
    this.onOrderNowPressed,
  });

  final CartManager cart;
  final void Function()? onOrderNowPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              'Total',
              style: TextStyle(fontSize: 20),
            ),
            const Spacer(),
            Chip(
              label: Text(
                '\$${cart.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).primaryTextTheme.titleLarge,
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            TextButton(
              onPressed: cart.productCount > 0 ? onOrderNowPressed : null,
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: const Text('ORDER NOW'),
            )
          ],
        ),
      ),
    );
  }
}
