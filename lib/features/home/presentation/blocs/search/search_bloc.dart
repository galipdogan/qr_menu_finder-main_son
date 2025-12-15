import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/place_suggestion.dart';
import '../../../domain/usecases/search_places.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchPlaces searchPlaces;
  Timer? _debounceTimer;

  SearchBloc({
    required this.searchPlaces,
  }) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchQuerySubmitted>(_onQuerySubmitted);
    on<SearchCleared>(_onSearchCleared);
    on<SearchSuggestionSelected>(_onSuggestionSelected);
  }

  void _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (event.query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    // Show loading immediately for better UX
    emit(SearchLoading(query: event.query));

    // Debounce search requests
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!isClosed) {
        add(SearchQuerySubmitted(
          query: event.query,
          latitude: event.latitude,
          longitude: event.longitude,
        ));
      }
    });
  }

  Future<void> _onQuerySubmitted(
    SearchQuerySubmitted event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading(query: event.query));

    final result = await searchPlaces(
      SearchPlacesParams(
        query: event.query.trim(),
        latitude: event.latitude,
        longitude: event.longitude,
        limit: 10,
      ),
    );

    if (!emit.isDone) {
      result.fold(
        (failure) => emit(SearchError(
          message: failure.message,
          query: event.query,
        )),
        (suggestions) => emit(SearchLoaded(
          suggestions: suggestions,
          query: event.query,
        )),
      );
    }
  }

  void _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    _debounceTimer?.cancel();
    emit(SearchInitial());
  }

  void _onSuggestionSelected(
    SearchSuggestionSelected event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchSuggestionSelectedState(
      suggestion: event.suggestion,
      query: event.suggestion.name,
    ));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}