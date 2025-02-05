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
        SnackBar(
          content: Text("Checkout successful! Your cart is now empty."),
          backgroundColor: Colors.green,
        ),
      );
      _loadCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Checkout failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" My Cart", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<CartItem>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("🛍️ Your cart is empty.", style: TextStyle(fontSize: 18)));
          }

          List<CartItem> cartItems = snapshot.data!;
          double subtotal = cartItems.fold(0, (sum, item) => sum + (item.finalPrice * item.quantity));
          double total = subtotal;

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
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Image with category-colored background
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(item.category),
                                borderRadius: BorderRadius.circular(10),
                                image: imageUrl.isNotEmpty
                                    ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                  onError: (error, stackTrace) {
                                    return;
                                  },
                                )
                                    : null,
                              ),
                              child: imageUrl.isEmpty
                                  ? Icon(Icons.image_not_supported, color: Colors.white, size: 40)
                                  : null,
                            ),
                            SizedBox(width: 12),

                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text("${item.category}", style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  Text(
                                    "${item.product.currency} ${item.finalPrice.toStringAsFixed(2)} x ${item.quantity}",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
                                  ),
                                  SizedBox(height: 6),

                                  // Quantity Buttons
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                        onPressed: item.quantity > 1
                                            ? () => _updateQuantity(item.productId, false)
                                            : () => _toggleCart(item.productId, remove: true),
                                      ),
                                      Text(item.quantity.toString(), style: TextStyle(fontSize: 16)),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline, color: Colors.green),
                                        onPressed: () => _updateQuantity(item.productId, true),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Delete Icon
                            IconButton(
                              icon: Icon(Icons.delete_forever, color: Colors.red),
                              onPressed: () => _toggleCart(item.productId, remove: true),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Checkout Summary
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6),
                  ],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Subtotal:", style: TextStyle(fontSize: 16)),
                        Text("LKR ${subtotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("LKR ${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _checkout,
                        icon: Icon(Icons.shopping_cart_checkout, color: Colors.white),
                        label: Text("Proceed to Checkout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold
                        ,color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Colors.brown,
                        ),
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

  Color _getCategoryColor(String category) {
    Map<String, Color> categoryColors = {
      'DARK': Colors.brown.shade900,
      'MILK': Colors.brown.shade300,
      'WHITE': Colors.amber.shade100,
      'FRUITNNUT': Colors.orange.shade300,
      'STRAWBERRY': Colors.pink.shade200,
      'CARAMEL': Colors.orange.shade500,
      'VEGAN': Colors.green.shade300,
    };

    return categoryColors[category.toUpperCase()] ?? Colors.grey.shade300;
  }
}
