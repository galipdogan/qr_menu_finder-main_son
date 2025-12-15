import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/menu_item.dart';
import '../blocs/menu_bloc.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback? onTap;

  const MenuItemCard({super.key, required this.menuItem, this.onTap});

  bool get isLink => menuItem.type == 'link';
  bool get isProcessed => menuItem.status == 'processed';
  bool get isOcrItem => menuItem.type == 'ocr_item';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ✅ Image or placeholder
              _buildImage(),

              const SizedBox(width: 16),

              // ✅ Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleRow(context),
                    const SizedBox(height: 4),

                    if (menuItem.description != null)
                      _buildDescription(context),

                    const SizedBox(height: 8),

                    _buildPriceAndCategory(context),

                    const SizedBox(height: 8),

                    // ✅ OCR / Link / Processed status
                    _buildStatusRow(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Image
  Widget _buildImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surface,
      ),
      child: menuItem.imageUrls.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                menuItem.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  // ✅ Title + availability
  Widget _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            menuItem.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (!menuItem.isAvailable)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Tükendi',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // ✅ Description
  Widget _buildDescription(BuildContext context) {
    return Text(
      menuItem.description!,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ✅ Price + category
  Widget _buildPriceAndCategory(BuildContext context) {
    return Row(
      children: [
        Text(
          '${menuItem.price.toStringAsFixed(2)} ${menuItem.currency}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            menuItem.category,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ✅ OCR / Link / Processed status row
  Widget _buildStatusRow(BuildContext context) {
    if (isLink && !isProcessed) {
      // ✅ “Menüyü İşle” butonu
      return Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          onPressed: () {
            context.read<MenuBloc>().add(ProcessMenuLinkEvent(menuItem.id));
          },
          icon: const Icon(Icons.document_scanner, size: 18),
          label: const Text("Menüyü İşle"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    if (isLink && isProcessed) {
      // ✅ Processed etiketi
      return Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
          const SizedBox(width: 6),
          Text(
            "Menü işlendi",
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (isOcrItem) {
      // ✅ OCR item etiketi
      return Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.blue.shade600, size: 18),
          const SizedBox(width: 6),
          Text(
            "OCR ile oluşturuldu",
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.restaurant_menu,
        color: AppColors.textSecondary,
        size: 32,
      ),
    );
  }
}
