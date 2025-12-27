import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../routing/app_navigation.dart';
import '../../../restaurant/domain/entities/restaurant.dart';
import '../../domain/entities/search_query.dart';
import '../blocs/search_bloc.dart';
import '../widgets/search_result_card.dart';
import '../widgets/search_filters_bottom_sheet.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  // Filter state
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  double? _minRating;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // If an initial query is provided, populate the search bar and run the search.
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<SearchBloc>().state;
      if (state is SearchLoaded && state.hasMore) {
        context.read<SearchBloc>().add(
              SearchNextPageRequested(currentQuery: state.query),
            );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(AppConstants.searchDebounce, () {
      if (query.trim().isNotEmpty) {
        _performSearch(query.trim());
      } else {
        context.read<SearchBloc>().add(SearchCleared());
      }
    });
  }

  void _performSearch(String query) {
    final searchQuery = SearchQuery(
      query: query,
      city: _selectedCity,
      district: _selectedDistrict,
      category: _selectedCategory,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minRating: _minRating,
      hasMenu: true,
      page: 0,
    );

    context.read<SearchBloc>().add(SearchQuerySubmitted(query: searchQuery));
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SearchFiltersBottomSheet(
        initialCity: _selectedCity,
        initialDistrict: _selectedDistrict,
        initialCategory: _selectedCategory,
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
        initialMinRating: _minRating,
        onApply: (city, district, category, minPrice, maxPrice, minRating) {
          setState(() {
            _selectedCity = city;
            _selectedDistrict = district;
            _selectedCategory = category;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _minRating = minRating;
          });

          if (_searchController.text.trim().isNotEmpty) {
            _performSearch(_searchController.text.trim());
          }
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCity = null;
      _selectedDistrict = null;
      _selectedCategory = null;
      _minPrice = null;
      _maxPrice = null;
      _minRating = null;
    });

    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text.trim());
    }
  }

  bool get _hasActiveFilters =>
      _selectedCity != null ||
      _selectedDistrict != null ||
      _selectedCategory != null ||
      _minPrice != null ||
      _maxPrice != null ||
      _minRating != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          decoration: InputDecoration(
            hintText: ErrorMessages.searchHint,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)),
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
          onSubmitted: (query) {
            if (query.trim().isNotEmpty) {
              _performSearch(query.trim());
            }
          },
        ),
        actions: [
          if (_hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Filtreleri Temizle',
            ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _hasActiveFilters ? AppColors.warning : null,
            ),
            onPressed: _showFilters,
            tooltip: 'Filtrele',
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial) {
            return EmptyState(
              icon: Icons.search,
              title: ErrorMessages.searchStartTitle,
              subtitle: ErrorMessages.searchStartSubtitle,
            );
          }

          if (state is SearchLoading) {
            return LoadingIndicator(message: ErrorMessages.searching);
          }

          if (state is SearchError && state.previousResponse == null) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                if (_searchController.text.trim().isNotEmpty) {
                  _performSearch(_searchController.text.trim());
                }
              },
            );
          }

          if (state is SearchLoaded) {
            if (state.isEmpty) {
              return EmptyState(
                icon: Icons.search_off,
                title: ErrorMessages.searchNoResultsTitle,
                subtitle: ErrorMessages.searchNoResultsSubtitle,
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: state.results.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.results.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final result = state.results[index];
                return SearchResultCard(
                  result: result,
                  onTap: () {
                    if (result.type == 'restaurant') {
                      // Create a minimal Restaurant entity from SearchResult
                      // to use as initialRestaurant fallback
                      final initialRestaurant = Restaurant(
                        id: result.id,
                        name: result.name,
                        description: result.description,
                        address: result.address,
                        latitude: null, // Search results don't have coordinates
                        longitude: null,
                        imageUrls: result.imageUrl != null ? [result.imageUrl!] : [],
                        rating: result.rating,
                        reviewCount: 0,
                        categories: result.category != null ? [result.category!] : [],
                        openingHours: const {},
                        isActive: true,
                        createdAt: DateTime.now(),
                      );
                      
                      AppNavigation.pushRestaurantDetail(
                        context,
                        result.id,
                        initialRestaurant: initialRestaurant,
                      );
                    } else if (result.type == 'menu_item') {
                      AppNavigation.pushItemDetail(context, result.restaurantId!, result.id);
                    }
                  },
                );
              },
            );
          }

          if (state is SearchLoadingMore) {
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.currentResponse.results.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.currentResponse.results.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final result = state.currentResponse.results[index];
                return SearchResultCard(
                  result: result,
                  onTap: () {
                    if (result.type == 'restaurant') {
                      // Create a minimal Restaurant entity from SearchResult
                      final initialRestaurant = Restaurant(
                        id: result.id,
                        name: result.name,
                        description: result.description,
                        address: result.address,
                        latitude: null,
                        longitude: null,
                        imageUrls: result.imageUrl != null ? [result.imageUrl!] : [],
                        rating: result.rating,
                        reviewCount: 0,
                        categories: result.category != null ? [result.category!] : [],
                        openingHours: const {},
                        isActive: true,
                        createdAt: DateTime.now(),
                      );
                      
                      AppNavigation.pushRestaurantDetail(
                        context,
                        result.id,
                        initialRestaurant: initialRestaurant,
                      );
                    } else if (result.type == 'menu_item') {
                      AppNavigation.pushItemDetail(context, result.restaurantId!, result.id);
                    }
                  },
                );
              },
            );
          }

          return EmptyState(
            icon: Icons.info,
            title: ErrorMessages.somethingWentWrong,
            subtitle: ErrorMessages.retryPrompt,
          );
        },
      ),
    );
  }
}
