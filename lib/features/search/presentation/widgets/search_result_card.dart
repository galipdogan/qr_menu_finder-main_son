import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/search_result.dart';
import '../../../price_comparison/presentation/widgets/price_comparison_section.dart';

/// Card widget for displaying search results with expandable price comparison
class SearchResultCard extends StatefulWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  State<SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<SearchResultCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Main Content
          InkWell(
            onTap: widget.onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultSpacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  _buildImage(),
                  const SizedBox(width: AppConstants.defaultSpacing),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type badge
                        _buildTypeBadge(),
                        const SizedBox(height: 4),

                        // Name
                        Text(
                          widget.result.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Description or Restaurant name
                        if (widget.result.description != null ||
                            widget.result.restaurantName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.result.type == 'restaurant'
                                  ? widget.result.description ?? ''
                                  : widget.result.restaurantName ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        const SizedBox(height: 8),

                        // Bottom row (price, rating, location)
                        _buildBottomRow(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Price Comparison Section (Only for menu items)
          if (widget.result.type == 'menu_item' &&
              widget.result.restaurantId != null)
            _buildComparisonSection(),
        ],
      ),
    );
  }

  Widget _buildComparisonSection() {
    return Column(
      children: [
        if (!_isExpanded)
          InkWell(
            onTap: () => setState(() => _isExpanded = true),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compare_arrows,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fiyatları Karşılaştır',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        if (_isExpanded)
          Column(
            children: [
              const Divider(height: 1),
              Stack(
                children: [
                  PriceComparisonSection(
                    itemName: widget.result.name,
                    currentRestaurantId: widget.result.restaurantId!,
                    currentProductId: widget.result.id,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _isExpanded = false),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 80,
        height: 80,
        child: widget.result.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: widget.result.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    widget.result.type == 'restaurant'
                        ? Icons.restaurant
                        : Icons.fastfood,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                ),
              )
            : Container(
                color: Colors.grey[200],
                child: Icon(
                  widget.result.type == 'restaurant'
                      ? Icons.restaurant
                      : Icons.fastfood,
                      color: Colors.grey[400],
                  size: 40,
                ),
              ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    final isRestaurant = widget.result.type == 'restaurant';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRestaurant
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isRestaurant ? ErrorMessages.restaurantLabel : ErrorMessages.menuLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isRestaurant ? AppColors.primary : Colors.orange,
        ),
      ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Price (for menu items)
        if (widget.result.price != null) ...[
          Text(
            '${widget.result.price!.toStringAsFixed(2)} ₺',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Rating
        if (widget.result.rating != null) ...[
          Icon(Icons.star, size: 16, color: Colors.amber[700]),
          const SizedBox(width: 4),
          Text(
            widget.result.rating!.toStringAsFixed(1),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
        ],

        // Location (for restaurants)
        if (widget.result.city != null) ...[
          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.result.district != null
                  ? '${widget.result.district}, ${widget.result.city}'
                  : widget.result.city!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
