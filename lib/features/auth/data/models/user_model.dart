import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.displayName,
    super.photoURL,
    required super.isEmailVerified,
    required super.createdAt,
    super.lastLoginAt,
    super.metadata,
    super.role,
    super.favorites,
  });

  /// ✅ JSON serialize
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'displayName': displayName,
    'photoURL': photoURL,
    'isEmailVerified': isEmailVerified,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
    'metadata': metadata,
    'role': role.name,
    'favorites': favorites,
  };

  /// ✅ JSON deserialize
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String?,
    photoURL: json['photoURL'] as String?,
    isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastLoginAt: json['lastLoginAt'] != null
        ? DateTime.parse(json['lastLoginAt'] as String)
        : null,
    metadata: json['metadata'] as Map<String, dynamic>?,
    role: UserRoleX.fromString(json['role'] as String),
    favorites:
        (json['favorites'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );

  /// ✅ Firestore serialize
  Map<String, dynamic> toFirestore() => {
    'id': id,
    'name': name,
    'email': email,
    'displayName': displayName,
    'photoURL': photoURL,
    'isEmailVerified': isEmailVerified,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastLoginAt': lastLoginAt != null
        ? Timestamp.fromDate(lastLoginAt!)
        : null,
    'metadata': metadata,
    'role': role.name,
    'favorites': favorites,
  };

  /// ✅ Firestore deserialize
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('User document is empty');
    }

    return UserModel(
      id: data['id'] as String,
      name: (data['name'] as String?) ?? (data['displayName'] as String?) ?? '',
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
      metadata: data['metadata'] as Map<String, dynamic>?,
      role: UserRoleX.fromString(data['role'] as String),
      favorites:
          (data['favorites'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// ✅ String serialize
  String toJsonString() => jsonEncode(toJson());

  /// ✅ String deserialize
  factory UserModel.fromJsonString(String jsonString) =>
      UserModel.fromJson(jsonDecode(jsonString));
}
