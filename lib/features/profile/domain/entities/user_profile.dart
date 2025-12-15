import 'package:equatable/equatable.dart';

/// User role enumeration
enum UserRole {
  user,
  owner,
  admin,
  pendingOwner,
}

/// Domain entity for user profile
class UserProfile extends Equatable {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final List<String> favorites;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.favorites = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    List<String>? favorites,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      favorites: favorites ?? this.favorites,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, role, favorites, createdAt, updatedAt];
}
