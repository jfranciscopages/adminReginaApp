import 'package:admin_regina_app/domain/product.dart';
import 'package:admin_regina_app/presentation/screens/add_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showAddProductForm = false;

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
          _buildProductSection(products),
          const Center(child: Text('Servicios (próximamente)')),
        ],
      ),
    );
  }

  Widget _buildProductSection(List<Product> products) {
    if (_showAddProductForm) {
      return AddProductScreen(
        onCancel: () => setState(() => _showAddProductForm = false),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _showAddProductForm = true),
              icon: const Icon(Icons.add),
              label: const Text("Agregar producto"),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (products.isEmpty) {
                return const Center(child: Text('No hay productos aún.'));
              }

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
          ),
        ),
      ],
    );
  }
}
