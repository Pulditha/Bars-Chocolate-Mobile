import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartItem>> _cartFuture;
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    setState(() {
      _cartFuture = _cartService.fetchCartItems();
    });
  }

  void _toggleCart(int productId, {bool remove = false}) async {
    try {
      await _cartService.toggleCart(productId, remove);
      _loadCart();
    } catch (e) {
      print("Error toggling cart: $e");
    }
  }

  void _updateQuantity(int productId, bool increase) async {
    try {
      await _cartService.updateQuantity(productId, increase);
      _loadCart();
    } catch (e) {
      print("Error updating quantity: $e");
    }
  }

  void _checkout() async {
    try {
      await _cartService.checkout();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Checkout successful! Your cart is now empty.")),
      );
      _loadCart(); // Refresh cart after checkout
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Checkout failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Cart")),
      body: FutureBuilder<List<CartItem>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Your cart is empty."));
          }

          List<CartItem> cartItems = snapshot.data!;
          double subtotal = cartItems.fold(0, (sum, item) => sum + (item.finalPrice * item.quantity));
          double total = subtotal; // You can add tax or discounts if needed

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    CartItem item = cartItems[index];
                    String imageUrl = item.images.isNotEmpty ? item.images[0] : "";
                    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                      imageUrl = "https://bars-chocolate.online/storage/$imageUrl";
                    }

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 50, color: Colors.grey);
                          },
                        )
                            : Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        title: Text(item.product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Category: ${item.category}"),
                            Text(
                              "${item.product.currency} ${item.finalPrice.toStringAsFixed(2)} x ${item.quantity}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: item.quantity > 1
                                      ? () => _updateQuantity(item.productId, false)
                                      : () => _toggleCart(item.productId, remove: true),
                                ),
                                Text(item.quantity.toString(), style: TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () => _updateQuantity(item.productId, true),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _toggleCart(item.productId, remove: true),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Summary and Checkout Button
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Subtotal: LKR ${subtotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                    Text("Total: LKR ${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checkout,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text("Proceed to Checkout", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
