import 'package:flutter/material.dart';
import '../../features/menu/data/models/menu_item_model.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';
import 'image_placeholder.dart';
import 'badge_widget.dart';

/// Menü öğesi kartı widget'ı - Refactored
class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback? onTap;
  final bool showRestaurant;

  const MenuItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.showRestaurant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.defaultSpacing / 2,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              // Ürün görseli
              if (item.imageUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrls.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        ImagePlaceholder.menuItem(),
                  ),
                )
              else
                ImagePlaceholder.menuItem(),

              const SizedBox(width: AppConstants.defaultPadding),

              // Ürün detayları
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    BadgeWidget(
                      label: item.category,
                      fontSize: 10,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppConstants.defaultSpacing),

              // Fiyat bölümü
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.price.toStringAsFixed(2)} ${item.currency}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  if (item.unit == 'staging') ...[
                    const SizedBox(height: 2),
                    BadgeWidget(
                      label: 'Beklemede',
                      backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                      textColor: AppColors.warning,
                      fontSize: 10,
                    ),
                  ] else if (item.unit != 'portion') ...[
                    const SizedBox(height: 2),
                    Text(
                      '/${item.unit}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                  if (item.previousPrices.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPriceTrendIcon(),
                          size: 12,
                          color: _getPriceTrendColor(),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Geçmiş',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPriceTrendIcon() {
    if (item.previousPrices.isEmpty) return Icons.trending_flat;

    final lastPrice = item.previousPrices.last.price;
    if (item.price > lastPrice) {
      return Icons.trending_up;
    } else if (item.price < lastPrice) {
      return Icons.trending_down;
    }
    return Icons.trending_flat;
  }

  Color _getPriceTrendColor() {
    if (item.previousPrices.isEmpty) return AppColors.textSecondary;

    final lastPrice = item.previousPrices.last.price;
    if (item.price > lastPrice) {
      return AppColors.error;
    } else if (item.price < lastPrice) {
      return AppColors.success;
    }
    return AppColors.textSecondary;
  }
}
