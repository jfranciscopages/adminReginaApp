import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  String id;
  String name;
  String description;
  int price;
  String times;
  int duration;
  String? imageUrl;
  String? imagePath;
  String status;
  DateTime? createdAt;
  DateTime? deletedAt;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.times,
    required this.duration,
    this.imageUrl,
    this.imagePath,
    this.status = 'active',
    this.createdAt,
    this.deletedAt,
  });

  factory Service.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return Service(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: data['price'] ?? 0,
      times: data['times'] ?? '',
      duration: data['duration'] ?? 60,
      imageUrl: data['imageUrl'],
      imagePath: data['imagePath'],
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'times': times,
      'duration': duration,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'status': status,
      'createdAt': createdAt,
      'deletedAt': deletedAt,
    };
  }
}