import 'package:admin_regina_app/domain/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Product>> getProductsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('status', isEqualTo: 'active')
        .withConverter<Product>(
          fromFirestore: Product.fromFirestore,
          toFirestore: (product, _) => product.toFirestore(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
