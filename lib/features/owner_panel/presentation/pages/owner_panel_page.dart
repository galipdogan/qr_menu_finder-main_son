import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../blocs/owner_panel_bloc.dart';
import '../blocs/owner_panel_event.dart';
import '../blocs/owner_panel_state.dart';
import '../../../restaurant/presentation/pages/add_restaurant_page.dart';

/// İşletme Paneli - Sadece işletme sahipleri için (Modern BLoC version)
class OwnerPanelPage extends StatelessWidget {
  const OwnerPanelPage({super.key});

  void _loadStats(BuildContext context, String ownerId) {
    context.read<OwnerPanelBloc>().add(
      OwnerStatsLoadRequested(ownerId: ownerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşletme Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return _buildNeedLogin(context);
          }

          final user = authState.user;

          // Eğer kullanıcı owner veya admin değilse
          if (user.role != UserRole.owner && user.role != UserRole.admin) {
            return _buildUpgradePrompt(context, user);
          }

          // Owner veya Admin ise - Load stats and show panel
          _loadStats(context, user.id);

          return BlocBuilder<OwnerPanelBloc, OwnerPanelState>(
            builder: (context, ownerState) {
              if (ownerState is OwnerStatsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (ownerState is OwnerPanelError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text('Hata: ${ownerState.message}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadStats(context, user.id),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                );
              }

              if (ownerState is OwnerStatsLoaded) {
                return _buildOwnerPanel(context, user, ownerState.stats);
              }

              // Initial or other state - show loading
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated &&
              (state.user.role == UserRole.owner ||
                  state.user.role == UserRole.admin)) {
            return FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddRestaurantPage()),
                );

                if (result == true && context.mounted) {
                  // Restoran başarıyla eklendi, sayfayı yenile
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Restoran başarıyla eklendi!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Restoran Ekle'),
              backgroundColor: AppColors.primary,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNeedLogin(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Giriş Gerekli',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'İşletme paneline erişmek için lütfen giriş yapın',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.login),
              label: const Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradePrompt(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.store, size: 100, color: AppColors.primary),
          const SizedBox(height: 32),
          const Text(
            'İşletme Hesabına Yükselt',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Restoranınızı platforma ekleyin ve menülerinizi kolayca yönetin',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Özellikler
          _buildFeatureCard(
            icon: Icons.restaurant_menu,
            title: 'Menü Yönetimi',
            description: 'QR kod ile menülerinizi kolayca güncelleyin',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.analytics,
            title: 'İstatistikler',
            description: 'Restoranınızın performansını takip edin',
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.people,
            title: 'Müşteri Yorumları',
            description: 'Müşteri geri bildirimlerini görün ve yanıtlayın',
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.notifications_active,
            title: 'Anlık Bildirimler',
            description: 'Yeni yorumlar ve güncellemelerden haberdar olun',
            color: Colors.purple,
          ),

          const SizedBox(height: 40),

          // Başvuru Butonu
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                _showUpgradeDialog(context);
              },
              icon: const Icon(Icons.arrow_forward, size: 24),
              label: const Text(
                'İşletme Hesabı Başvurusu Yap',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextButton(
            onPressed: () {
              _showHelpDialog(context);
            },
            child: const Text('Daha fazla bilgi'),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOwnerPanel(BuildContext context, User user, dynamic stats) {
    // Extract stats values
    final restaurantCount = stats.restaurantCount ?? 0;
    final menuCount = stats.menuItemCount ?? 0;
    final reviewCount = stats.reviewCount ?? 0;
    final viewCount = stats.viewCount ?? 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hoş geldin mesajı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoş geldiniz,',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // İstatistik Kartları
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.restaurant,
                        title: 'Restoranlarım',
                        value: restaurantCount.toString(),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.menu_book,
                        title: 'Menü Ürünleri',
                        value: menuCount.toString(),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.rate_review,
                        title: 'Yorumlar',
                        value: reviewCount.toString(),
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.visibility,
                        title: 'Görüntülenme',
                        value: viewCount > 0 ? viewCount.toString() : 'Yakında',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Hızlı İşlemler
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Hızlı İşlemler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildQuickActionCard(
                  context,
                  icon: Icons.add_business,
                  title: 'Restoran Ekle',
                  color: Colors.blue,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Restoran ekleme yakında!')),
                    );
                  },
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.qr_code_scanner,
                  title: 'Menü Tara',
                  color: Colors.green,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR tarama yakında!')),
                    );
                  },
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.verified,
                  title: 'OCR Doğrula',
                  color: Colors.orange,
                  onTap: () async {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      // BLoC'a bir event göndererek restoran seçiciyi tetikle
                      // Bu event, BLoC'un restoranları yükleyip yeni bir state emit etmesini sağlar.
                      context.read<OwnerPanelBloc>().add(
                        OcrVerificationTapped(ownerId: authState.user.id),
                      );
                    }
                  },
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.analytics,
                  title: 'Raporlar',
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Raporlar yakında!')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Son Aktiviteler
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Son Aktiviteler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz aktivite yok',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Restoran eklediğinizde burada görünecek',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('İşletme Hesabı Başvurusu'),
          content: const Text(
            'İşletme hesabı başvurusu özelliği yakında aktif olacak.\n\n'
            'Restoran bilgilerinizi ve belgelerinizi yükleyerek '
            'işletme hesabına geçiş yapabileceksiniz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('İşletme Paneli Hakkında'),
          content: const SingleChildScrollView(
            child: Text(
              'İşletme Paneli ile neler yapabilirsiniz?\n\n'
              '• Restoranlarınızı ekleyin ve yönetin\n'
              '• Menülerinizi QR kod ile güncelleyin\n'
              '• Müşteri yorumlarını görün\n'
              '• Fiyat geçmişini takip edin\n'
              '• İstatistikleri izleyin\n\n'
              'İşletme hesabı oluşturmak için:\n'
              '1. İşletme belgelerinizi hazırlayın\n'
              '2. Başvuru yapın\n'
              '3. Onay bekleyin (24-48 saat)\n'
              '4. Onaylandıktan sonra panel aktif olur',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Anladım'),
            ),
          ],
        );
      },
    );
  }
}
