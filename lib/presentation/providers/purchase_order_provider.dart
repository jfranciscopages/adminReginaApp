import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_regina_app/domain/order.dart';

final purchaseOrderStreamProvider = StreamProvider<List<PurchaseOrder>>((ref) {
  return FirebaseFirestore.instance
      .collection('purchaseOrders')
      .where('deletedAt', isNull: true)
      .withConverter<PurchaseOrder>(
        fromFirestore: PurchaseOrder.fromFirestore,
        toFirestore: (order, _) => order.toFirestore(),
      )
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});
