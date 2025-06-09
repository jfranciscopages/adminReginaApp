import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_regina_app/domain/product.dart';
import 'package:admin_regina_app/presentation/providers/product_storage_provider.dart';

class ImageUploader extends ConsumerStatefulWidget {
  final String productId;
  final Function(String imagePath) onImageUploaded;
  final String? initialImagePath;

  const ImageUploader({
    super.key,
    required this.productId,
    required this.onImageUploaded,
    this.initialImagePath,
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
    final storageService = ref.read(productStorageServiceProvider);
    final url = await storageService.getProductImageUrl(
      Product(
        id: widget.productId,
        name: '',
        description: '',
        price: 0,
        imagePath: path,
        status: 'active',
      ),
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
        final storageService = ref.read(productStorageServiceProvider);
        final bytes = reader.result as Uint8List;

        setState(() {
          _isUploading = true;
        });

        final path = await storageService.uploadProductImage(bytes, file.name);

        widget.onImageUploaded(file.name);

        final url = await storageService.getProductImageUrl(
          Product(
            id: widget.productId,
            name: '',
            description: '',
            price: 0,
            imagePath: file.name,
            status: 'active',
          ),
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

      // Alternativa si querés dejar solo texto:
      // imagePreviewBox = const Text('Imagen sin seleccionar');
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
