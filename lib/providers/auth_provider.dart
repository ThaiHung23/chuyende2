import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  String? _role;
  String? get role => _role;

  Future<void> loadUserRole() async {
    if (currentUser == null) return;
    try {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      _role = doc.data()?['role'] ?? 'customer';
      notifyListeners();
    } catch (e) {
      _role = 'customer';
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await loadUserRole();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleError(e.code));
    }
  }

  Future<void> register(String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firestore.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _role = 'customer';
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleError(e.code));
    }
  }

  String _handleError(String code) {
    switch (code) {
      case 'user-not-found': return 'Không tìm thấy tài khoản';
      case 'wrong-password': return 'Mật khẩu sai';
      case 'email-already-in-use': return 'Email đã tồn tại';
      default: return 'Lỗi đăng nhập: $code';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _role = null;
    notifyListeners();
  }
}