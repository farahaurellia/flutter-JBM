import 'package:flutter/material.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer'),
      ),
      body: const Center(
        child: Text(
          'Halaman Customer (Placeholder)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}