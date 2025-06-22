import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String userId;
  final String serviceId;
  final DateTime date;
  final String status;
  final DateTime createdAt;
  final DateTime? deletedAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.date,
    required this.status,
    required this.createdAt,
    this.deletedAt,
  });

  factory Appointment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return Appointment(
      id: doc.id,
      userId: data['userId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'activo',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deletedAt:
          data['deletedAt'] != null
              ? (data['deletedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'serviceId': serviceId,
      'date': Timestamp.fromDate(date),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }
}
