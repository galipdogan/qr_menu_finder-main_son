import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_messages.dart';
import '../../presentation/blocs/menu_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class AddMenuPage extends StatefulWidget {
  final String? qrContent;
  final bool isUrl;
  final String? restaurantId;

  const AddMenuPage({
    super.key,
    this.qrContent,
    this.isUrl = false,
    this.restaurantId,
  });

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  String _uploadMethod = 'photo'; // 'photo', 'url', 'qr'
  bool _isUploading = false;

  /// Handle menu upload
  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      if (_uploadMethod == 'url' && _urlController.text.isNotEmpty) {
        // Handle URL upload
        await _handleUrlUpload(_urlController.text, widget.restaurantId!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorMessages.menuAddedSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } else if (_uploadMethod == 'photo' && _selectedImage != null) {
        // Navigate to OCR verification page instead of uploading
        if (mounted) {
          context.push(
            '/restaurant/${widget.restaurantId}/ocr',
            extra: {'imagePath': _selectedImage!.path},
          );
        }
      } else {
        throw Exception(ErrorMessages.invalidMenuSelection);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  /// Handle URL upload
  Future<void> _handleUrlUpload(String url, String restaurantId) async {
    if (!mounted) return;

    final bloc = context.read<MenuBloc>();
    bloc.add(UploadMenuUrl(restaurantId: restaurantId, url: url, type: 'url'));

    final state = await bloc.stream.firstWhere(
      (s) => s is MenuUploadSuccess || s is MenuUploadFailure,
    );

    if (state is MenuUploadSuccess) return;
    if (state is MenuUploadFailure) throw Exception(state.message);
  }


  @override
  void initState() {
    super.initState();

    // URL modunda aç
    if (widget.isUrl) {
      _uploadMethod = 'url';
      if (widget.qrContent != null) {
        _urlController.text = widget.qrContent!;
      }
    } else if (widget.qrContent != null) {
      // QR koddan geliyorsa
      _uploadMethod = 'qr';
    }
  }

  // Auth kontrolü artık calling screen'de yapılıyor
  // Duplicate dialog'u önlemek için bu metod kaldırıldı

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _uploadMethod = 'photo';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${ErrorMessages.photoSelectErrorPrefix} $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _uploadMethod = 'photo';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${ErrorMessages.photoCaptureErrorPrefix} $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildRestaurantSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info),
                      SizedBox(width: 8),
                          Text(
                            ErrorMessages.restaurantSelectionRequired,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                    ],
                  ),
                  SizedBox(height: 12),
                      Text(
                        ErrorMessages.restaurantSelectionDesc,
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              // Navigate to restaurant search screen
              if (mounted) {
                context.push('/restaurant-search');
              }
            },
            icon: const Icon(Icons.search),
            label: Text(ErrorMessages.restaurantSearchLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              // Create new restaurant
              if (mounted) {
                context.push('/add-restaurant');
              }
            },
            icon: const Icon(Icons.add),
            label: Text(ErrorMessages.newRestaurantLabel),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If restaurantId is null, show restaurant selection first
    if (widget.restaurantId == null || widget.restaurantId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(ErrorMessages.restaurantSelectTitle),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: _buildRestaurantSelection(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(ErrorMessages.menuAddTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info),
                        SizedBox(width: 8),
                        Text(
                          ErrorMessages.menuUploadTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      ErrorMessages.menuUploadInstructions,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Upload Method Selection
              const Text(
                  ErrorMessages.uploadMethodLabel,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _MethodButton(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      isSelected:
                          _uploadMethod == 'photo' && _selectedImage != null,
                      onTap: _pickImageFromGallery,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MethodButton(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      isSelected: false,
                      onTap: _pickImageFromCamera,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MethodButton(
                      icon: Icons.link,
                      label: 'URL',
                      isSelected: _uploadMethod == 'url',
                      onTap: () {
                        setState(() {
                          _uploadMethod = 'url';
                          _selectedImage = null;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Image Preview or URL Input
                if (_selectedImage != null) ...[
                const Text(
                  ErrorMessages.selectedPhotoLabel,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Use FutureBuilder to load image bytes for web compatibility
                      FutureBuilder<Uint8List>(
                        future: _selectedImage!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_uploadMethod == 'url') ...[
                const Text(
                  ErrorMessages.menuPhotoUrlLabel,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    hintText: ErrorMessages.urlHint,
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ErrorMessages.urlRequired;
                    }
                    if (!value.startsWith('http://') &&
                        !value.startsWith('https://')) {
                      return ErrorMessages.urlInvalid;
                    }
                    return null;
                  },
                  keyboardType: TextInputType.url,
                ),
              ] else if (widget.qrContent != null && _uploadMethod == 'qr') ...[
                const Text(
                  ErrorMessages.qrContentLabel,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    widget.qrContent!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Upload Button
              ElevatedButton(
                onPressed: _isUploading ? null : _handleUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        ErrorMessages.uploadAndProcess,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
