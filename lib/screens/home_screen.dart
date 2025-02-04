import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> products = [];
  List<dynamic> categories = [];
  List<String> sliderImages = [
    'https://example.com/slider1.jpg',
    'https://example.com/slider2.jpg',
    'https://example.com/slider3.jpg'
  ];
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
  }

  void fetchCategories() async {
    List<dynamic> fetchedCategories = await ProductService().fetchCategories();
    setState(() {
      categories = fetchedCategories;
    });
  }

  void fetchProducts() async {
    List<dynamic> fetchedProducts = await ProductService().fetchProducts();
    setState(() {
      products = fetchedProducts;
    });
  }

  void handleLogout() async {
    await authService.logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onChanged: (value) => fetchProducts(),
              ),
            ),
            IconButton(icon: Icon(Icons.favorite_border), onPressed: () {}),
            IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {}),
            IconButton(icon: Icon(Icons.logout), onPressed: handleLogout),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
              items: sliderImages.map((imageUrl) {
                return Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity);
              }).toList(),
              options: CarouselOptions(height: 200, autoPlay: true),
            ),
            SizedBox(height: 10),
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(categories[index]['image']),
                      ),
                      Text(categories[index]['name']),
                    ],
                  );
                },
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(products[index]['image'], width: 50),
                  title: Text(products[index]['name']),
                  subtitle: Text(products[index]['category']),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
