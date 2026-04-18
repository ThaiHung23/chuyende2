class ChatMessage {
  final String sender;   // 'customer' hoặc 'admin'
  final String text;
  final DateTime time;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'text': text,
    'time': time.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    sender: json['sender'],
    text: json['text'],
    time: DateTime.parse(json['time']),
  );
}