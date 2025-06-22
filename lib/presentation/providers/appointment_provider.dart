import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_regina_app/domain/appointment.dart';

final appointmentProvider = StreamProvider<List<Appointment>>((ref) {
  return FirebaseFirestore.instance
      .collection('appointments')
      .where('deletedAt', isNull: true)
      .withConverter<Appointment>(
        fromFirestore: Appointment.fromFirestore,
        toFirestore: (appointment, _) => appointment.toFirestore(),
      )
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});
