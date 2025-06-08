import 'package:admin_regina_app/domain/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class PurchaseOrder {
  final String id;
  final String status;
  final double totalPrice;
  final String userId;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final List<CartItem> items;

  PurchaseOrder({
    required this.id,
    required this.status,
    required this.totalPrice,
    required this.userId,
    required this.createdAt,
    this.deletedAt,
    required this.items,
  });

  factory PurchaseOrder.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return PurchaseOrder(
      id: snapshot.id,
      status: data['status'],
      totalPrice: (data['totalPrice'] as num).toDouble(),
      userId: data['userId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deletedAt: data['deletedAt'] != null
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
      items: (data['items'] as List)
          .map((item) => CartItem.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'status': status,
      'totalPrice': totalPrice,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}
