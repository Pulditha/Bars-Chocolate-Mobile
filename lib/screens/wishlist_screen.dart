import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  final CartService _cartService = CartService();
  List<Product> _wishlistItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  /// Fetch wishlist items
  void _fetchWishlist() async {
    try {
      final items = await _wishlistService.fetchWishlist();
      setState(() {
        _wishlistItems = items.map((item) => item.product).toList();
      });
    } catch (e) {
      print("Error fetching wishlist: $e");
    }
  }

  /// Move all wishlist items to cart
  void _moveAllToCart() async {
    if (_wishlistItems.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      for (var product in _wishlistItems) {
        await _wishlistService.toggleWishlist(product.id, "remove the product");
        await _cartService.toggleCart(product.id, false);
      }

      setState(() {
        _wishlistItems.clear(); // Clear wishlist after moving
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All items moved to cart!")),
      );
    } catch (e) {
      print("Error moving all products to cart: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wishlist")),
      body: Column(
        children: [
          Expanded(
            child: _wishlistItems.isEmpty
                ? Center(child: Text("Your wishlist is empty"))
                : ListView.builder(
              itemCount: _wishlistItems.length,
              itemBuilder: (context, index) {
                final product = _wishlistItems[index];
                return ListTile(
                  leading: Image.network(
                    "https://bars-chocolate.online/storage/${product.images.isNotEmpty ? product.images.first : ''}",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, size: 50);
                    },
                  ),
                  title: Text(product.name),
                  subtitle: Text("${product.currency} ${product.price}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: _isLoading
                        ? null
                        : () async {
                      await _wishlistService.toggleWishlist(product.id, "remove the product");
                      setState(() => _wishlistItems.removeAt(index));
                    },
                  ),
                );
              },
            ),
          ),
          if (_wishlistItems.isNotEmpty) // Show button only if wishlist is not empty
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _moveAllToCart,
                icon: _isLoading
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.shopping_cart),
                label: Text("Move All to Cart"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
