import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../injection_container.dart' as di; // Import di
import '../../../ocr/domain/usecases/extract_and_parse_menu_items_from_image.dart'; // New import
import '../../../ocr/domain/entities/parsed_menu_item.dart'; // New import

/// Menu Upload Page - Upload menu photos and extract items using ML Kit OCR
/// TR: Menü Yükleme Sayfası - Menü fotoğrafları yükle ve ML Kit OCR ile öğeleri çıkar
///
/// This replaces the Cloud Function menuProcessor with client-side ML Kit OCR
/// Bu, Cloud Function menuProcessor'ı client-side ML Kit OCR ile değiştirir
///
/// Flow / Akış:
/// 1. User picks image / Kullanıcı görüntü seçer
/// 2. ML Kit extracts text (on-device) / ML Kit metin çıkarır (cihaz üzerinde)
/// 3. Parse menu items / Menü öğelerini parse et
/// 4. Show preview for editing / Düzenleme için önizleme göster
/// 5. Upload image to Storage / Görüntüyü Storage'a yükle
/// 6. Write items to items_staging / Öğeleri items_staging'e yaz
class MenuUploadPage extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const MenuUploadPage({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<MenuUploadPage> createState() => _MenuUploadPageState();
}

class _MenuUploadPageState extends State<MenuUploadPage> {
  final ImagePicker _imagePicker = ImagePicker();
  // final MLKitOCRService _ocrService = MLKitOCRService(); // Removed
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _selectedImage;
  List<ParsedMenuItem> _parsedItems = [];
  bool _isProcessing = false;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void dispose() {
    // _ocrService.dispose(); // Removed, handled by DI
    super.dispose();
  }

  /// Pick image from gallery or camera
  /// TR: Galeriden veya kameradan görüntü seç
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _parsedItems = [];
          _errorMessage = null;
        });

        // Automatically process the image
        // Görüntüyü otomatik olarak işle
        await _processImage();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  /// Process image with ML Kit OCR
  /// TR: Görüntüyü ML Kit OCR ile işle
  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Extract and parse menu items using ML Kit
      // ML Kit kullanarak menü öğelerini çıkar ve parse et
      final itemsResult = await di.sl<ExtractAndParseMenuItemsFromImage>()(
        ExtractAndParseMenuItemsFromImageParams(
          imagePath: _selectedImage!.path,
        ),
      );

      itemsResult.fold(
        (failure) {
          setState(() {
            _isProcessing = false;
            _errorMessage = 'OCR processing failed: ${failure.message}';
          });
        },
        (items) {
          setState(() {
            _parsedItems = items;
            _isProcessing = false;
          });
          if (items.isEmpty) {
            setState(() {
              _errorMessage =
                  'No menu items found. Please try a clearer image.';
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'OCR processing failed: $e';
      });
    }
  }

  /// Upload image and save parsed items
  /// TR: Görüntüyü yükle ve parse edilmiş öğeleri kaydet
  Future<void> _uploadAndSave() async {
    if (_selectedImage == null || _parsedItems.isEmpty) return;

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      // 1. Upload image to Firebase Storage
      // 1. Görüntüyü Firebase Storage'a yükle
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child(
        'menus/${widget.restaurantId}/$fileName',
      );

      await storageRef.putFile(
        _selectedImage!,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': uid,
            'restaurantId': widget.restaurantId,
            'processedWithMLKit': 'true',
          },
        ),
      );

      final downloadUrl = await storageRef.getDownloadURL();

      // 2. Write parsed items to items_staging collection
      // 2. Parse edilmiş öğeleri items_staging koleksiyonuna yaz
      final batch = _firestore.batch();

      for (final item in _parsedItems) {
        final stagingRef = _firestore.collection('items_staging').doc();
        batch.set(stagingRef, {
          'name': item.name,
          'price': item.price,
          'currency': item.currency,
          'raw': item.raw,
          'restaurantId': widget.restaurantId,
          'meta': {
            'sourcePath': 'menus/${widget.restaurantId}/$fileName',
            'sourceUrl': downloadUrl,
            'uploadedBy': uid,
            'createdAt': FieldValue.serverTimestamp(),
            'processedWithMLKit': true,
          },
        });
      }

      await batch.commit();

      setState(() {
        _isUploading = false;
      });

      // Show success message and navigate back
      // Başarı mesajı göster ve geri dön
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Successfully uploaded ${_parsedItems.length} items!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Upload failed: $e';
      });
    }
  }

  /// Edit item name
  /// TR: Öğe adını düzenle
  void _editItemName(int index, String newName) {
    setState(() {
      _parsedItems[index] = ParsedMenuItem(
        name: newName,
        price: _parsedItems[index].price,
        currency: _parsedItems[index].currency,
        rawText: _parsedItems[index].rawText,
      );
    });
  }

  /// Edit item price
  /// TR: Öğe fiyatını düzenle
  void _editItemPrice(int index, double newPrice) {
    setState(() {
      _parsedItems[index] = ParsedMenuItem(
        name: _parsedItems[index].name,
        price: newPrice,
        currency: _parsedItems[index].currency,
        rawText: _parsedItems[index].rawText,
      );
    });
  }

  /// Remove item
  /// TR: Öğeyi kaldır
  void _removeItem(int index) {
    setState(() {
      _parsedItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Menu - ${widget.restaurantName}')),
      body: Column(
        children: [
          // Image preview / Görüntü önizlemesi
          if (_selectedImage != null)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),

          // Pick image buttons / Görüntü seçme butonları
          if (_selectedImage == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Upload a menu photo to extract items',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Processing indicator / İşleme göstergesi
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Processing image with ML Kit...'),
                ],
              ),
            ),

          // Error message / Hata mesajı
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          // Parsed items list / Parse edilmiş öğeler listesi
          if (_parsedItems.isNotEmpty)
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Found ${_parsedItems.length} items. Review and edit if needed:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _parsedItems.length,
                      itemBuilder: (context, index) {
                        final item = _parsedItems[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text('${item.price} ${item.currency}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Action buttons / Aksiyon butonları
          if (_selectedImage != null && !_isProcessing)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isUploading
                          ? null
                          : () {
                              setState(() {
                                _selectedImage = null;
                                _parsedItems = [];
                                _errorMessage = null;
                              });
                            },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUploading || _parsedItems.isEmpty
                          ? null
                          : _uploadAndSave,
                      child: _isUploading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Upload & Save'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Show edit dialog for item
  /// TR: Öğe için düzenleme dialogu göster
  void _showEditDialog(int index) {
    final item = _parsedItems[index];
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(text: item.price.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              final newPrice = double.tryParse(priceController.text);

              if (newName.isNotEmpty && newPrice != null && newPrice > 0) {
                _editItemName(index, newName);
                _editItemPrice(index, newPrice);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
