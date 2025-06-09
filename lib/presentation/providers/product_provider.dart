import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_regina_app/domain/product.dart';

final productProvider = StreamProvider<List<Product>>((ref) {
  return FirebaseFirestore.instance
      .collection('products')
      .where('status', isEqualTo: 'active')
      .withConverter<Product>(
        fromFirestore: Product.fromFirestore,
        toFirestore: (product, _) => product.toFirestore(),
      )
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});
