import 'package:flutter/material.dart';
import '../../features/menu/data/models/menu_item_model.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';

/// Price History Bottom Sheet
/// Shows detailed price history with tabs for Date and Price view
/// Matches the design from screenshot with favorite indicator and price change arrows
class PriceHistorySheet extends StatefulWidget {
  final MenuItemModel item;

  const PriceHistorySheet({
    super.key,
    required this.item,
  });

  @override
  State<PriceHistorySheet> createState() => _PriceHistorySheetState();
}

class _PriceHistorySheetState extends State<PriceHistorySheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _favoriteDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // For demo: mark the first price as favorite
    if (widget.item.previousPrices.isNotEmpty) {
      _favoriteDate = widget.item.previousPrices.first.date;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Combine current price with previous prices for complete history
    final allPrices = [
      PriceHistory(
        price: widget.item.price,
        date: widget.item.updatedAt ?? DateTime.now(),
      ),
      ...widget.item.previousPrices,
    ];

    // Sort by date descending (newest first)
    allPrices.sort((a, b) => b.date.compareTo(a.date));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header with current vs favorite comparison
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildPriceComparisonHeader(allPrices),
          ),

          const SizedBox(height: 8),

          // Disclaimer text (from screenshot)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'İlanlardaki fiyatlar ilan giren kullanıcı tarafından belirlenmekte olup,\nsahibinden.com\'un fiyatlara herhangi bir müdahalesi bulunmamaktadır.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Tarih'),
                Tab(text: 'Fiyat'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDateView(allPrices),
                _buildPriceView(allPrices),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Header showing price comparison (favorite vs current)
  Widget _buildPriceComparisonHeader(List<PriceHistory> allPrices) {
    final favoritePrice = allPrices.firstWhere(
      (p) => p.date == _favoriteDate,
      orElse: () => allPrices.first,
    );
    final currentPrice = allPrices.first;

    return Row(
      children: [
        // Favorite Price (Left)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateFormat('dd MMMM yyyy', 'tr_TR').format(favoritePrice.date)} Fiyatı',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatPrice(favoritePrice.price)} ${widget.item.currency}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Arrow Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward,
            color: Colors.grey[600],
            size: 24,
          ),
        ),

        // Current Price (Right)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Şu Anki Fiyatı',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatPrice(currentPrice.price)} ${widget.item.currency}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Date-ordered view (Tab 1)
  Widget _buildDateView(List<PriceHistory> allPrices) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: allPrices.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final priceHistory = allPrices[index];
        final isFavorite = priceHistory.date == _favoriteDate;
        final isNewest = index == 0;

        // Calculate price change from previous
        String? changeIndicator;
        Color? changeColor;
        if (index < allPrices.length - 1) {
          final prevPrice = allPrices[index + 1].price;
          final diff = priceHistory.price - prevPrice;
          if (diff > 0) {
            changeIndicator = '↑';
            changeColor = Colors.red;
          } else if (diff < 0) {
            changeIndicator = '↓';
            changeColor = Colors.green;
          }
        }

        return InkWell(
          onTap: () {
            setState(() {
              _favoriteDate = priceHistory.date;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                // Date
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Text(
                        DateFormat('dd MMMM yyyy', 'tr_TR').format(priceHistory.date),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isNewest ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (isNewest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ŞİMDİ',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Price with change indicator
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (changeIndicator != null) ...[
                        Text(
                          changeIndicator,
                          style: TextStyle(
                            fontSize: 18,
                            color: changeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${_formatPrice(priceHistory.price)} ${widget.item.currency}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isNewest ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Favorite star
                const SizedBox(width: 8),
                Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.orange : Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Price-ordered view (Tab 2)
  Widget _buildPriceView(List<PriceHistory> allPrices) {
    // Sort by price descending (highest first)
    final sortedByPrice = List<PriceHistory>.from(allPrices)
      ..sort((a, b) => b.price.compareTo(a.price));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sortedByPrice.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final priceHistory = sortedByPrice[index];
        final isFavorite = priceHistory.date == _favoriteDate;
        final isNewest = priceHistory.date == allPrices.first.date;

        return InkWell(
          onTap: () {
            setState(() {
              _favoriteDate = priceHistory.date;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                // Date
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Text(
                        DateFormat('dd MMMM yyyy', 'tr_TR').format(priceHistory.date),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isNewest ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (isNewest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ŞİMDİ',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Price
                Expanded(
                  flex: 2,
                  child: Text(
                    '${_formatPrice(priceHistory.price)} ${widget.item.currency}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isNewest ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),

                // Favorite star
                const SizedBox(width: 8),
                Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.orange : Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatPrice(double price) {
    // Format with thousand separators
    final formatter = NumberFormat('#,##0.000', 'tr_TR');
    return formatter.format(price);
  }
}
