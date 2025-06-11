import 'package:admin_regina_app/domain/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userNameProvider = FutureProvider.family<String, String>((
  ref,
  userId,
) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (!doc.exists) throw Exception('Usuario no encontrado');

  final user = User.fromFirestore(doc, null);
  return '${user.name} ${user.surname}';
});
