import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddServiceScreen extends StatefulWidget {
  final VoidCallback onCancel;

  const AddServiceScreen({super.key, required this.onCancel});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _timesController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('services')
          .add({
            'name': _nameController.text.trim(),
            'description': _descriptionController.text.trim(),
            'times': _timesController.text.trim(),
            'price': int.parse(_priceController.text.trim()),
            'imageUrl': _imageUrlController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'deletedAt': null,
            'status': 'active',
          });

      await docRef.update({'id': docRef.id});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Servicio agregado correctamente'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

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
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre del servicio'),
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
                        controller: _timesController,
                        decoration: const InputDecoration(labelText: 'Duración del servicio'),
                        validator:
                            (val) =>
                                val == null || val.isEmpty ? 'Requerido' : null,
                      ),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Precio del servicio'),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Requerido';
                          if (int.tryParse(val) == null)
                            return 'Debe ser un número';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL de imagen',
                        ),
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
                            child: const Text('Guardar'),
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
