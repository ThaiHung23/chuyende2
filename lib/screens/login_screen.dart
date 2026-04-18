import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sports_kabaddi, size: 100, color: Colors.red),
              const SizedBox(height: 20),
              const Text('Anh em chat Store', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text('Quản lý bán giày thể thao online', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  authProvider.login('customer');
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                child: const Text('Đăng nhập với tư cách Khách hàng', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  authProvider.login('admin');
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                child: const Text('Đăng nhập với tư cách Quản trị viên', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}