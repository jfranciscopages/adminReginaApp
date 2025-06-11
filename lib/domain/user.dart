import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  String surname;
  String email;
  String status;
  DateTime? createdAt;
  DateTime? deletedAt;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.status,
    required this.createdAt,
    required this.deletedAt,
  });
  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return User(
      id: doc.id,
      name: data['nombre'] ?? '',
      surname: data['apellido'] ?? '',
      email: data['email'] ?? '',
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': name,
      'apellido': surname,
      'email': email,
      'status': status,
      'createdAt': createdAt,
      'deletedAt': deletedAt,
    };
  }

  String get fullName => '$name $surname';
}
