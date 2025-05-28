import 'package:admin_regina_app/domain/service.dart';
import 'package:admin_regina_app/presentation/providers/product_provider.dart';
import 'package:admin_regina_app/presentation/providers/service_provider.dart';
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
        StreamProvider<List<Service>>(
          create: (_) => ServiceProvider().getServicesStream(),
          initialData: const [],
        ),
      ],
      child: const AdminReginaApp(),
    ),
  );
}

class AdminReginaApp extends StatelessWidget {
  const AdminReginaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Regina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const HomePage(),
    );
  }
}
