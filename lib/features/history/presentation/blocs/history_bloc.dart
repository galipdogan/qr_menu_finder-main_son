import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/clear_history.dart';
import '../../domain/usecases/delete_history_entry.dart';
import '../../domain/usecases/get_user_history.dart';
import '../../domain/usecases/track_search.dart';

// Events
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class HistoryLoadRequested extends HistoryEvent {
  final String userId;
  final int limit;

  const HistoryLoadRequested({
    required this.userId,
    this.limit = 100,
  });

  @override
  List<Object> get props => [userId, limit];
}

class HistoryClearRequested extends HistoryEvent {
  final String userId;

  const HistoryClearRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class HistoryEntryDeleteRequested extends HistoryEvent {
  final String historyId;
  final String userId; // To reload after delete

  const HistoryEntryDeleteRequested({
    required this.historyId,
    required this.userId,
  });

  @override
  List<Object> get props => [historyId, userId];
}

class HistorySearchTracked extends HistoryEvent {
  final String userId;
  final String searchQuery;

  const HistorySearchTracked({
    required this.userId,
    required this.searchQuery,
  });

  @override
  List<Object> get props => [userId, searchQuery];
}

// States
abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<HistoryEntry> entries;

  const HistoryLoaded({required this.entries});

  bool get isEmpty => entries.isEmpty;

  @override
  List<Object> get props => [entries];
}

class HistoryClearing extends HistoryState {
  final List<HistoryEntry> currentEntries;

  const HistoryClearing({required this.currentEntries});

  @override
  List<Object> get props => [currentEntries];
}

class HistoryCleared extends HistoryState {}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetUserHistory getUserHistory;
  final ClearHistory clearHistory;
  final DeleteHistoryEntry deleteHistoryEntry;
  final TrackSearch trackSearch;

  HistoryBloc({
    required this.getUserHistory,
    required this.clearHistory,
    required this.deleteHistoryEntry,
    required this.trackSearch,
  }) : super(HistoryInitial()) {
    on<HistoryLoadRequested>(_onHistoryLoadRequested);
    on<HistoryClearRequested>(_onHistoryClearRequested);
    on<HistoryEntryDeleteRequested>(_onHistoryEntryDeleteRequested);
    on<HistorySearchTracked>(_onHistorySearchTracked);
  }

  Future<void> _onHistoryLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());

    final result = await getUserHistory(
      GetUserHistoryParams(
        userId: event.userId,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(HistoryError(message: failure.message)),
      (entries) => emit(HistoryLoaded(entries: entries)),
    );
  }

  Future<void> _onHistoryClearRequested(
    HistoryClearRequested event,
    Emitter<HistoryState> emit,
  ) async {
    // Keep current entries visible while clearing
    final currentEntries = state is HistoryLoaded
        ? (state as HistoryLoaded).entries
        : <HistoryEntry>[];

    emit(HistoryClearing(currentEntries: currentEntries));

    final result = await clearHistory(
      ClearHistoryParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(HistoryError(message: failure.message)),
      (_) => emit(HistoryCleared()),
    );
  }

  Future<void> _onHistoryEntryDeleteRequested(
    HistoryEntryDeleteRequested event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await deleteHistoryEntry(
      DeleteHistoryEntryParams(historyId: event.historyId),
    );

    result.fold(
      (failure) => emit(HistoryError(message: failure.message)),
      (_) {
        // Reload history after successful delete
        add(HistoryLoadRequested(userId: event.userId));
      },
    );
  }

  Future<void> _onHistorySearchTracked(
    HistorySearchTracked event,
    Emitter<HistoryState> emit,
  ) async {
    // Track search in background, don't emit any state changes
    await trackSearch(
      TrackSearchParams(
        userId: event.userId,
        searchQuery: event.searchQuery,
      ),
    );
  }
}
