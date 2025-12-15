// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';

/// Abstract auth remote data source
abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUser();

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({required String email});

  Future<UserModel> updateUserProfile({String? displayName, String? photoURL});

  Future<void> deleteAccount();

  Stream<UserModel?> get authStateChanges;
}

/// Firebase implementation of auth remote data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Named constructor for DI readability
  AuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _auth = firebaseAuth,
       _firestore = firestore;

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _fetchUser(firebaseUser);
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Sign in failed: No user returned');
      }
      return _fetchUser(firebaseUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException('Sign in failed: ${e.message}', code: e.code);
    } catch (e) {
      throw ServerException('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Sign up failed: No user returned');
      }

      // Optionally set display name in Auth profile
      if (displayName != null && displayName.isNotEmpty) {
        await firebaseUser.updateDisplayName(displayName);
      }

      final userModel = _mapFirebaseUser(firebaseUser);

      // Persist to Firestore
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException('Sign up failed: ${e.message}', code: e.code);
    } catch (e) {
      throw ServerException('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException('Password reset failed: ${e.message}', code: e.code);
    } catch (e) {
      throw ServerException('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw const AuthException('No user signed in');
    }

    if (displayName != null) await firebaseUser.updateDisplayName(displayName);
    if (photoURL != null) await firebaseUser.updatePhotoURL(photoURL);

    final updateData = {
      if (displayName != null) 'displayName': displayName,
      if (photoURL != null) 'photoURL': photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .update(updateData);

    // Return fresh mapped model (Auth values + updated Firestore fields)
    return _mapFirebaseUser(firebaseUser);
  }

  @override
  Future<void> deleteAccount() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw const AuthException('No user signed in');
    }
    await _firestore.collection('users').doc(firebaseUser.uid).delete();
    await firebaseUser.delete();
  }

  @override
  Stream<UserModel?> get authStateChanges =>
      _auth.authStateChanges().asyncMap((firebaseUser) async {
        if (firebaseUser == null) return null;
        return _fetchUser(firebaseUser);
      });

  // ---------------------------
  // Helpers
  // ---------------------------

  Future<UserModel> _fetchUser(firebase_auth.User firebaseUser) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) return UserModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.w('Failed to fetch user', error: e);
    }
    // Fallback to Auth mapping if Firestore doc missing
    return _mapFirebaseUser(firebaseUser);
  }

  UserModel _mapFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      name:
          firebaseUser.displayName ??
          firebaseUser.email?.split('@').first ??
          '',
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
      metadata: {
        'creationTime': firebaseUser.metadata.creationTime?.toIso8601String(),
        'lastSignInTime': firebaseUser.metadata.lastSignInTime
            ?.toIso8601String(),
      },
      role: UserRole.user,
      favorites: const [],
    );
  }
}
