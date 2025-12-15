import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_response.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/usecases/get_search_suggestions.dart';
import '../../domain/usecases/search_items.dart';

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQuerySubmitted extends SearchEvent {
  final SearchQuery query;

  const SearchQuerySubmitted({required this.query});

  @override
  List<Object> get props => [query];
}

class SearchQueryChanged extends SearchEvent {
  final String partialQuery;

  const SearchQueryChanged({required this.partialQuery});

  @override
  List<Object> get props => [partialQuery];
}

class SearchCleared extends SearchEvent {}

class SearchNextPageRequested extends SearchEvent {
  final SearchQuery currentQuery;

  const SearchNextPageRequested({required this.currentQuery});

  @override
  List<Object> get props => [currentQuery];
}

// States
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuggestionsLoading extends SearchState {
  final SearchResponse? previousResponse; // Keep previous results visible

  const SearchSuggestionsLoading({this.previousResponse});

  @override
  List<Object?> get props => [previousResponse];
}

class SearchSuggestionsLoaded extends SearchState {
  final List<String> suggestions;
  final SearchResponse? previousResponse;

  const SearchSuggestionsLoaded({
    required this.suggestions,
    this.previousResponse,
  });

  @override
  List<Object?> get props => [suggestions, previousResponse];
}

class SearchLoaded extends SearchState {
  final SearchResponse response;
  final SearchQuery query;

  const SearchLoaded({
    required this.response,
    required this.query,
  });

  bool get hasMore => response.hasMore;
  bool get isEmpty => response.isEmpty;
  List<SearchResult> get results => response.results;

  @override
  List<Object> get props => [response, query];
}

class SearchLoadingMore extends SearchState {
  final SearchResponse currentResponse;
  final SearchQuery currentQuery;

  const SearchLoadingMore({
    required this.currentResponse,
    required this.currentQuery,
  });

  @override
  List<Object> get props => [currentResponse, currentQuery];
}

class SearchError extends SearchState {
  final String message;
  final SearchResponse? previousResponse; // Keep previous results on error

  const SearchError({
    required this.message,
    this.previousResponse,
  });

  @override
  List<Object?> get props => [message, previousResponse];
}

// Bloc
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchItems searchItems;
  final GetSearchSuggestions getSearchSuggestions;

  SearchBloc({
    required this.searchItems,
    required this.getSearchSuggestions,
  }) : super(SearchInitial()) {
    on<SearchQuerySubmitted>(_onSearchQuerySubmitted);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchCleared>(_onSearchCleared);
    on<SearchNextPageRequested>(_onSearchNextPageRequested);
  }

  Future<void> _onSearchQuerySubmitted(
    SearchQuerySubmitted event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());

    final result = await searchItems(event.query);

    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (response) => emit(SearchLoaded(
        response: response,
        query: event.query,
      )),
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    // If query is empty, clear search
    if (event.partialQuery.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    // Keep previous results visible while loading suggestions
    final previousResponse = state is SearchLoaded
        ? (state as SearchLoaded).response
        : null;

    emit(SearchSuggestionsLoading(previousResponse: previousResponse));

    final result = await getSearchSuggestions(
      SuggestionsParams(partialQuery: event.partialQuery),
    );

    result.fold(
      (failure) => emit(SearchError(
        message: failure.message,
        previousResponse: previousResponse,
      )),
      (suggestions) => emit(SearchSuggestionsLoaded(
        suggestions: suggestions,
        previousResponse: previousResponse,
      )),
    );
  }

  void _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }

  Future<void> _onSearchNextPageRequested(
    SearchNextPageRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (state is! SearchLoaded) return;

    final currentState = state as SearchLoaded;
    if (!currentState.hasMore) return;

    emit(SearchLoadingMore(
      currentResponse: currentState.response,
      currentQuery: currentState.query,
    ));

    // Create query for next page
    final nextPageQuery = event.currentQuery.copyWith(
      page: event.currentQuery.page + 1,
    );

    final result = await searchItems(nextPageQuery);

    result.fold(
      (failure) => emit(SearchError(
        message: failure.message,
        previousResponse: currentState.response,
      )),
      (newResponse) {
        // Combine results
        final combinedResults = [
          ...currentState.response.results,
          ...newResponse.results,
        ];

        final combinedResponse = SearchResponse(
          results: combinedResults,
          totalHits: newResponse.totalHits,
          currentPage: newResponse.currentPage,
          totalPages: newResponse.totalPages,
          hitsPerPage: newResponse.hitsPerPage,
        );

        emit(SearchLoaded(
          response: combinedResponse,
          query: nextPageQuery,
        ));
      },
    );
  }
}
