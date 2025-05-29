import 'package:admin_regina_app/domain/product.dart';
import 'package:admin_regina_app/domain/service.dart';
import 'package:admin_regina_app/presentation/screens/add_product_screen.dart';
import 'package:admin_regina_app/presentation/screens/add_service_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _showAddServiceForm = false;
  Service? _serviceToEdit;
  Product? _productToEdit;
  bool _isEditingProduct = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<List<Product>>();
    final services = context.watch<List<Service>>();

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
          _buildServiceSection(services),
        ],
      ),
    );
  }

  Widget _buildProductSection(List<Product> products) {
    if (_showAddProductForm) {
      return AddProductScreen(
        onCancel: () {
          setState(() {
            _showAddProductForm = false;
            _isEditingProduct = false;
            _productToEdit = null;
          });
        },
        isEditing: _isEditingProduct,
        productToEdit: _productToEdit,
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
                  child: Align(
                    alignment: Alignment.topCenter,
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
                          DataColumn(label: Text('')),
                        ],
                        rows:
                            products.map((product) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(product.name)),
                                  DataCell(Text(product.description)),
                                  DataCell(Text('\$${product.price}')),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _showAddProductForm = true;
                                              _productToEdit = product;
                                              _isEditingProduct = true;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                          onPressed:
                                              () => _confirmDeleteProduct(
                                                product,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
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

  void _confirmDeleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Seguro que querés eliminar "${product.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Eliminar',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'status': 'inactive', 'deletedAt': Timestamp.now()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto eliminado correctamente.'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    }
  }

  Widget _buildServiceSection(List<Service> services) {
    if (_showAddServiceForm) {
      return AddServiceScreen(
        serviceToEdit: _serviceToEdit,
        isEditing: _serviceToEdit != null,
        onCancel:
            () => setState(() {
              _showAddServiceForm = false;
              _serviceToEdit = null;
            }),
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
              onPressed:
                  () => setState(() {
                    _serviceToEdit = null;
                    _showAddServiceForm = true;
                  }),
              icon: const Icon(Icons.add),
              label: const Text("Agregar servicio"),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (services.isEmpty) {
                return const Center(child: Text('No hay servicios aún.'));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Align(
                    alignment: Alignment.topCenter,
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
                              'Duración',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Precio',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(label: Text('')),
                        ],
                        rows:
                            services.map((service) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(service.name)),
                                  DataCell(Text(service.description)),
                                  DataCell(Text(service.times)),
                                  DataCell(Text('\$${service.price}')),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                          ),
                                          onPressed:
                                              () => setState(() {
                                                _serviceToEdit = service;
                                                _showAddServiceForm = true;
                                              }),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                          onPressed:
                                              () => _confirmDeleteService(
                                                service,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
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

  void _confirmDeleteService(Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Seguro que querés eliminar "${service.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Eliminar',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(service.id)
          .update({'status': 'inactive', 'deletedAt': Timestamp.now()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Servicio eliminado correctamente.'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    }
  }
}
