import 'package:bar_chocolate_app/screens/shop_screen.dart';
import 'package:bar_chocolate_app/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    AuthService authService = AuthService();
    String? username = await authService.getUsername();
    setState(() {
      name = username ?? 'Guest';
    });
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
                color: Colors.brown.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Discover the Best Chocolate',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
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
                  _buildCategoryItem('FRUIT & NUT', 'assets/dark.png',
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
              height: 220, // Adjusted height
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildDiscountedProduct('Deluxe Chocolate Box', 'assets/dark.png'),
                  _buildDiscountedProduct('Milk Chocolate Pack', 'assets/dark.png'),
                  _buildDiscountedProduct('Hazelnut Choco', 'assets/dark.png'),
                  _buildDiscountedProduct('Strawberry Delight', 'assets/dark.png'),
                  _buildDiscountedProduct('Vegan Dark Chocolate', 'assets/dark.png'),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ✅ More Products Section
            Text(
              'More Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Grid layout for two columns
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7, // Adjusted for smaller screens
              children: [
                _buildBigProductItem('Classic Chocolate Bar', 'assets/dark.png'),
                _buildBigProductItem('Almond Chocolate', 'assets/dark.png'),
                _buildBigProductItem('Truffle Selection', 'assets/dark.png'),
                _buildBigProductItem('Caramel Bliss', 'assets/dark.png'),
              ],
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
                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountedProduct(String title, String imagePath) {
    return Container(
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
          Image.asset(imagePath, height: 70),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBigProductItem(String title, String imagePath) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Image.asset(imagePath, height: 100, fit: BoxFit.cover),
          SizedBox(height: 10),
          Text(title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
