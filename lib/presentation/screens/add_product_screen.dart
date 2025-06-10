import 'package:admin_regina_app/domain/product.dart';
import 'package:admin_regina_app/presentation/widgets/image_uploader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  final VoidCallback onCancel;
  final Product? productToEdit;
  final bool isEditing;

  const AddProductScreen({
    super.key,
    this.productToEdit,
    this.isEditing = false,
    required this.onCancel,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isSubmitting = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.productToEdit != null) {
      final p = widget.productToEdit!;
      _nameController.text = p.name;
      _descriptionController.text = p.description;
      _priceController.text = p.price.toString();
      _imagePath = p.imagePath;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (widget.isEditing && widget.productToEdit != null) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productToEdit!.id)
            .update({
              'name': _nameController.text.trim(),
              'description': _descriptionController.text.trim(),
              'price': int.parse(_priceController.text.trim()),
              'imagePath': _imagePath,
              'status': 'active',
              'updatedAt': FieldValue.serverTimestamp(),
            });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Producto actualizado correctamente'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Crea producto nuevo
        final docRef = await FirebaseFirestore.instance
            .collection('products')
            .add({
              'name': _nameController.text.trim(),
              'description': _descriptionController.text.trim(),
              'price': int.parse(_priceController.text.trim()),
              'imagePath': _imagePath,
              'createdAt': FieldValue.serverTimestamp(),
              'deletedAt': null,
              'status': 'active',
            });

        await docRef.update({'id': docRef.id});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Producto agregado correctamente'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      widget.onCancel();
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        widget.isEditing
                            ? 'Editar producto'
                            : 'Agregar nuevo producto',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del producto',
                        ),
                        validator:
                            (val) =>
                                val == null || val.isEmpty ? 'Requerido' : null,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción del producto',
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        minLines: 3,
                        keyboardType: TextInputType.multiline,
                        validator:
                            (val) =>
                                val == null || val.isEmpty ? 'Requerido' : null,
                      ),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio del producto',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Requerido';
                          if (int.tryParse(val) == null)
                            return 'Debe ser un número';
                          return null;
                        },
                      ),
                      ImageUploader(
                        itemId:
                            widget.productToEdit?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        initialImagePath: widget.productToEdit?.imagePath,
                        folderName: 'products',
                        onImageUploaded: (path) {
                          setState(() {
                            _imagePath = path;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: widget.onCancel,
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            child: Text(
                              widget.isEditing ? 'Actualizar' : 'Guardar',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
