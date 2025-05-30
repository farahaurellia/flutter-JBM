import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
      ),
      body: const Center(
        child: Text(
          'Halaman Product (Placeholder)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}