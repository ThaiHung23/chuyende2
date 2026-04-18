class Review {
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'date': date.toIso8601String(),
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    userName: json['userName'],
    rating: json['rating'].toDouble(),
    comment: json['comment'],
    date: DateTime.parse(json['date']),
  );
}