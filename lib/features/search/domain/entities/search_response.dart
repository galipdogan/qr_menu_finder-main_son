import 'package:equatable/equatable.dart';
import 'search_result.dart';

/// Search response entity containing results and pagination info
class SearchResponse extends Equatable {
  final List<SearchResult> results;
  final int totalHits;
  final int currentPage;
  final int totalPages;
  final int hitsPerPage;

  const SearchResponse({
    required this.results,
    required this.totalHits,
    required this.currentPage,
    required this.totalPages,
    required this.hitsPerPage,
  });

  bool get hasMore => currentPage < totalPages - 1;

  bool get isEmpty => results.isEmpty;

  @override
  List<Object?> get props => [
        results,
        totalHits,
        currentPage,
        totalPages,
        hitsPerPage,
      ];
}
