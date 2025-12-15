import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/error.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

/// Abstract profile remote data source
abstract class ProfileRemoteDataSource {
  /// Get user profile by ID
  Future<UserProfileModel> getUserProfile(String uid);

  /// Update user profile
  Future<void> updateProfile(UserProfileModel profile);

  /// Stream user profile changes
  Stream<UserProfileModel> streamUserProfile(String uid);

  /// Update user role
  Future<void> updateUserRole({
    required String uid,
    required UserRole role,
  });
}

/// Firestore implementation of profile remote data source
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final String _collection = 'users';

  ProfileRemoteDataSourceImpl({required this.firestore});

  @override
  Future<UserProfileModel> getUserProfile(String uid) async {
    try {
      // 🔥 OPTIMIZATION: Try cache first, then server
      var doc = await firestore.collection(_collection).doc(uid).get(
        const GetOptions(source: Source.cache),
      );

      // If not in cache or doesn't exist, fetch from server
      if (!doc.exists) {
        doc = await firestore.collection(_collection).doc(uid).get(
          const GetOptions(source: Source.server),
        );
      }

      if (!doc.exists) {
        throw ServerException(
          'User profile not found',
          code: 'profile-not-found',
        );
      }

      return UserProfileModel.fromFirestore(doc);
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      throw ServerException(
        'Failed to get user profile: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateProfile(UserProfileModel profile) async {
    try {
      await firestore.collection(_collection).doc(profile.uid).set(
            profile.toFirestore(isUpdate: true),
            SetOptions(merge: true),
          );
    } catch (e, stackTrace) {
      throw ServerException(
        'Failed to update profile: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Stream<UserProfileModel> streamUserProfile(String uid) {
    try {
      return firestore
          .collection(_collection)
          .doc(uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          throw ServerException(
            'User profile not found',
            code: 'profile-not-found',
          );
        }
        return UserProfileModel.fromFirestore(doc);
      });
    } catch (e, stackTrace) {
      throw ServerException(
        'Failed to stream user profile: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateUserRole({
    required String uid,
    required UserRole role,
  }) async {
    try {
      await firestore.collection(_collection).doc(uid).update({
        'role': role.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      throw ServerException(
        'Failed to update user role: ${e.toString()}',
        stackTrace: stackTrace,
      );
    }
  }
}
