import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomerPage extends StatefulWidget {
  final String token;
  const CustomerPage({Key? key, required this.token}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  List customers = [];
  String? name, email, phone, address;
  int? editingId;

  final String apiUrl = 'http://127.0.0.1:8000/api/customers';

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        customers = json.decode(response.body)['data'];
      });
    }
  }

  Future<void> addOrUpdateCustomer({bool isEdit = false}) async {
    final formKey = GlobalKey<FormState>();
    String? tempName = isEdit ? name : null;
    String? tempEmail = isEdit ? email : null;
    String? tempPhone = isEdit ? phone : null;
    String? tempAddress = isEdit ? address : null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF23234B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit Customer' : 'Tambah Customer',
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
                      labelText: 'Nama',
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
                    initialValue: tempEmail,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    onChanged: (v) => tempEmail = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: tempPhone,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'No. Telepon',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    onChanged: (v) => tempPhone = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: tempAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    onChanged: (v) => tempAddress = v,
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
                      'email': tempEmail,
                      'phone': tempPhone,
                      'address': tempAddress,
                    }),
                  );
                  if (response.statusCode == 201 || response.statusCode == 200) {
                    fetchCustomers();
                    setState(() {
                      editingId = null;
                      name = null;
                      email = null;
                      phone = null;
                      address = null;
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

  Future<void> deleteCustomer(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      fetchCustomers();
    }
  }

  void startEdit(Map customer) {
    setState(() {
      editingId = customer['id'];
      name = customer['name'];
      email = customer['email'];
      phone = customer['phone'];
      address = customer['address'];
    });
    addOrUpdateCustomer(isEdit: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181829),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => addOrUpdateCustomer(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, i) {
                final cust = customers[i];
                return ListTile(
                  title: Text(
                    cust['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cust['email'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        cust['phone'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        cust['address'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () => startEdit(cust),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => deleteCustomer(cust['id']),
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