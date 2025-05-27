import 'package:admin_regina_app/domain/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<List<Product>>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Regina App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Productos'), Tab(text: 'Servicios')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductTable(products),
          const Center(child: Text('Servicios (próximamente)')),
        ],
      ),
    );
  }

  Widget _buildProductTable(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text('No hay productos aún.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 56,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Nombre',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Descripción',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Precio',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],

                  rows:
                      products.map((product) {
                        return DataRow(
                          cells: [
                            DataCell(Text(product.name)),
                            DataCell(Text(product.description)),
                            DataCell(Text('\$${product.price}')),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
