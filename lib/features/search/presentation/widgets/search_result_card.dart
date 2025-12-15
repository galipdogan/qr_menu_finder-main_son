import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/search_result.dart';

/// Card widget for displaying search results
class SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                      result.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description or Restaurant name
                    if (result.description != null ||
                        result.restaurantName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          result.type == 'restaurant'
                              ? result.description ?? ''
                              : result.restaurantName ?? '',
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
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 80,
        height: 80,
        child: result.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: result.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    result.type == 'restaurant'
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
                  result.type == 'restaurant'
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
    final isRestaurant = result.type == 'restaurant';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRestaurant
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isRestaurant ? 'Restoran' : 'Menü',
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
        if (result.price != null) ...[
          Text(
            '${result.price!.toStringAsFixed(2)} ₺',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Rating
        if (result.rating != null) ...[
          Icon(Icons.star, size: 16, color: Colors.amber[700]),
          const SizedBox(width: 4),
          Text(
            result.rating!.toStringAsFixed(1),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
        ],

        // Location (for restaurants)
        if (result.city != null) ...[
          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              result.district != null
                  ? '${result.district}, ${result.city}'
                  : result.city!,
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
