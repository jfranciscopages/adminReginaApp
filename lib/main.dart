import 'package:admin_regina_app/presentation/providers/product_provider.dart';
import 'package:admin_regina_app/presentation/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'domain/product.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<List<Product>>(
          create: (_) => ProductProvider().getProductsStream(),
          initialData: const [],
        ),
      ],
      child: const MaterialApp(home: HomePage()),
    ),
  );
}
