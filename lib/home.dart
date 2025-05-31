import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'category/category_page.dart';
import 'customer/customer_page.dart';
import 'product/product_page.dart';
import 'transaction/transaction_page.dart';

class HomePage extends StatefulWidget {
  final String token;
  final String? name;
  final String? email;
  const HomePage({Key? key, required this.token, this.name, this.email}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userName = data['name'];
        userEmail = data['email'];
      });
    }
  }

  // List halaman menu
  List<Widget> get _pages => [
        TransactionPage(token: widget.token),
        ProductPage(token: widget.token),
        CustomerPage(token: widget.token),
        CategoryPage(token: widget.token),
      ];

  // List judul menu
  final List<String> _titles = [
    'Transaksi',
    'Product',
    'Customer',
    'Kategori',
  ];

  // List icon menu
  final List<IconData> _icons = [
    Icons.receipt_long,
    Icons.directions_car,
    Icons.people,
    Icons.category,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showProfileSidebar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF181829), // biru tua kehitaman
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFF4B2067), // ungu tua
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                userName ?? 'Nama Pengguna',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                userEmail ?? 'Email',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Log Out', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B2067), // ungu tua
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup sidebar
                    Navigator.of(context).pop(); // Kembali ke login
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181829), // biru tua kehitaman
      appBar: AppBar(
        backgroundColor: const Color(0xFF181829),
        elevation: 0,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: _showProfileSidebar,
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF181829),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF23234B), // biru tua
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF8F5FE8), // ungu terang
          unselectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0,
          items: List.generate(_titles.length, (i) {
            return BottomNavigationBarItem(
              icon: Icon(_icons[i]),
              label: _titles[i],
            );
          }),
        ),
      ),
    );
  }
}