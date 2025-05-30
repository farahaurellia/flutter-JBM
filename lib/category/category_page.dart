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
  final _formKey = GlobalKey<FormState>();
  String? name, description;
  int? editingId;

  // Ganti dengan URL API Anda
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

  Future<void> addOrUpdateCategory() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final url = editingId == null
        ? apiUrl
        : '$apiUrl/$editingId';
    final method = editingId == null ? http.post : http.put;

    final response = await method(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: json.encode({
        'name': name,
        'description': description,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      fetchCategories();
      setState(() {
        editingId = null;
        name = null;
        description = null;
      });
      _formKey.currentState!.reset();
    }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kategori')),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(labelText: 'Nama Kategori'),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    onSaved: (v) => name = v,
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: InputDecoration(labelText: 'Deskripsi'),
                    onSaved: (v) => description = v,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: addOrUpdateCategory,
                        child: Text(editingId == null ? 'Tambah' : 'Update'),
                      ),
                      if (editingId != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              editingId = null;
                              name = null;
                              description = null;
                            });
                            _formKey.currentState!.reset();
                          },
                          child: Text('Batal'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                return ListTile(
                  title: Text(cat['name']),
                  subtitle: Text(cat['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => startEdit(cat),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
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