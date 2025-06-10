import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage({
    required String folder,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final ref = _storage.ref().child('$folder/$fileName');

    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final uploadTask = await ref.putData(bytes, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> getImagePath({
    required String folder,
    required String fileName,
  }) async {
    final ref = _storage.ref().child('$folder/$fileName');
    return await ref.getDownloadURL();
  }
}
