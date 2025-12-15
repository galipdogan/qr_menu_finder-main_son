import '../../features/auth/domain/entities/user.dart' as auth;
import '../../features/profile/domain/entities/user_profile.dart' as profile;

/// Extension to convert auth User to profile UserProfile
extension UserToUserProfileExtension on auth.User {
  profile.UserProfile toUserProfile() {
    return profile.UserProfile(
      uid: id,
      name: displayName ?? 'User',
      email: email,
      role: _convertRole(role),
      favorites: favorites,
      createdAt: createdAt,
      updatedAt: lastLoginAt,
    );
  }

  profile.UserRole _convertRole(auth.UserRole role) {
    switch (role) {
      case auth.UserRole.user:
        return profile.UserRole.user;
      case auth.UserRole.owner:
        return profile.UserRole.owner;
      case auth.UserRole.admin:
        return profile.UserRole.admin;
      case auth.UserRole.pendingOwner:
        return profile.UserRole.pendingOwner;
    }
  }
}
