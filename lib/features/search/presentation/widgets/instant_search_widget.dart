import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../injection_container.dart' as di;
import '../../../../routing/app_navigation.dart';
import '../../domain/entities/search_result.dart';
import '../blocs/search_bloc.dart';
import 'search_result_card.dart';

/// Instant search widget with real-time results
class InstantSearchWidget extends StatefulWidget {
  final String? initialQuery;
  final VoidCallback? onClose;

  const InstantSearchWidget({super.key, this.initialQuery, this.onClose});

  @override
  State<InstantSearchWidget> createState() => _InstantSearchWidgetState();
}

class _InstantSearchWidgetState extends State<InstantSearchWidget> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();

    // Auto-focus on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SearchBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: widget.onClose ?? () => Navigator.pop(context),
          ),
          title: _buildSearchField(),
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchInitial) {
              return _buildInitialState();
            }
            if (state is SearchLoading) {
              return const LoadingIndicator(message: ErrorMessages.searching);
            }
            if (state is SearchError) {
              return _buildErrorState(state.message);
            }
            if (state is SearchLoaded) {
              return _buildResultsList(state.results);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: true,
          decoration: InputDecoration(
            hintText: ErrorMessages.searchHint,
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      context.read<SearchBloc>().add(SearchCleared());
                    },
                  )
                : null,
          ),
          onChanged: (query) {
            if (query.isEmpty) {
              if (!mounted) return;
              context.read<SearchBloc>().add(SearchCleared());
            } else {
              // Instant search with debounce
              final bloc = context.read<SearchBloc>();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_searchController.text == query) {
                  if (!mounted) return;
                  bloc.add(SearchQueryChanged(partialQuery: query));
                }
              });
            }
          },
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              context.read<SearchBloc>().add(
                SearchQueryChanged(partialQuery: query),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey[300]),
          const SizedBox(height: AppConstants.defaultSpacing),
          Text(
            ErrorMessages.searchStartSubtitle,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: AppConstants.defaultSpacing),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<SearchResult> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: AppConstants.defaultSpacing),
            Text(
              ErrorMessages.searchNoResultsTitle,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: SearchResultCard(
                  result: result,
                  onTap: () => _handleResultTap(context, result),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleResultTap(BuildContext context, SearchResult result) {
    if (result.type == 'restaurant') {
      AppNavigation.goRestaurantDetail(context, result.id);
    } else {
      // Navigate to menu item detail
      if (result.restaurantId != null) {
        Navigator.pop(context);
        // Navigate to item detail
        // AppNavigation.goItemDetail(context, result.id, result.restaurantId!);
      }
    }
  }
}
