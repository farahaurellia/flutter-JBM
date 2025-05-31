import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductPage extends StatefulWidget {
  final String token;
  const ProductPage({Key? key, required this.token}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List products = [];
  List categories = [];
  String? name, description;
  double? price;
  int? categoryId;
  int? editingId;

  final String apiUrl = 'http://127.0.0.1:8000/api/products';
  final String categoryUrl = 'http://127.0.0.1:8000/api/categories';

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse(categoryUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body)['data'];
      });
    }
  }

  Future<void> fetchProducts() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body)['data'];
      });
    }
  }

  Future<void> addOrUpdateProduct({bool isEdit = false}) async {
    final formKey = GlobalKey<FormState>();
    String? tempName = isEdit ? name : null;
    String? tempDesc = isEdit ? description : null;
    double? tempPrice = isEdit ? price : null;
    int? tempCategoryId = isEdit ? categoryId : null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF23234B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit Produk' : 'Tambah Produk',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: tempName,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    onChanged: (v) => tempName = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: tempDesc,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (v) => tempDesc = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: tempPrice != null ? tempPrice.toString() : null,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    onChanged: (v) => tempPrice = double.tryParse(v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: tempCategoryId,
                    dropdownColor: const Color(0xFF23234B),
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    items: categories.map<DropdownMenuItem<int>>((cat) {
                      return DropdownMenuItem<int>(
                        value: cat['id'],
                        child: Text(
                          cat['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    validator: (v) => v == null ? 'Pilih kategori' : null,
                    onChanged: (v) => tempCategoryId = v,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isEdit ? 'Update' : 'Tambah'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  final url = isEdit ? '$apiUrl/$editingId' : apiUrl;
                  final method = isEdit ? http.put : http.post;
                  final response = await method(
                    Uri.parse(url),
                    headers: {
                      'Accept': 'application/json',
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer ${widget.token}',
                    },
                    body: json.encode({
                      'name': tempName,
                      'description': tempDesc,
                      'price': tempPrice,
                      'category_id': tempCategoryId,
                    }),
                  );
                  if (response.statusCode == 201 || response.statusCode == 200) {
                    fetchProducts();
                    setState(() {
                      editingId = null;
                      name = null;
                      description = null;
                      price = null;
                      categoryId = null;
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      fetchProducts();
    }
  }

  void startEdit(Map product) {
    setState(() {
      editingId = product['id'];
      name = product['name'];
      description = product['description'];
      price = product['price'] is int
          ? (product['price'] as int).toDouble()
          : (product['price'] is double ? product['price'] : double.tryParse(product['price'].toString()));
      categoryId = product['category_id'];
    });
    addOrUpdateProduct(isEdit: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181829),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => addOrUpdateProduct(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, i) {
                final prod = products[i];
                final catName = categories.firstWhere(
                  (cat) => cat['id'] == prod['category_id'],
                  orElse: () => {'name': '-'},
                )['name'];
                return ListTile(
                  title: Text(
                    prod['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prod['description'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Harga: ${prod['price']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Kategori: $catName',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () => startEdit(prod),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => deleteProduct(prod['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}