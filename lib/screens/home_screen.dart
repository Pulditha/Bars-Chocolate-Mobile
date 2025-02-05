import 'package:bar_chocolate_app/screens/product_detail_screen.dart';
import 'package:bar_chocolate_app/screens/shop_screen.dart';
import 'package:bar_chocolate_app/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  String name = '';
  late Future<List<Product>> _discountedProducts;
  late Future<List<Product>> _nonDiscountedProducts;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _loadName();
    _discountedProducts = _fetchDiscountedProducts();
    _nonDiscountedProducts = _fetchNonDiscountedProducts();
  }

  Future<void> _loadName() async {
    AuthService authService = AuthService();
    String? username = await authService.getUsername();
    setState(() {
      name = username ?? 'Guest';
    });
  }

  Future<List<Product>> _fetchDiscountedProducts() async {
    try {
      List<Product> products = await _productService.fetchProducts();
      return products.where((product) => product.discountPrice != null)
          .toList();
    } catch (e) {
      print("Error fetching discounted products: $e");
      return [];
    }
  }

  Future<List<Product>> _fetchNonDiscountedProducts() async {
    try {
      List<Product> products = await _productService.fetchProducts();
      return products.where((product) => product.discountPrice == null)
          .toList();
    } catch (e) {
      print("Error fetching non-discounted products: $e");
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ✅ Welcome Text with Wishlist & Cart Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome, $name!',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700]),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.favorite_border, color: Colors.brown),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WishlistScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon:
                      Icon(Icons.shopping_cart_outlined, color: Colors.brown),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CartScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),

            // ✅ Chocolate Info Section
            Container(
              height: 180,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.brown.shade400,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  SizedBox(height: 10),
                  Text(
                    'Discover the Best Chocolate',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Premium chocolates crafted with love. Enjoy the rich flavors today!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // ✅ Categories Section (Horizontal Scroll)
            Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 110, // Adjusted height
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryItem('DARK', 'assets/dark.png',
                      Colors.brown.shade900),
                  _buildCategoryItem(
                      'MILK', 'assets/dark.png', Colors.brown.shade300),
                  _buildCategoryItem(
                      'WHITE', 'assets/dark.png', Colors.amber.shade100),
                  _buildCategoryItem('FRUIT&NUT', 'assets/dark.png',
                      Colors.orange.shade300),
                  _buildCategoryItem(
                      'STRAWBERRY', 'assets/dark.png', Colors.pink.shade200),
                  _buildCategoryItem(
                      'CARAMEL', 'assets/dark.png', Colors.orange.shade500),
                  _buildCategoryItem(
                      'VEGAN', 'assets/dark.png', Colors.green.shade300),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ✅ Discounted Products Section
            Text(
              'Discounted Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 220,
              child: FutureBuilder<List<Product>>(
                future: _discountedProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error loading products"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text("No discounted products available"));
                  }
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: snapshot.data!.map((product) =>
                        _buildDiscountedProduct(product)).toList(),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // ✅ More Products Section
            Text(
              'More Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            FutureBuilder<List<Product>>(
              future: _nonDiscountedProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading products"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No more products available"));
                }
                return GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.7,
                  children: snapshot.data!.map((product) =>
                      _buildBigProductItem(product)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, String imagePath, Color bgColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListScreen(selectedCategory: title),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 40),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountedProduct(Product product) {
    String imageUrl = product.images.isNotEmpty ? product.images.first : '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = "https://bars-chocolate.online/storage/$imageUrl";
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            width: 180,
            margin: EdgeInsets.only(right: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  imageUrl.isNotEmpty ? imageUrl : 'assets/placeholder.png',
                  height: 70,
                ),
                SizedBox(height: 10),
                Text(
                  product.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  "${product.currency} ${product.price}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Text(
                "Save RS ${product.discountPrice}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBigProductItem(Product product) {
    String imageUrl = product.images.isNotEmpty ? product.images.first : '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = "https://bars-chocolate.online/storage/$imageUrl";
    }

    // Category-based color mapping
    Map<String, Color> categoryColors = {
      'DARK': Colors.brown.shade900,
      'MILK': Colors.brown.shade300,
      'WHITE': Colors.amber.shade100,
      'FRUITNNUT': Colors.orange.shade300,
      'STRAWBERRY': Colors.pink.shade200,
      'CARAMEL': Colors.orange.shade500,
      'VEGAN': Colors.green.shade300,
    };

    Color cardColor = categoryColors[product.category.toUpperCase()] ?? Colors.grey.shade200;

    return LayoutBuilder(
      builder: (context, constraints) {
        double imageSize = constraints.maxWidth < 150 ? 70 : 100; // Adjust image size for smaller screens
        double textSize = constraints.maxWidth < 150 ? 14 : 16; // Adjust text size for readability
        double priceTextSize = constraints.maxWidth < 150 ? 14 : 16;
        double iconSize = constraints.maxWidth < 150 ? 20 : 24;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl.isNotEmpty ? imageUrl : 'assets/placeholder.png',
                        height: imageSize, // Adjust dynamically
                        width: imageSize, // Adjust dynamically
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      product.name,
                      style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      product.category,
                      style: TextStyle(
                        fontSize: textSize - 2,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "${product.currency} ${product.price}",
                      style: TextStyle(
                        fontSize: priceTextSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: 20), // Reduced space for smaller screens
                  ],
                ),

              ],
            ),
          ),
        );
      },
    );

  }
}