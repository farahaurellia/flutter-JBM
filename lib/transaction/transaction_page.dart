import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransactionPage extends StatefulWidget {
  final String token;
  const TransactionPage({Key? key, required this.token}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List transactions = [];
  List customers = [];
  List products = [];
  int? customerId;
  int? productId;
  int? amount;
  double? price;
  double? totalPrice;
  int? editingId;
  DateTime tempTransactionDate = DateTime.now();

  final String apiUrl = 'http://127.0.0.1:8000/api/transactions';
  final String customerUrl = 'http://127.0.0.1:8000/api/customers';
  final String productUrl = 'http://127.0.0.1:8000/api/products';

  @override
  void initState() {
    super.initState();
    fetchCustomers();
    fetchProducts();
    fetchTransactions();
  }

  Future<void> fetchCustomers() async {
    final response = await http.get(
      Uri.parse(customerUrl),
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

  Future<void> fetchProducts() async {
    final response = await http.get(
      Uri.parse(productUrl),
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

  Future<void> fetchTransactions() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode == 200) {
      setState(() {
        transactions = json.decode(response.body)['data']['data'];
      });
    }
  }

  Future<void> addOrUpdateTransaction({bool isEdit = false}) async {
    final formKey = GlobalKey<FormState>();
    int? tempCustomerId = isEdit ? customerId : null;
    int? tempProductId = isEdit ? productId : null;
    int? tempAmount = isEdit ? amount : null;
    double? tempPrice = isEdit ? price : null;
    double? tempTotalPrice = isEdit ? totalPrice : null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void updatePriceAndTotal(int? selectedProductId, String? amountStr) {
              final selectedProduct = products.firstWhere(
                (p) => p['id'] == selectedProductId,
                orElse: () => null,
              );
              double? newPrice = selectedProduct != null ? (selectedProduct['price'] is int
                  ? (selectedProduct['price'] as int).toDouble()
                  : (selectedProduct['price'] is double
                      ? selectedProduct['price']
                      : double.tryParse(selectedProduct['price'].toString()))) : null;
              int? newAmount = int.tryParse(amountStr ?? '') ?? tempAmount;
              setStateDialog(() {
                tempPrice = newPrice;
                tempTotalPrice = (newPrice ?? 0) * (newAmount ?? 0);
              });
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF23234B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEdit ? 'Edit Transaksi' : 'Tambah Transaksi',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        value: tempCustomerId,
                        dropdownColor: const Color(0xFF23234B),
                        decoration: const InputDecoration(
                          labelText: 'Customer',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        items: customers.map<DropdownMenuItem<int>>((cust) {
                          return DropdownMenuItem<int>(
                            value: cust['id'],
                            child: Text(
                              cust['name'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        validator: (v) => v == null ? 'Pilih customer' : null,
                        onChanged: (v) {
                          setStateDialog(() {
                            tempCustomerId = v;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: tempProductId,
                        dropdownColor: const Color(0xFF23234B),
                        decoration: const InputDecoration(
                          labelText: 'Produk',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        items: products.map<DropdownMenuItem<int>>((prod) {
                          return DropdownMenuItem<int>(
                            value: prod['id'],
                            child: Text(
                              prod['name'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        validator: (v) => v == null ? 'Pilih produk' : null,
                        onChanged: (v) {
                          tempProductId = v;
                          updatePriceAndTotal(v, tempAmount?.toString());
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: tempAmount?.toString(),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        onChanged: (v) {
                          tempAmount = int.tryParse(v);
                          updatePriceAndTotal(tempProductId, v);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: tempPrice != null ? tempPrice.toString() : '',
                        ),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Harga Satuan',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: tempTotalPrice != null ? tempTotalPrice.toString() : '',
                        ),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Total Harga',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Transaksi',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        controller: TextEditingController(
                          text: "${tempTransactionDate.year}-${tempTransactionDate.month.toString().padLeft(2, '0')}-${tempTransactionDate.day.toString().padLeft(2, '0')}",
                        ),
                        enabled: false, // readonly
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
                          'customer_id': tempCustomerId,
                          'product_id': tempProductId,
                          'amount': tempAmount,
                          'price': tempPrice,
                          'total_price': tempTotalPrice,
                          'transaction_date': "${tempTransactionDate.year}-${tempTransactionDate.month.toString().padLeft(2, '0')}-${tempTransactionDate.day.toString().padLeft(2, '0')}",
                        }),
                      );
                      if (response.statusCode == 201 || response.statusCode == 200) {
                        fetchTransactions();
                        setState(() {
                          editingId = null;
                          customerId = null;
                          productId = null;
                          amount = null;
                          price = null;
                          totalPrice = null;
                        });
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> deleteTransaction(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      fetchTransactions();
    }
  }

  void startEdit(Map trx) {
    setState(() {
      editingId = trx['id'];
      customerId = trx['customer_id'];
      productId = trx['product_id'];
      amount = trx['amount'];
      price = trx['price'] is int
          ? (trx['price'] as int).toDouble()
          : (trx['price'] is double ? trx['price'] : double.tryParse(trx['price'].toString()));
      totalPrice = trx['total_price'] is int
          ? (trx['total_price'] as int).toDouble()
          : (trx['total_price'] is double ? trx['total_price'] : double.tryParse(trx['total_price'].toString()));
    });
    addOrUpdateTransaction(isEdit: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181829),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => addOrUpdateTransaction(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, i) {
                final trx = transactions[i];
                final customerName = customers.firstWhere(
                  (c) => c['id'] == trx['customer_id'],
                  orElse: () => {'name': '-'},
                )['name'];
                final productName = products.firstWhere(
                  (p) => p['id'] == trx['product_id'],
                  orElse: () => {'name': '-'},
                )['name'];
                return ListTile(
                  title: Text(
                    'Customer: $customerName',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produk: $productName',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Jumlah: ${trx['amount']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Harga Satuan: ${trx['price']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Total Harga: ${trx['total_price']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () => startEdit(trx),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => deleteTransaction(trx['id']),
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