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
class OcrVerificationPage extends StatelessWidget {
  final String imagePath;
  final String restaurantId;

  const OcrVerificationPage({
    super.key,
    required this.imagePath,
    required this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<OcrBloc>()
        ..add(OcrFullExtractionRequested(imagePath: imagePath)),
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
                        OcrFullExtractionRequested(imagePath: imagePath),
                      );
                },
              );
            }

            if (state is OcrMenuParsed) {
              return _buildParsedResults(context, state.menuItems);
            }

            return const Center(
              child: Text('Hazır'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildParsedResults(
    BuildContext context,
    List<ParsedMenuItem> items,
  ) {
    if (items.isEmpty) {
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
                '${items.length} öğe bulundu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement save all
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tümünü kaydet özelliği yakında!'),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Tümünü Kaydet'),
              ),
            ],
          ),
        ),

        // List of parsed items
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return ParsedItemCard(
                item: item,
                onEdit: () {
                  // TODO: Implement edit
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} düzenleniyor...'),
                    ),
                  );
                },
                onDelete: () {
                  // TODO: Implement delete
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} silindi'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
