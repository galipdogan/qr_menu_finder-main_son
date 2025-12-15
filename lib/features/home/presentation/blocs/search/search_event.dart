part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  final double? latitude;
  final double? longitude;

  const SearchQueryChanged({
    required this.query,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [query, latitude, longitude];
}

class SearchQuerySubmitted extends SearchEvent {
  final String query;
  final double? latitude;
  final double? longitude;

  const SearchQuerySubmitted({
    required this.query,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [query, latitude, longitude];
}

class SearchCleared extends SearchEvent {}

class SearchSuggestionSelected extends SearchEvent {
  final PlaceSuggestion suggestion;

  const SearchSuggestionSelected(this.suggestion);

  @override
  List<Object> get props => [suggestion];
}