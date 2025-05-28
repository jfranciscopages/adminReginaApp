import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_regina_app/domain/service.dart';

class ServiceProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Service>> getServicesStream() {
    return _firestore.collection('services').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Service.fromFirestore(doc, null)).toList();
    });
  }

  Future<void> addService(Service service) {
    final docRef = _firestore.collection('services').doc();
    return docRef.set(service.toFirestore()..['createdAt'] = Timestamp.now());
  }
}
