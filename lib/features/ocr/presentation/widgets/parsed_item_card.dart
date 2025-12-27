import 'package:flutter/material.dart';
import '../../domain/entities/parsed_menu_item.dart';
import '../../../../core/theme/app_colors.dart';

/// Parsed menu item card widget
/// TR: Parse edilmiş menü item kartı - OCR sonuçlarını gösterir
class ParsedItemCard extends StatelessWidget {
  final ParsedMenuItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEditable;

  const ParsedItemCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name and Actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isEditable) ...[
                  IconButton(
                    icon: Icon(Icons.edit, color: AppColors.primary),
                    onPressed: onEdit,
                    tooltip: 'Düzenle',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Sil',
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Price
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.price.toStringAsFixed(2)} ${item.currency}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Raw text (original OCR result)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.text_snippet,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.raw,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
