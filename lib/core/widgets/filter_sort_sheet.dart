import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../error/error_messages.dart';
import 'glass_container.dart';

enum SortOption {
  distance,
  rating,
  reviewCount,
  name,
}

class FilterSortOptions {
  final List<String> selectedCategories;
  final double? minRating;
  final SortOption sortBy;

  const FilterSortOptions({
    this.selectedCategories = const [],
    this.minRating,
    this.sortBy = SortOption.distance,
  });

  FilterSortOptions copyWith({
    List<String>? selectedCategories,
    double? minRating,
    bool clearMinRating = false,
    SortOption? sortBy,
  }) {
    return FilterSortOptions(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return selectedCategories.isNotEmpty || minRating != null;
  }
}

class FilterSortSheet extends StatefulWidget {
  final FilterSortOptions initialOptions;
  final List<String> availableCategories;
  final Function(FilterSortOptions) onApply;

  const FilterSortSheet({
    super.key,
    required this.initialOptions,
    required this.availableCategories,
    required this.onApply,
  });

  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<FilterSortSheet> {
  late FilterSortOptions _options;

  @override
  void initState() {
    super.initState();
    _options = widget.initialOptions;
  }

  void _toggleCategory(String category) {
    final categories = List<String>.from(_options.selectedCategories);
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
    setState(() {
      _options = _options.copyWith(selectedCategories: categories);
    });
  }

  void _setMinRating(double? rating) {
    setState(() {
      _options = _options.copyWith(
        minRating: rating,
        clearMinRating: rating == null,
      );
    });
  }

  void _setSortBy(SortOption sortBy) {
    setState(() {
      _options = _options.copyWith(sortBy: sortBy);
    });
  }

  void _reset() {
    setState(() {
      _options = const FilterSortOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.surface.withValues(alpha: 0.95),
                AppColors.backgroundDark.withValues(alpha: 0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(
              top: BorderSide(color: AppColors.border, width: 2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.gradientPrimary,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      ErrorMessages.filterSortTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(ErrorMessages.reset),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.gradientPrimary,
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),

          // Sort Section
          const SizedBox(height: 16),
          const Text(
            ErrorMessages.sortLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text(ErrorMessages.sortDistance),
                selected: _options.sortBy == SortOption.distance,
                onSelected: (_) => _setSortBy(SortOption.distance),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
              ),
              ChoiceChip(
                label: const Text(ErrorMessages.sortRating),
                selected: _options.sortBy == SortOption.rating,
                onSelected: (_) => _setSortBy(SortOption.rating),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
              ),
              ChoiceChip(
                label: const Text(ErrorMessages.sortReviewCount),
                selected: _options.sortBy == SortOption.reviewCount,
                onSelected: (_) => _setSortBy(SortOption.reviewCount),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
              ),
              ChoiceChip(
                label: const Text(ErrorMessages.sortName),
                selected: _options.sortBy == SortOption.name,
                onSelected: (_) => _setSortBy(SortOption.name),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
              ),
            ],
          ),

          // Rating Filter
          const SizedBox(height: 24),
          const Text(
            ErrorMessages.minRatingLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (var rating in [4.5, 4.0, 3.5, 3.0])
                FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(rating.toString()),
                    ],
                  ),
                  selected: _options.minRating == rating,
                  onSelected: (selected) {
                    _setMinRating(selected ? rating : null);
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                ),
            ],
          ),

          // Category Filter
          const SizedBox(height: 24),
          const Text(
            ErrorMessages.categoriesLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.availableCategories.isEmpty)
            const Text(
              ErrorMessages.categoryNotFound,
              style: TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              children: widget.availableCategories.map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: _options.selectedCategories.contains(category),
                  onSelected: (_) => _toggleCategory(category),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                );
              }).toList(),
            ),

          // Apply Button
          const SizedBox(height: 28),
          GlassButton(
            text: ErrorMessages.apply,
            icon: Icons.check_circle_rounded,
            width: double.infinity,
            height: 60,
            backgroundColor: AppColors.primary,
            onPressed: () {
              widget.onApply(_options);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
