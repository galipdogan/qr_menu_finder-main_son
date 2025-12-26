import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/blocs/auth_event.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../../../review/presentation/blocs/review_bloc.dart';

/// Profil ekranı - Sadece normal kullanıcılar için
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    AppLogger.i('👤 ProfilePage: Initializing profile page');
    _loadUserReviews();
  }

  void _loadUserReviews() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      AppLogger.i('💬 ProfilePage: Loading user reviews via ReviewBloc');
      context.read<ReviewBloc>().add(LoadUserReviews(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ErrorMessages.profileTitle),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.push(RouteNames.editProfile);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text(ErrorMessages.mustLogin));
          }

          final user = state.user;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profil Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Email
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRoleName(user.role),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // İstatistikler
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.favorite,
                          title: ErrorMessages.favoritesTitle,
                          value: '${user.favorites.length}',
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: BlocBuilder<ReviewBloc, ReviewState>(
                          builder: (context, reviewState) {
                            String commentCount = '0';
                            if (reviewState is ReviewLoading) {
                              commentCount = '...';
                            } else if (reviewState is ReviewLoaded) {
                              commentCount = reviewState.reviews.length
                                  .toString();
                            }

                            return _buildStatCard(
                              context,
                              icon: Icons.rate_review,
                              title: ErrorMessages.reviewsTitle,
                              value: commentCount,
                              color: Colors.orange,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Menü Seçenekleri
                _buildMenuSection(
                  context,
                  title: ErrorMessages.accountSection,
                  items: [
                    _MenuItem(
                      icon: Icons.favorite,
                      title: ErrorMessages.favoritesTitle,
                      subtitle: '${user.favorites.length} favori',
                      onTap: () {
                        context.push(RouteNames.favorites);
                      },
                    ),
                    _MenuItem(
                      icon: Icons.rate_review,
                      title: ErrorMessages.reviewsTitle,
                      subtitle: ErrorMessages.myCommentsSubtitle,
                      onTap: () {
                        context.push(RouteNames.userReviews);
                      },
                    ),
                    _MenuItem(
                      icon: Icons.history,
                      title: ErrorMessages.historyTitle,
                      subtitle: ErrorMessages.visitedPlacesSubtitle,
                      onTap: () {
                        context.push(RouteNames.history);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildMenuSection(
                  context,
                  title: ErrorMessages.settingsTitle,
                  items: [
                    _MenuItem(
                      icon: Icons.person,
                      title: ErrorMessages.profileInfoTitle,
                      subtitle: ErrorMessages.profileInfoSubtitle,
                      onTap: () {
                        context.push(RouteNames.editProfile);
                      },
                    ),
                    _MenuItem(
                      icon: Icons.notifications,
                      title: ErrorMessages.notificationsTitle,
                      subtitle: ErrorMessages.notificationsSubtitle,
                      onTap: () {
                        context.push(
                          '${RouteNames.settings}?type=notifications',
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.language,
                      title: ErrorMessages.languageTitle,
                      subtitle: ErrorMessages.turkish,
                      onTap: () {
                        context.push('${RouteNames.settings}?type=language');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // İşletme Hesabı Upgrade
                if (user.role == UserRole.user)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.store,
                              size: 48,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              ErrorMessages.businessAccountTitle,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ErrorMessages.businessAccountSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Future: Navigate to business account registration
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      ErrorMessages.businessAccountSoon,
                                    ),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text(ErrorMessages.openBusinessAccount),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Çıkış Yap
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      icon: Icon(Icons.logout, color: AppColors.error),
                      label: const Text(
                          ErrorMessages.logoutTitle,
                          style: TextStyle(color: AppColors.error),
                        ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: items.map((item) {
              return ListTile(
                leading: Icon(item.icon, color: AppColors.primary),
                title: Text(item.title),
                subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: item.onTap,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.user:
        return ErrorMessages.roleUser;
      case UserRole.owner:
        return ErrorMessages.roleOwner;
      case UserRole.admin:
        return ErrorMessages.roleAdmin;
      case UserRole.pendingOwner:
        return ErrorMessages.rolePendingOwner;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    AppLogger.i('🚪 ProfilePage: Showing logout dialog');
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(ErrorMessages.logoutTitle),
          content: const Text(ErrorMessages.logoutConfirm),
          actions: [
            TextButton(
              onPressed: () {
                AppLogger.i('❌ ProfilePage: Logout cancelled');
                Navigator.of(dialogContext).pop();
              },
              child: const Text(ErrorMessages.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                AppLogger.i('✅ ProfilePage: User confirmed logout');
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(AuthSignOutRequested());
                Navigator.of(context).pop(); // Profil ekranından çık
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text(ErrorMessages.logoutTitle),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
