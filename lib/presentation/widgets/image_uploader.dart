import 'dart:typed_data';
import 'dart:html' as html;
import 'package:admin_regina_app/presentation/providers/storage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageUploader extends ConsumerStatefulWidget {
  final String itemId; // Puede ser producto o servicio
  final Function(String imagePath) onImageUploaded;
  final String? initialImagePath;
  final String folderName; // 'products' o 'services'

  const ImageUploader({
    super.key,
    required this.itemId,
    required this.onImageUploaded,
    this.initialImagePath,
    required this.folderName,
  });

  @override
  ConsumerState<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends ConsumerState<ImageUploader> {
  String? _imageUrlPreview;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null) {
      _loadImageFromPath(widget.initialImagePath!);
    }
  }

  Future<void> _loadImageFromPath(String path) async {
    final storage = ref.read(storageProvider);
    final url = await storage.getImagePath(
      folder: widget.folderName,
      fileName: path,
    );
    setState(() {
      _imageUrlPreview = url;
    });
  }

  Future<void> _pickImage() async {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file == null) return;

      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) async {
        final bytes = reader.result as Uint8List;
        final storageService = ref.read(storageProvider);

        setState(() {
          _isUploading = true;
        });

        final fileName = file.name;

        await storageService.uploadImage(
          folder: widget.folderName,
          bytes: bytes,
          fileName: fileName,
        );

        widget.onImageUploaded(fileName);

        final url = await storageService.getImagePath(
          folder: widget.folderName,
          fileName: fileName,
        );

        setState(() {
          _imageUrlPreview = url;
          _isUploading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget imagePreviewBox;
    if (_isUploading) {
      imagePreviewBox = const Center(child: CircularProgressIndicator());
    } else if (_imageUrlPreview != null) {
      imagePreviewBox = Image.network(
        _imageUrlPreview!,
        fit: BoxFit.cover,
        width: 150,
        height: 150,
      );
    } else {
      imagePreviewBox = const Icon(Icons.image, size: 48, color: Colors.grey);
    }

    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          child: imagePreviewBox,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.upload_file),
          label: const Text('Seleccionar imagen'),
        ),
      ],
    );
  }
}
