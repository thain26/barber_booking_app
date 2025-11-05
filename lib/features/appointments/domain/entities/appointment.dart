class Appointment {
  final String id;
  final String userId;
  final String service;
  final DateTime date;
  final int price;
  final String status;
  final DateTime createdAt;

  const Appointment({
    required this.id,
    required this.userId,
    required this.service,
    required this.date,
    required this.price,
    this.status = 'pending',
    required this.createdAt,
  });
}