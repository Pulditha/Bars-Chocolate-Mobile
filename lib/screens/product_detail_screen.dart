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

    Map<String, Color> categoryColors = {
      'DARK': Colors.brown.shade900,
      'MILK': Colors.brown.shade300,
      'WHITE': Colors.amber.shade100,
      'FRUITNNUT': Colors.orange.shade300,
      'STRAWBERRY': Colors.pink.shade200,
      'CARAMEL': Colors.orange.shade500,
      'VEGAN': Colors.green.shade300,
    };

    Color categoryColor = categoryColors[widget.product.category.toUpperCase()] ?? Colors.grey.shade300;

    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name, style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Category Color Background
            Container(
              width: double.infinity,
              color: categoryColor,
              padding: EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  height: 250,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image, size: 150, color: Colors.red);
                  },
                )
                    : Icon(Icons.image_not_supported, size: 150, color: Colors.grey),
              ),
            ),

            // Add to Cart & Wishlist Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoadingCart ? null : _toggleCart,
                    icon: _isLoadingCart
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(_isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart, color: Colors.white),
                    label: Text(_isInCart ? "Remove from Cart" : "Add to Cart",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
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
            ),
            // Product Details with Discount Badge
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${widget.product.currency} ${widget.product.price}",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  SizedBox(width: 10),

                  // Discount Badge as Circle
                  if (widget.product.discountPrice != null)
                    Container(
                      child: Text(
                        "SAVE RS ${widget.product.discountPrice}",
                        style: TextStyle(color: Colors.red[800], fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

            // Weight
            if (widget.product.weight != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 10),
                child: Text("Weight: ${widget.product.weight}g",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87)),
              ),



            // Product Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(widget.product.description ?? "No description available", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
