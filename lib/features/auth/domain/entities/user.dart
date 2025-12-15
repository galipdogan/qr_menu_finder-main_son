import 'package:equatable/equatable.dart';

/// User roles enum
enum UserRole { user, owner, admin, pendingOwner }

/// Extension for easier string conversion
extension UserRoleX on UserRole {
  String get name => toString().split('.').last;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.toString().split('.').last == role,
      orElse: () => UserRole.user,
    );
  }
}

/// User entity for clean architecture
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;
  final UserRole role;
  final List<String> favorites;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.isEmailVerified,
    required this.createdAt,
    this.lastLoginAt,
    this.metadata,
    this.role = UserRole.user,
    this.favorites = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    displayName,
    photoURL,
    isEmailVerified,
    createdAt,
    lastLoginAt,
    metadata,
    role,
    favorites,
  ];

  /// Copy with method for immutability
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
    UserRole? role,
    List<String>? favorites,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
      role: role ?? this.role,
      favorites: favorites ?? this.favorites,
    );
  }
}
