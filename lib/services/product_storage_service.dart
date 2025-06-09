import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:admin_regina_app/domain/product.dart';

class ProductStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProductImage(Uint8List bytes, String fileName) async {
    final ref = _storage.ref().child('products/$fileName');

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final uploadTask = await ref.putData(bytes, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> getProductImageUrl(Product product) async {
    final ref = _storage.ref().child('products/${product.imagePath}');
    return await ref.getDownloadURL();
  }
}
