part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {
  final String query;

  const SearchLoading({required this.query});

  @override
  List<Object> get props => [query];
}

class SearchLoaded extends SearchState {
  final List<PlaceSuggestion> suggestions;
  final String query;

  const SearchLoaded({
    required this.suggestions,
    required this.query,
  });

  @override
  List<Object> get props => [suggestions, query];
}

class SearchError extends SearchState {
  final String message;
  final String query;

  const SearchError({
    required this.message,
    required this.query,
  });

  @override
  List<Object> get props => [message, query];
}

class SearchSuggestionSelectedState extends SearchState {
  final PlaceSuggestion suggestion;
  final String query;

  const SearchSuggestionSelectedState({
    required this.suggestion,
    required this.query,
  });

  @override
  List<Object> get props => [suggestion, query];
}