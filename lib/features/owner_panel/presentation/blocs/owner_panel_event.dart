import 'package:equatable/equatable.dart';

/// Base class for OwnerPanel events
abstract class OwnerPanelEvent extends Equatable {
  const OwnerPanelEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load owner stats
class OwnerStatsLoadRequested extends OwnerPanelEvent {
  final String ownerId;

  const OwnerStatsLoadRequested({required this.ownerId});

  @override
  List<Object?> get props => [ownerId];
}

/// Event triggered when OCR verification is tapped
class OcrVerificationTapped extends OwnerPanelEvent {
  final String ownerId;

  const OcrVerificationTapped({required this.ownerId});

  @override
  List<Object?> get props => [ownerId];
}

/// Event to load owner restaurants
class OwnerRestaurantsLoadRequested extends OwnerPanelEvent {
  final String ownerId;

  const OwnerRestaurantsLoadRequested({required this.ownerId});

  @override
  List<Object?> get props => [ownerId];
}

/// Event to request owner upgrade
class OwnerUpgradeRequested extends OwnerPanelEvent {
  final String userId;

  const OwnerUpgradeRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to refresh owner panel data
class OwnerPanelRefreshRequested extends OwnerPanelEvent {
  final String ownerId;

  const OwnerPanelRefreshRequested({required this.ownerId});

  @override
  List<Object?> get props => [ownerId];
}
