import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../injection_container.dart' as di;
import '../../../../routing/app_navigation.dart';
import '../../domain/entities/compared_price.dart';
import '../blocs/price_comparison_bloc.dart';

/// Widget to display price comparison section for a menu item
class PriceComparisonSection extends StatelessWidget {
  final String itemName;
  final String currentRestaurantId;
  final String currentProductId;

  const PriceComparisonSection({
    super.key,
    required this.itemName,
    required this.currentRestaurantId,
    required this.currentProductId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<PriceComparisonBloc>()
        ..add(
          PriceComparisonRequested(
            itemName: itemName,
            currentRestaurantId: currentRestaurantId,
            currentProductId: currentProductId,
          ),
        ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diğer Restoranlardaki Fiyatlar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.defaultSpacing / 2),
            BlocBuilder<PriceComparisonBloc, PriceComparisonState>(
              builder: (context, state) {
                if (state is PriceComparisonLoading) {
                  return const LoadingIndicator(
                    message: 'Fiyatlar aranıyor...',
                  );
                }
                if (state is PriceComparisonError) {
                  return Center(
                    child: Text(
                      'Fiyatlar yüklenemedi: ${state.message}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }
                if (state is PriceComparisonLoaded) {
                  if (state.prices.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Bu ürün için başka restoranda fiyat bulunamadı.',
                        ),
                      ),
                    );
                  }
                  return _buildPriceList(context, state.prices);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build the list of compared prices with animations
  Widget _buildPriceList(BuildContext context, List<ComparedPrice> prices) {
    // Sort by price (lowest first)
    final sortedPrices = List<ComparedPrice>.from(prices)
      ..sort((a, b) => a.price.compareTo(b.price));

    return Column(
      children: [
        // Best price indicator
        if (sortedPrices.isNotEmpty)
          _buildBestPriceCard(context, sortedPrices.first),

        const SizedBox(height: AppConstants.defaultSpacing),

        // Other prices
        ...sortedPrices.skip(1).map((item) => _buildPriceCard(context, item)),
      ],
    );
  }

  /// Build best price card (highlighted)
  Widget _buildBestPriceCard(BuildContext context, ComparedPrice item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing / 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultSpacing,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.star, color: Colors.white, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.restaurantName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'EN UYGUN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: const Text(
          'En uygun fiyat',
          style: TextStyle(color: AppColors.primary),
        ),
        trailing: Text(
          '${item.price.toStringAsFixed(2)} ${item.currency}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
        onTap: () {
          AppNavigation.goRestaurantDetail(context, item.restaurantId);
        },
      ),
    );
  }

  /// Build regular price card
  Widget _buildPriceCard(BuildContext context, ComparedPrice item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing / 2),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultSpacing,
          vertical: 4,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.restaurant, color: Colors.grey[600], size: 20),
        ),
        title: Text(
          item.restaurantName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: Text(
          '${item.price.toStringAsFixed(2)} ${item.currency}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        onTap: () {
          AppNavigation.goRestaurantDetail(context, item.restaurantId);
        },
      ),
    );
  }
}
