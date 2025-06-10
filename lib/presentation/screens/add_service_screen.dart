import 'package:admin_regina_app/domain/service.dart';
import 'package:admin_regina_app/presentation/widgets/image_uploader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddServiceScreen extends StatefulWidget {
  final VoidCallback onCancel;
  final Service? serviceToEdit;
  final bool isEditing;

  const AddServiceScreen({
    super.key,
    required this.onCancel,
    this.serviceToEdit,
    this.isEditing = false,
  });

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isSubmitting = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.serviceToEdit != null) {
      final s = widget.serviceToEdit!;
      _nameController.text = s.name;
      _descriptionController.text = s.description;
      _priceController.text = s.price.toString();
      _durationController.text = s.duration.toString();
      _imageUrlController.text = s.imageUrl ?? '';
      _imagePath = s.imagePath;
    }
  }

  String generateTimesLabel(int durationInMinutes) {
    if (durationInMinutes > 120) {
      throw ArgumentError('La duración no puede superar los 120 minutos.');
    }

    if (durationInMinutes < 60) {
      return '$durationInMinutes minutos';
    }

    final hours = durationInMinutes ~/ 60;
    final minutes = durationInMinutes % 60;

    final hourLabel = hours == 1 ? '1 hora' : '$hours horas';
    final minuteLabel = minutes > 0 ? ' $minutes minutos' : '';

    return hourLabel + minuteLabel;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final durationMinutes = int.parse(_durationController.text.trim());
      final serviceData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': int.parse(_priceController.text.trim()),
        'duration': durationMinutes,
        'times': generateTimesLabel(durationMinutes),
        'imageUrl': _imageUrlController.text.trim(),
        'imagePath': _imagePath,
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.isEditing && widget.serviceToEdit != null) {
        await FirebaseFirestore.instance
            .collection('services')
            .doc(widget.serviceToEdit!.id)
            .update(serviceData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Servicio actualizado correctamente'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        serviceData['createdAt'] = FieldValue.serverTimestamp();

        final docRef = await FirebaseFirestore.instance
            .collection('services')
            .add(serviceData);
        await docRef.update({'id': docRef.id});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Servicio agregado correctamente'),
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
                            ? 'Editar servicio'
                            : 'Agregar nuevo servicio',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del servicio',
                        ),
                        validator:
                            (val) =>
                                val == null || val.isEmpty ? 'Requerido' : null,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción del servicio',
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
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Duración (en minutos)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Requerido';
                          final parsed = int.tryParse(val);
                          if (parsed == null || parsed <= 0) {
                            return 'Debe ser un número positivo';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio del servicio',
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
                            widget.serviceToEdit?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        initialImagePath: widget.serviceToEdit?.imagePath,
                        folderName: 'services',
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
