import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = (product.images.isNotEmpty) ? product.images.first : '';

    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = "https://bars-chocolate.online/storage/$imageUrl";
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
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
                  Text(product.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("${product.currency} ${product.price}", style: TextStyle(fontSize: 18, color: Colors.green)),
                  SizedBox(height: 10),
                  Text(product.description ?? "No description available", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
