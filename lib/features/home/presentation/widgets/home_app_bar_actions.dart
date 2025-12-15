import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../../../core/theme/theme_event.dart';
import '../../../../core/theme/theme_state.dart';
import '../../../../routing/app_navigation.dart';
import '../../../restaurant/domain/entities/restaurant.dart';
import '../../../../core/widgets/filter_sort_sheet.dart';

class HomeAppBarActions extends StatelessWidget {
  final FilterSortOptions? filterOptions;
  final Function(FilterSortOptions)? onFilterApply;
  final List<Restaurant> currentRestaurants;
  final double? userLatitude;
  final double? userLongitude;

  const HomeAppBarActions({
    super.key,
    this.filterOptions,
    this.onFilterApply,
    this.currentRestaurants = const [],
    this.userLatitude,
    this.userLongitude,
  });

  void _showFilterSort(BuildContext context, List<String> availableCategories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterSortSheet(
        initialOptions: filterOptions ?? const FilterSortOptions(),
        availableCategories: availableCategories,
        onApply: onFilterApply ?? (_) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR Scanner - Most important action
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          tooltip: 'QR Kod Tara',
          onPressed: () => AppNavigation.goQrScanner(context),
        ),
        // More menu for other actions
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'Daha Fazla',
          onSelected: (value) {
            switch (value) {
              case 'map':
                AppNavigation.pushRestaurantMap(
                  context,
                  restaurants: currentRestaurants.isNotEmpty
                      ? currentRestaurants
                      : null,
                  latitude: userLatitude,
                  longitude: userLongitude,
                );
                break;
              case 'theme':
                final currentThemeMode = context
                    .read<ThemeBloc>()
                    .state
                    .themeMode;
                final newThemeMode = currentThemeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
                context.read<ThemeBloc>().add(
                  ThemeChangeRequested(newThemeMode),
                );
                break;
              case 'filter':
                final availableCategories = currentRestaurants
                    .expand((r) => r.categories)
                    .toSet()
                    .toList();
                _showFilterSort(context, availableCategories);
                break;
              case 'debug':
                if (kDebugMode) {
                  AppNavigation.goDebugSearch(context);
                }
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'map',
              child: Row(
                children: [
                  Icon(Icons.map),
                  SizedBox(width: 8),
                  Text('Harita Görünümü'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'theme',
              child: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  final isDark = themeState.themeMode == ThemeMode.dark;
                  return Row(
                    children: [
                      Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      const SizedBox(width: 8),
                      Text(isDark ? 'Açık Tema' : 'Koyu Tema'),
                    ],
                  );
                },
              ),
            ),
            PopupMenuItem(
              value: 'filter',
              child: Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 8),
                  const Text('Filtrele & Sırala'),
                  if (filterOptions?.hasActiveFilters ?? false)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
