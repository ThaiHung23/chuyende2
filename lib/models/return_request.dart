enum ReturnType { returnOnly, exchange }

class ReturnRequest {
  final String id;
  final String orderId;
  final DateTime requestDate;
  final ReturnType type;
  final String reason;
  final String? newProductId; // Nếu đổi hàng
  String status; // 'Đang xử lý', 'Đã duyệt', 'Từ chối'

  ReturnRequest({
    required this.id,
    required this.orderId,
    required this.type,
    required this.reason,
    this.newProductId,
    this.status = 'Đang xử lý',
  }) : requestDate = DateTime.now();

  String get typeText => type == ReturnType.returnOnly ? 'Trả hàng' : 'Đổi hàng';
}