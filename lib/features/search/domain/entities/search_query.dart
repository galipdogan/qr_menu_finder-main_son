import 'package:equatable/equatable.dart';

/// Search query entity with filters
class SearchQuery extends Equatable {
  final String query;
  final String? city;
  final String? district;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final int page;
  final int hitsPerPage;

  const SearchQuery({
    required this.query,
    this.city,
    this.district,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.page = 0,
    this.hitsPerPage = 20,
  });

  SearchQuery copyWith({
    String? query,
    String? city,
    String? district,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int? page,
    int? hitsPerPage,
  }) {
    return SearchQuery(
      query: query ?? this.query,
      city: city ?? this.city,
      district: district ?? this.district,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      page: page ?? this.page,
      hitsPerPage: hitsPerPage ?? this.hitsPerPage,
    );
  }

  @override
  List<Object?> get props => [
        query,
        city,
        district,
        category,
        minPrice,
        maxPrice,
        minRating,
        page,
        hitsPerPage,
      ];
}
