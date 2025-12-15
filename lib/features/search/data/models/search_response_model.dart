import '../../domain/entities/search_response.dart';
import 'search_result_model.dart';

/// Search response model for data layer
class SearchResponseModel extends SearchResponse {
  const SearchResponseModel({
    required super.results,
    required super.totalHits,
    required super.currentPage,
    required super.totalPages,
    required super.hitsPerPage,
  });

  /// Create from Algolia response data
  factory SearchResponseModel.fromAlgoliaResponse({
    required List<Map<String, dynamic>> hits,
    required int? nbHits,
    required int page,
    required int? nbPages,
    required int hitsPerPage,
  }) {
    final results = hits
        .map((hit) => SearchResultModel.fromAlgoliaHit(hit))
        .toList();

    return SearchResponseModel(
      results: results,
      totalHits: nbHits ?? 0,
      currentPage: page,
      totalPages: nbPages ?? 0,
      hitsPerPage: hitsPerPage,
    );
  }

  factory SearchResponseModel.fromMeiliSearchResponse({
    required List<Map<String, dynamic>> hits,
    required int totalHits,
    required int offset,
    required int limit,
  }) {
    final results = hits
        .map((hit) => SearchResultModel.fromMeiliSearchHit(hit))
        .toList();

    return SearchResponseModel(
      results: results,
      totalHits: totalHits,
      currentPage: (offset ~/ limit), // Calculate current page
      totalPages: (totalHits / limit).ceil(), // Calculate total pages
      hitsPerPage: limit,
    );
  }

  /// Convert to domain entity
  SearchResponse toEntity() {
    return SearchResponse(
      results: results,
      totalHits: totalHits,
      currentPage: currentPage,
      totalPages: totalPages,
      hitsPerPage: hitsPerPage,
    );
  }

  /// Convert from domain entity
  factory SearchResponseModel.fromEntity(SearchResponse entity) {
    return SearchResponseModel(
      results: entity.results,
      totalHits: entity.totalHits,
      currentPage: entity.currentPage,
      totalPages: entity.totalPages,
      hitsPerPage: entity.hitsPerPage,
    );
  }
}
