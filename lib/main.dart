import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'category/category_page.dart';
import 'customer/customer_page.dart';
import 'product/product_page.dart';
import 'transaction/transaction_page.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jual Beli Mobil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF181829),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF181829),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF23234B),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white54, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          labelStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white70),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white70),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          primary: Color(0xFF4B2067), // ungu tua
          secondary: Color(0xFF23234B), // biru tua
        ),
      ),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? errorMessage;

  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse(isLogin ? '$baseUrl/login' : '$baseUrl/register');

      final body = isLogin
          ? {
              'email': _emailController.text,
              'password': _passwordController.text,
            }
          : {
              'name': _nameController.text,
              'email': _emailController.text,
              'password': _passwordController.text,
              'password_confirmation': _passwordController.text,
            };

      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: body,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['access_token'] != null) {
        final token = data['access_token'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(token: token ?? ''),
          ),
        );
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Gagal ${isLogin ? "login" : "register"}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan koneksi';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleForm() {
    setState(() {
      isLogin = !isLogin;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181829),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tambahkan label besar di atas form
                Text(
                  isLogin ? 'Login' : 'Register',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 32),
                if (!isLogin)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      prefixIcon: Icon(Icons.person),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Nama wajib diisi'
                        : null,
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Email wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Password wajib diisi'
                      : null,
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4B2067), // ungu tua untuk teks/icon
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      isLogin ? Icons.login : Icons.app_registration,
                      color: const Color(0xFF4B2067),
                    ),
                    label: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFF4B2067),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isLogin ? 'Login' : 'Register',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF4B2067), // warna terang (ungu tua)
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading ? null : _toggleForm,
                  child: Text(
                    isLogin
                        ? 'Belum punya akun? Register'
                        : 'Sudah punya akun? Login',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
