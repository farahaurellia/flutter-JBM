// file: category_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoryPage extends StatefulWidget {
  final String token;
  const CategoryPage({Key? key, required this.token}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List categories = [];
  String? name, description;
  int? editingId;

  final String apiUrl = 'http://127.0.0.1:8000/api/categories';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse(apiUrl), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    });
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body)['data'];
      });
    }
  }

  Future<void> addOrUpdateCategory({bool isEdit = false}) async {
    final formKey = GlobalKey<FormState>();
    String? tempName = isEdit ? name : null;
    String? tempDesc = isEdit ? description : null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF23234B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit Kategori' : 'Tambah Kategori',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: tempName,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
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
              ],
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
                    }),
                  );
                  if (response.statusCode == 201 || response.statusCode == 200) {
                    fetchCategories();
                    setState(() {
                      editingId = null;
                      name = null;
                      description = null;
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

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      fetchCategories();
    }
  }

  void startEdit(Map category) {
    setState(() {
      editingId = category['id'];
      name = category['name'];
      description = category['description'];
    });
    addOrUpdateCategory(isEdit: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181829),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => addOrUpdateCategory(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                return ListTile(
                  title: Text(
                    cat['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    cat['description'] ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () => startEdit(cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => deleteCategory(cat['id']),
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