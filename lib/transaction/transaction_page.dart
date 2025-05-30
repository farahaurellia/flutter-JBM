import 'package:flutter/material.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction'),
      ),
      body: const Center(
        child: Text(
          'Halaman Transaction (Placeholder)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}