import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String userId;
  final String restaurantId;
  final String text;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Review({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.text,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        restaurantId,
        text,
        rating,
        createdAt,
        updatedAt,
      ];
}