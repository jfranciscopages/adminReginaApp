import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_regina_app/domain/service.dart';

final serviceProvider = StreamProvider<List<Service>>((ref) {
  return FirebaseFirestore.instance
      .collection('services')
      .where('status', isEqualTo: 'active')
      .withConverter<Service>(
        fromFirestore: Service.fromFirestore,
        toFirestore: (service, _) => service.toFirestore(),
      )
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});

final serviceNameProvider = FutureProvider.family<String, String>((
  ref,
  serviceId,
) async {
  final doc =
      await FirebaseFirestore.instance
          .collection('services')
          .doc(serviceId)
          .get();

  if (!doc.exists) throw Exception('Servicio no encontrado');

  final service = Service.fromFirestore(doc, null);
  return service.name;
});
