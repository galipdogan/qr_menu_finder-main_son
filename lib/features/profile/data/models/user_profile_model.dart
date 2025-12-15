import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

/// User profile model for data layer - extends domain entity
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
    super.favorites,
    super.createdAt,
    super.updatedAt,
  });

  /// Create from Firestore document
  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: _parseRole(data['role'] as String?),
      favorites: List<String>.from(data['favorites'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore({bool isUpdate = false}) {
    final data = <String, dynamic>{
      'name': name,
      'email': email,
      'role': role.name,
      'favorites': favorites,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Only set createdAt on new documents
    if (!isUpdate) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    return data;
  }

  /// Parse user role from string
  static UserRole _parseRole(String? roleStr) {
    switch (roleStr) {
      case 'owner':
        return UserRole.owner;
      case 'admin':
        return UserRole.admin;
      case 'pendingOwner':
      case 'pending_owner':
        return UserRole.pendingOwner;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  /// Convert to domain entity
  UserProfile toEntity() {
    return UserProfile(
      uid: uid,
      name: name,
      email: email,
      role: role,
      favorites: favorites,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert from domain entity
  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      favorites: entity.favorites,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
