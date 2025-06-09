import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_regina_app/services/product_storage_service.dart';

final productStorageServiceProvider = Provider<ProductStorageService>((ref) {
  return ProductStorageService();
});
