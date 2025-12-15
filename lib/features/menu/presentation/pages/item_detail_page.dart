import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/menu_item.dart';
import '../blocs/item_detail/item_detail_bloc.dart';
import '../../../price_comparison/presentation/widgets/price_comparison_section.dart';
import '../../../../injection_container.dart' as di;

class ItemDetailPage extends StatelessWidget {
  final String itemId;
  final String restaurantId;

  const ItemDetailPage({
    super.key,
    required this.itemId,
    required this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<ItemDetailBloc>()
            ..add(LoadItemDetail(itemId: itemId, restaurantId: restaurantId)),
      child: Scaffold(
        body: BlocBuilder<ItemDetailBloc, ItemDetailState>(
          builder: (context, state) {
            if (state is ItemDetailLoading) {
              return const LoadingIndicator(message: 'Ürün yükleniyor...');
            }
            if (state is ItemDetailError) {
              return Center(child: Text('Hata: ${state.message}'));
            }
            if (state is ItemDetailLoaded) {
              return _buildLoadedBody(context, state.item);
            }
            return const Center(child: Text('Ürün detayları yüklenemedi.'));
          },
        ),
      ),
    );
  }

  Widget _buildLoadedBody(BuildContext context, MenuItem item) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(item.name, style: const TextStyle(color: Colors.white)),
            background: item.imageUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.imageUrls.first,
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.3),
                    colorBlendMode: BlendMode.darken,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.fastfood, color: Colors.white),
                  )
                : Container(color: AppColors.surface),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and Category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.category,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${item.price.toStringAsFixed(2)} ${item.currency}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultSpacing),

                // Description
                if (item.description != null && item.description!.isNotEmpty)
                  Text(
                    item.description!,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                const SizedBox(height: AppConstants.defaultSpacing * 2),
                const Divider(),

                // Price Comparison Section
                PriceComparisonSection(
                  itemName: item.name,
                  currentRestaurantId: item.restaurantId,
                  currentProductId: item.id,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
