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

  /// Get category-based background color
  Color _getCategoryColor(String category) {
    final Map<String, Color> categoryColors = {
      'DARK': Colors.brown.shade900,
      'MILK': Colors.brown.shade300,
      'WHITE': Colors.amber.shade100,
      'FRUITNNUT': Colors.orange.shade300,
      'STRAWBERRY': Colors.pink.shade200,
      'CARAMEL': Colors.orange.shade500,
      'VEGAN': Colors.green.shade300,
    };
    return categoryColors[category.toUpperCase()] ?? Colors.grey.shade200;
  }

  /// Build Wishlist Item
  Widget _buildWishlistItem(Product product) {
    String imageUrl = product.images.isNotEmpty
        ? "https://bars-chocolate.online/storage/${product.images.first}"
        : "";
    Color categoryColor = _getCategoryColor(product.category);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: categoryColor, // Apply category color
            borderRadius: BorderRadius.circular(10),
            image: imageUrl.isNotEmpty
                ? DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              onError: (error, stackTrace) => null,
            )
                : null,
          ),
          child: imageUrl.isEmpty
              ? Icon(Icons.image_not_supported, size: 30, color: Colors.grey)
              : null,
        ),
        title: Text(
          product.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "${product.currency} ${product.price}",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: _isLoading
              ? null
              : () async {
            await _wishlistService.toggleWishlist(product.id, "remove the product");
            setState(() => _wishlistItems.remove(product));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wishlist")),
      body: Column(
        children: [
          Expanded(
            child: _wishlistItems.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.redAccent),
                  SizedBox(height: 10),
                  Text(
                    "Your wishlist is empty",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _wishlistItems.length,
              itemBuilder: (context, index) {
                return _buildWishlistItem(_wishlistItems[index]);
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
                    : Icon(Icons.shopping_cart, color: Colors.white),
                label: Text("Move All to Cart",style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
