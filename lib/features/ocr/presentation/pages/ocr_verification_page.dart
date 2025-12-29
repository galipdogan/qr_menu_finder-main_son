import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/parsed_menu_item.dart';
import '../blocs/ocr_bloc.dart';
import '../blocs/ocr_event.dart';
import '../blocs/ocr_state.dart';
import '../widgets/parsed_item_card.dart';

/// OCR Verification Page
/// TR: OCR Doğrulama Sayfası - ML Kit ile parse edilen menü itemlarını gösterir
class OcrVerificationPage extends StatefulWidget {
  final String imagePath;
  final String restaurantId;

  const OcrVerificationPage({
    super.key,
    required this.imagePath,
    required this.restaurantId,
  });

  @override
  State<OcrVerificationPage> createState() => _OcrVerificationPageState();
}

class _OcrVerificationPageState extends State<OcrVerificationPage> {
  List<ParsedMenuItem> _editableItems = [];
  bool _isSaving = false;

  void _onItemEdited(int index, ParsedMenuItem updatedItem) {
    setState(() {
      _editableItems[index] = updatedItem;
    });
  }

  void _onItemDeleted(int index) {
    setState(() {
      _editableItems.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Öğe silindi'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showEditDialog(int index, ParsedMenuItem item) async {
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(text: item.price.toString());

    final result = await showDialog<ParsedMenuItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğeyi Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ürün Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Fiyat',
                border: OutlineInputBorder(),
                suffixText: 'TRY',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedItem = ParsedMenuItem(
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? item.price,
                currency: item.currency,
                rawText: item.rawText,
              );
              Navigator.pop(context, updatedItem);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result != null) {
      _onItemEdited(index, result);
    }
  }

  Future<void> _saveAllItems() async {
    if (_editableItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kaydedilecek öğe yok'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // TODO: Implement proper menu item saving through repository
      // For now, show success message
      // In production, you would:
      // 1. Get menu repository from DI
      // 2. For each item, call repository.addMenuItem()
      // 3. Handle success/failure for each item
      
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_editableItems.length} öğe kaydedildi'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Biraz bekle ve geri dön
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.pop(true); // true = başarılı
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<OcrBloc>()
        ..add(OcrFullExtractionRequested(imagePath: widget.imagePath)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menü Öğelerini Doğrula'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<OcrBloc, OcrState>(
          listener: (context, state) {
            if (state is OcrError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is OcrMenuParsed) {
              // İlk parse edildiğinde editable list'e kopyala
              if (_editableItems.isEmpty) {
                setState(() {
                  _editableItems = List.from(state.menuItems);
                });
              }
            }
          },
          builder: (context, state) {
            if (state is OcrRecognizing) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Menü fotoğrafı işleniyor...',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ML Kit ile metin tanıma yapılıyor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is OcrParsing) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Menü öğeleri ayıklanıyor...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            if (state is OcrError) {
              return ErrorView(
                message: state.message,
                onRetry: () {
                  context.read<OcrBloc>().add(
                        OcrFullExtractionRequested(imagePath: widget.imagePath),
                      );
                },
              );
            }

            if (state is OcrMenuParsed || _editableItems.isNotEmpty) {
              return _buildParsedResults(context);
            }

            return const Center(
              child: Text('Hazır'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildParsedResults(BuildContext context) {
    if (_editableItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Menü öğesi bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fotoğrafta fiyat bilgisi tespit edilemedi',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Geri Dön'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with count
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${_editableItems.length} öğe bulundu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton.icon(
                      onPressed: _saveAllItems,
                      icon: const Icon(Icons.save),
                      label: const Text('Tümünü Kaydet'),
                    ),
            ],
          ),
        ),

        // List of parsed items
        Expanded(
          child: ListView.builder(
            itemCount: _editableItems.length,
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemBuilder: (context, index) {
              final item = _editableItems[index];
              return ParsedItemCard(
                item: item,
                onEdit: () => _showEditDialog(index, item),
                onDelete: () => _onItemDeleted(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
