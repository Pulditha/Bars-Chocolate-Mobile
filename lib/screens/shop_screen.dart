import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _futureProducts;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'DARK',
    'MILK',
    'WHITE',
    'FRUIT & NUT',
    'STRAWBERRY',
    'CARAMEL',
    'VEGAN'
  ];

  @override
  void initState() {
    super.initState();
    _futureProducts = _productService.fetchProducts();
    _futureProducts.then((products) {
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
      });
    });
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProducts = _allProducts.where((product) {
        bool matchesSearch = product.name.toLowerCase().contains(query);
        bool matchesCategory = (_selectedCategory == 'All' || product.category == _selectedCategory);
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
      appBar: AppBar(title: Text("Products")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterProducts(),
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
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
                    selectedColor: Colors.brown,
                    backgroundColor: Colors.grey[300],
                    labelStyle: TextStyle(
                      color: _selectedCategory == category ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
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
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      Product product = _filteredProducts[index];
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                      imageUrl,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(child: CircularProgressIndicator());
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.broken_image, color: Colors.red, size: 80);
                                      },
                                    )
                                        : Icon(Icons.image_not_supported, color: Colors.grey, size: 80),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white.withOpacity(0.8),
                                      child: Icon(Icons.favorite_border, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  product.name,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "${product.currency} ${product.price}",
                                style: TextStyle(fontSize: 14, color: Colors.brown, fontWeight: FontWeight.bold),
                              ),
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
