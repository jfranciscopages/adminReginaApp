import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_regina_app/domain/service.dart';

class ServiceProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Service>> getServicesStream() {
    return _firestore
        .collection('services')
        .where('status', isEqualTo: 'active')
        .withConverter<Service>(
          fromFirestore: Service.fromFirestore,
          toFirestore: (service, _) => service.toFirestore(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addService(Service service) {
    final docRef = _firestore.collection('services').doc();
    return docRef.set(service.toFirestore()..['createdAt'] = Timestamp.now());
  }
}
