import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CartService _cartService = CartService();
  final WishlistService _wishlistService = WishlistService();

  bool _isInCart = false;
  bool _isInWishlist = false;
  bool _isLoadingCart = false;
  bool _isLoadingWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkCartStatus();
    _checkWishlistStatus();
  }

  /// Check if product is already in cart
  void _checkCartStatus() async {
    try {
      final cartItems = await _cartService.fetchCartItems();
      setState(() {
        _isInCart = cartItems.any((item) => item.product.id == widget.product.id);
      });
    } catch (e) {
      print("Error checking cart status: $e");
    }
  }

  /// Check if product is already in wishlist
  void _checkWishlistStatus() async {
    try {
      final wishlistItems = await _wishlistService.fetchWishlist();
      setState(() {
        _isInWishlist = wishlistItems.any((item) => item.productId == widget.product.id);
      });
    } catch (e) {
      print("Error checking wishlist status: $e");
    }
  }

  /// Toggle cart status
  void _toggleCart() async {
    setState(() => _isLoadingCart = true);

    try {
      await _cartService.toggleCart(widget.product.id, _isInCart);
      setState(() => _isInCart = !_isInCart);
    } catch (e) {
      print("Error toggling cart: $e");
    }

    setState(() => _isLoadingCart = false);
  }

  /// Toggle wishlist status
  void _toggleWishlist() async {
    setState(() => _isLoadingWishlist = true);

    try {
      String action = _isInWishlist ? "remove the product" : "add";
      await _wishlistService.toggleWishlist(widget.product.id, action);
      setState(() => _isInWishlist = !_isInWishlist);
    } catch (e) {
      print("Error toggling wishlist: $e");
    }

    setState(() => _isLoadingWishlist = false);
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = (widget.product.images.isNotEmpty) ? widget.product.images.first : '';

    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = "https://bars-chocolate.online/storage/$imageUrl";
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, size: 150, color: Colors.red);
              },
            )
                : Icon(Icons.image_not_supported, size: 150, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("${widget.product.currency} ${widget.product.price}", style: TextStyle(fontSize: 18, color: Colors.green)),
                  SizedBox(height: 10),
                  Text(widget.product.description ?? "No description available", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoadingCart ? null : _toggleCart,
                        icon: _isLoadingCart
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(_isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart),
                        label: Text(_isInCart ? "Remove from Cart" : "Add to Cart"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          backgroundColor: _isInCart ? Colors.red : Colors.green,
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: _isLoadingWishlist
                            ? CircularProgressIndicator(strokeWidth: 2)
                            : Icon(
                          _isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: _isInWishlist ? Colors.red : Colors.grey,
                          size: 30,
                        ),
                        onPressed: _isLoadingWishlist ? null : _toggleWishlist,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
