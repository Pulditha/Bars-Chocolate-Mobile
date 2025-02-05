import 'package:bar_chocolate_app/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String selectedCategory;

  ProductListScreen({required this.selectedCategory});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _futureProducts;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  TextEditingController _searchController = TextEditingController();
  late String _selectedCategory;

  final List<String> _categories = [
    'All',
    'DARK',
    'MILK',
    'WHITE',
    'FRUITNNUT',
    'STRAWBERRY',
    'CARAMEL',
    'VEGAN'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.selectedCategory; // Initialize with selected category
    _futureProducts = _productService.fetchProducts();
    _futureProducts.then((products) {
      setState(() {
        _allProducts = products;
        _filterProducts(); // Apply filtering
      });
    });
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        bool matchesSearch = product.name.toLowerCase().contains(query);
        bool matchesCategory = (_selectedCategory == 'All' ||
            product.category == _selectedCategory);
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Shop",
          style: TextStyle(fontWeight: FontWeight.bold,),
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.brown[800]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WishlistScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.brown[800]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterProducts(),
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: Icon(Icons.search, color: Colors.brown),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // Category Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                String category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (_) => _selectCategory(category),
                    selectedColor: Colors.brown.shade700,
                    backgroundColor: Colors.grey[300],
                    labelStyle: TextStyle(
                      color: _selectedCategory == category
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          // Product Grid
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else {
                  return GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      Product product = _filteredProducts[index];
                      String imageUrl = product.images.isNotEmpty ? product
                          .images.first : '';
                      if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                        imageUrl =
                        "https://bars-chocolate.online/storage/$imageUrl";
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

                      Color cardColor = categoryColors[product.category
                          .toUpperCase()] ?? Colors.grey.shade200;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 6),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Discount Badge (Only if there's a discount)
                              if (product.discountPrice != null &&
                                  double.tryParse(product.discountPrice!) != null &&
                                  double.tryParse(product.price) != null &&
                                  double.parse(product.discountPrice!) < double.parse(product.price))
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                  margin: EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Save RS ${(double.parse(product.price) - double.parse(product.discountPrice!)).toStringAsFixed(2)}",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),

                              // Product Image Section
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                      imageUrl,
                                      height: 120, // Adjusted for better proportions
                                      fit: BoxFit.contain, // Ensures full-width image without distortion
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(child: CircularProgressIndicator());
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 120,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.broken_image, color: Colors.red, size: 50),
                                        );
                                      },
                                    )
                                        : Container(
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Product Name
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  product.name,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: 4),

                              // Product Category
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  product.category,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
                                ),
                              ),
                              SizedBox(height: 4),

                              // Updated Price Section (Without Strikethrough)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "${product.currency} ${product.discountPrice ?? product.price}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Spacer(),

                              // Add to Cart Button

                            ],
                          ),
                        ),

                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}