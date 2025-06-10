import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_regina_app/services/storage_service.dart';

final storageProvider = Provider<Storage>((ref) {
  return Storage();
});

