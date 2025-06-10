import 'package:admin_regina_app/domain/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PurchaseOrderProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PurchaseOrder>> getOrdersStream() {
    return _firestore
        .collection('purchaseOrders')
        .where('deletedAt', isNull: true)
        .withConverter<PurchaseOrder>(
          fromFirestore: PurchaseOrder.fromFirestore,
          toFirestore: (order, _) => order.toFirestore(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}