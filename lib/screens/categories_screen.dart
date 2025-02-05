import 'package:bar_chocolate_app/screens/shop_screen.dart';
import 'package:flutter/material.dart';


class CategoriesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {"title": "DARK", "image": "assets/dark.png", "color": Colors.brown[800]},
    {"title": "WHITE", "image": "assets/dark.png", "color": Colors.amber[100]},
    {"title": "MILK", "image": "assets/dark.png", "color": Colors.brown[300]},
    {"title": "FRUIT&NUT", "image": "assets/dark.png", "color": Colors.orange[300]},
    {"title": "STRAWBERRY", "image": "assets/dark.png", "color": Colors.pink[300]},
    {"title": "CARAMEL", "image": "assets/dark.png", "color": Colors.orange[800]},
    {"title": "VEGAN", "image": "assets/dark.png", "color": Colors.green[300]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Categories")),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductListScreen(selectedCategory: category["title"]),
                ),
              );
            },
            child: Container(
              height: 180, // Box size
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: category["color"],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category["title"],
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Explore the best ${category["title"].toLowerCase()}!",
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      category["image"],
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
