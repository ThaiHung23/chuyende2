import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat_message.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => _messages;

  ChatProvider() {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('chat_messages');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _messages = jsonList.map((e) => ChatMessage.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('chat_messages', data);
  }

  void addMessage(String sender, String text) {
    _messages.add(ChatMessage(
      sender: sender,           // 'customer' hoặc 'admin'
      text: text,
      time: DateTime.now(),
    ));
    _saveMessages();
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _saveMessages();
    notifyListeners();
  }
}