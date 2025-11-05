import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.userId,
    required super.service,
    required super.date,
    required super.price,
    required super.status,
    required super.createdAt,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppointmentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      service: data['service'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      price: (data['price'] ?? 0) as int,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'service': service,
      'date': Timestamp.fromDate(date),
      'price': price,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppointmentModel.fromEntity(Appointment e) {
    return AppointmentModel(
      id: e.id,
      userId: e.userId,
      service: e.service,
      date: e.date,
      price: e.price,
      status: e.status,
      createdAt: e.createdAt,
    );
  }

  Appointment toEntity() => Appointment(
        id: id,
        userId: userId,
        service: service,
        date: date,
        price: price,
        status: status,
        createdAt: createdAt,
      );
}