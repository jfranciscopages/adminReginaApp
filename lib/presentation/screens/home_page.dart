import 'package:admin_regina_app/domain/order.dart';
import 'package:admin_regina_app/domain/product.dart';
import 'package:admin_regina_app/domain/service.dart';
import 'package:admin_regina_app/presentation/providers/appointment_provider.dart';
import 'package:admin_regina_app/presentation/providers/product_provider.dart';
import 'package:admin_regina_app/presentation/providers/purchase_order_provider.dart';
import 'package:admin_regina_app/presentation/providers/service_provider.dart';
import 'package:admin_regina_app/presentation/providers/storage_provider.dart';
import 'package:admin_regina_app/presentation/providers/user_provider.dart';
import 'package:admin_regina_app/presentation/screens/add_product_screen.dart';
import 'package:admin_regina_app/presentation/screens/add_service_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showAddProductForm = false;
  bool _showAddServiceForm = false;
  Product? _productToEdit;
  bool _isEditingProduct = false;
  bool _isEditingService = false;
  Service? _serviceToEdit;
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  bool _showOrderDetail = false;
  PurchaseOrder? _selectedOrder;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final services = ref.watch(serviceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Regina App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Productos'),
            Tab(text: 'Servicios'),
            Tab(text: 'Mis ventas'),
            Tab(text: 'Mis turnos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          products.when(
            data: (products) => _buildProductSection(products),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          services.when(
            data: (services) => _buildServiceSection(services),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          _buildSalesSectionWrapper(),
          _buildAppointmentsSection(),
        ],
      ),
    );
  }

  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String newStatus,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Error al actualizar el estado del turno: $e');
    }
  }

  Widget _buildAppointmentsSection() {
    final appointmentsAsync = ref.watch(appointmentProvider);
    const rowsPerPage = 10;

    return appointmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (appointments) {
        appointments.sort((a, b) => b.date.compareTo(a.date));
        final totalPages = (appointments.length / rowsPerPage).ceil();
        final currentPageAppointments =
            appointments
                .skip(_currentPage * rowsPerPage)
                .take(rowsPerPage)
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 24,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 72,
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'Cliente',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Servicio',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Fecha',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Hora',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Estado',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              rows:
                                  currentPageAppointments.map((appointment) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Consumer(
                                            builder: (context, ref, _) {
                                              final asyncName = ref.watch(
                                                userNameProvider(
                                                  appointment.userId,
                                                ),
                                              );
                                              return asyncName.when(
                                                data: (name) => Text(name),
                                                loading:
                                                    () => const Text(
                                                      'Cargando...',
                                                    ),
                                                error:
                                                    (_, __) => const Text(
                                                      'Desconocido',
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                        DataCell(
                                          Consumer(
                                            builder: (context, ref, _) {
                                              final asyncServiceName = ref
                                                  .watch(
                                                    serviceNameProvider(
                                                      appointment.serviceId,
                                                    ),
                                                  );
                                              return asyncServiceName.when(
                                                data: (name) => Text(name),
                                                loading:
                                                    () => const Text(
                                                      'Cargando...',
                                                    ),
                                                error:
                                                    (_, __) => const Text(
                                                      'Desconocido',
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${appointment.date.day.toString().padLeft(2, '0')}/${appointment.date.month.toString().padLeft(2, '0')}/${appointment.date.year}',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${appointment.date.hour.toString().padLeft(2, '0')}:${appointment.date.minute.toString().padLeft(2, '0')}',
                                          ),
                                        ),

                                        DataCell(
                                          DropdownButton<String>(
                                            value: appointment.status,
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'activo',
                                                child: Text('Activo'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'completado',
                                                child: Text('Completado'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'cancelado',
                                                child: Text('Cancelado'),
                                              ),
                                            ],
                                            onChanged: (newValue) async {
                                              if (newValue != null &&
                                                  newValue !=
                                                      appointment.status) {
                                                try {
                                                  await updateAppointmentStatus(
                                                    appointmentId:
                                                        appointment.id,
                                                    newStatus: newValue,
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Estado actualizado a "$newValue"',
                                                      ),
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primaryContainer,
                                                      behavior:
                                                          SnackBarBehavior
                                                              .floating,
                                                      duration: const Duration(
                                                        seconds: 2,
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error al actualizar estado: $e',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                      behavior:
                                                          SnackBarBehavior
                                                              .floating,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed:
                        _currentPage > 0
                            ? () => setState(() => _currentPage--)
                            : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text('Página ${_currentPage + 1} de $totalPages'),
                  IconButton(
                    onPressed:
                        (_currentPage + 1) * rowsPerPage < appointments.length
                            ? () => setState(() => _currentPage++)
                            : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSalesSectionWrapper() {
    if (_showOrderDetail && _selectedOrder != null) {
      return Consumer(
        builder: (context, ref, _) {
          final asyncName = ref.watch(userNameProvider(_selectedOrder!.userId));

          return asyncName.when(
            data: (name) => _buildOrderDetailView(_selectedOrder!, name),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (_, __) => _buildOrderDetailView(
                  _selectedOrder!,
                  'Cliente desconocido',
                ),
          );
        },
      );
    } else {
      return _buildSalesTable();
    }
  }

  Widget _buildProductSection(List<Product> products) {
    if (_showAddProductForm || _isEditingProduct) {
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
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: 1000,
                  ),
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
                              'Producto',
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
                                  DataCell(
                                    FutureBuilder<String>(
                                      future: ref
                                          .read(storageProvider)
                                          .getImagePath(
                                            folder: 'products',
                                            fileName: product.imagePath ?? '',
                                          ),
                                      builder: (context, snapshot) {
                                        Widget imageWidget;

                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          imageWidget = const SizedBox(
                                            width: 40,
                                            height: 40,
                                          );
                                        } else if (snapshot.hasError ||
                                            !snapshot.hasData) {
                                          imageWidget = const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                          );
                                        } else {
                                          imageWidget = Image.network(
                                            snapshot.data!,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                    ),
                                          );
                                        }

                                        return Row(
                                          children: [
                                            imageWidget,
                                            const SizedBox(width: 8),
                                            Container(
                                              constraints: const BoxConstraints(
                                                maxWidth: 180,
                                              ),
                                              child: Text(
                                                product.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 400,
                                      ),
                                      child: Text(
                                        product.description,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
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
    if (_showAddServiceForm || _isEditingService) {
      return AddServiceScreen(
        onCancel: () {
          setState(() {
            _showAddServiceForm = false;
            _isEditingService = false;
            _serviceToEdit = null;
          });
        },
        isEditing: _isEditingService,
        serviceToEdit: _serviceToEdit,
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
                              'Servicio',
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
                                  DataCell(
                                    FutureBuilder<String>(
                                      future: ref
                                          .read(storageProvider)
                                          .getImagePath(
                                            folder: 'services',
                                            fileName: service.imagePath ?? '',
                                          ),
                                      builder: (context, snapshot) {
                                        Widget imageWidget;

                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          imageWidget = const SizedBox(
                                            width: 40,
                                            height: 40,
                                          );
                                        } else if (snapshot.hasError ||
                                            !snapshot.hasData) {
                                          imageWidget = const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                          );
                                        } else {
                                          imageWidget = Image.network(
                                            snapshot.data!,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.broken_image,
                                                      size: 40,
                                                    ),
                                          );
                                        }

                                        return Row(
                                          children: [
                                            imageWidget,
                                            const SizedBox(width: 8),
                                            Container(
                                              constraints: const BoxConstraints(
                                                maxWidth: 180,
                                              ),
                                              child: Text(
                                                service.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 400,
                                      ),
                                      child: Text(
                                        service.description,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
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
                                          onPressed: () {
                                            setState(() {
                                              _isEditingService = true;
                                              _serviceToEdit = service;
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

  Widget _buildSalesTable() {
    final ordersAsync = ref.watch(purchaseOrderStreamProvider);

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (orders) {
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final paginatedOrders =
            orders
                .skip(_currentPage * _rowsPerPage)
                .take(_rowsPerPage)
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 24,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 72,
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'Cliente',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Estado',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Total',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Fecha',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Detalle',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              rows:
                                  paginatedOrders.map((order) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Consumer(
                                            builder: (context, ref, _) {
                                              final asyncName = ref.watch(
                                                userNameProvider(order.userId),
                                              );
                                              return asyncName.when(
                                                data: (name) => Text(name),
                                                loading:
                                                    () => const Text(
                                                      'Cargando...',
                                                    ),
                                                error:
                                                    (_, __) => const Text(
                                                      'Desconocido',
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                        DataCell(Text(order.status)),
                                        DataCell(
                                          Text(
                                            '\$${order.totalPrice.toStringAsFixed(2)}',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year}',
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(
                                              Icons.info_outline,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _selectedOrder = order;
                                                _showOrderDetail = true;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed:
                        _currentPage > 0
                            ? () => setState(() => _currentPage--)
                            : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text('Página ${_currentPage + 1}'),
                  IconButton(
                    onPressed:
                        (_currentPage + 1) * _rowsPerPage < orders.length
                            ? () => setState(() => _currentPage++)
                            : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderDetailView(PurchaseOrder order, String clientName) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _showOrderDetail = false;
                        _selectedOrder = null;
                      });
                    },
                  ),
                  Text(
                    clientName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Estado: ${order.status}'),
                  Text('Total: \$${order.totalPrice.toStringAsFixed(2)}'),
                  Text(
                    'Fecha: ${order.createdAt.toLocal().toString().split(' ').first}',
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Productos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return ListTile(
                        leading:
                            item.product.imagePath != null
                                ? FutureBuilder<String>(
                                  future: ref
                                      .read(storageProvider)
                                      .getImagePath(
                                        folder: 'products',
                                        fileName: item.product.imagePath!,
                                      ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox(
                                        width: 40,
                                        height: 40,
                                      );
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData) {
                                      return const Icon(
                                        Icons.image_not_supported,
                                      );
                                    } else {
                                      return Image.network(
                                        snapshot.data!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                  },
                                )
                                : const Icon(Icons.image_not_supported),
                        title: Text(item.product.name),
                        subtitle: Text('Cantidad: ${item.quantity}'),
                        trailing: Text(
                          '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
