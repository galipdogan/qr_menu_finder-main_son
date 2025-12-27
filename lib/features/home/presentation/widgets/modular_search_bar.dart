import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/place_suggestion.dart';
import '../blocs/search/search_bloc.dart';

/// Modular Search Bar Widget - Clean Architecture Compliant
/// No direct service dependencies, only BLoC communication
class ModularSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final Function(PlaceSuggestion)? onSuggestionSelected;
  final double? latitude;
  final double? longitude;
  final String hintText;

  const ModularSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onClear,
    this.onSuggestionSelected,
    this.latitude,
    this.longitude,
    this.hintText = ErrorMessages.searchHint,
  });

  @override
  State<ModularSearchBar> createState() => _ModularSearchBarState();
}

class _ModularSearchBarState extends State<ModularSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus;
    });
  }

  void _onQueryChanged(String query) {
    context.read<SearchBloc>().add(
      SearchQueryChanged(
        query: query,
        latitude: widget.latitude,
        longitude: widget.longitude,
      ),
    );
  }

  void _onSuggestionTap(PlaceSuggestion suggestion) {
    widget.controller.text = suggestion.name;
    context.read<SearchBloc>().add(SearchSuggestionSelected(suggestion));
    
    if (widget.onSuggestionSelected != null) {
      widget.onSuggestionSelected!(suggestion);
    }
    
    // Don't call widget.onSearch here - onSuggestionSelected handles navigation
    // widget.onSearch is only for manual search (Enter key or search button)
    _focusNode.unfocus();
  }

  void _onClear() {
    widget.controller.clear();
    context.read<SearchBloc>().add(SearchCleared());
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Input Field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: _onQueryChanged,
            onSubmitted: widget.onSearch,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.primary,
                size: 24,
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: _onClear,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),

        // Suggestions Dropdown
        if (_showSuggestions) _buildSuggestions(),
      ],
    );
  }

  Widget _buildSuggestions() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchInitial) {
          return const SizedBox.shrink();
        }

        if (state is SearchLoading) {
          return _buildSuggestionsContainer([
            _buildLoadingItem(),
          ]);
        }

        if (state is SearchError) {
          return _buildSuggestionsContainer([
            _buildErrorItem(state.message),
          ]);
        }

        if (state is SearchLoaded) {
          if (state.suggestions.isEmpty) {
            return _buildSuggestionsContainer([
              _buildNoResultsItem(),
            ]);
          }

          return _buildSuggestionsContainer(
            state.suggestions.map((suggestion) => 
              _buildSuggestionItem(suggestion)
            ).toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSuggestionsContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildSuggestionItem(PlaceSuggestion suggestion) {
    return ListTile(
      leading: Icon(
        _getIconForType(suggestion.type),
        color: AppColors.primary,
        size: 20,
      ),
      title: Text(
        suggestion.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        suggestion.address,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _onSuggestionTap(suggestion),
      dense: true,
    );
  }

  Widget _buildLoadingItem() {
    return ListTile(
      leading: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
      title: const Text(ErrorMessages.searching),
      dense: true,
    );
  }

  Widget _buildErrorItem(String message) {
    return ListTile(
      leading: Icon(
        Icons.error_outline,
        color: AppColors.error,
        size: 20,
      ),
      title: Text(
        '${ErrorMessages.errorPrefix} $message',
        style: TextStyle(color: AppColors.error),
      ),
      dense: true,
    );
  }

  Widget _buildNoResultsItem() {
    return ListTile(
      leading: Icon(
        Icons.search_off,
        color: AppColors.textMuted,
        size: 20,
      ),
      title: Text(
        ErrorMessages.searchNoResultsTitle,
        style: TextStyle(color: AppColors.textMuted),
      ),
      dense: true,
    );
  }

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'cafe':
        return Icons.local_cafe;
      case 'fast_food':
        return Icons.fastfood;
      case 'bar':
        return Icons.local_bar;
      default:
        return Icons.place;
    }
  }
}