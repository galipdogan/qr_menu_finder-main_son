import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_menu_finder/features/auth/presentation/blocs/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../../core/error/error_messages.dart';
import '../../domain/entities/history_entry.dart';
import '../blocs/history_bloc.dart';
import '../../../../routing/app_navigation.dart';

/// History page - Clean Architecture implementation
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _clearHistory(BuildContext context, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ErrorMessages.confirmClearHistoryTitle),
        content: const Text(ErrorMessages.confirmClearHistoryContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(ErrorMessages.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(ErrorMessages.clear),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<HistoryBloc>().add(HistoryClearRequested(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(ErrorMessages.historyTitle),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: ErrorMessages.mustLogin,
          subtitle: ErrorMessages.mustLoginForHistory,
        ),
      );
    }

    return BlocConsumer<HistoryBloc, HistoryState>(
      listener: (context, state) {
        if (state is HistoryCleared) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(ErrorMessages.historyCleared),
                backgroundColor: AppColors.success,
              ),
            );
          // Reload history after clearing
          context.read<HistoryBloc>().add(HistoryLoadRequested(userId: userId));
        } else if (state is HistoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        // Load history on first build
        if (state is HistoryInitial) {
          context.read<HistoryBloc>().add(HistoryLoadRequested(userId: userId));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(ErrorMessages.historyTitle),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              if (state is HistoryLoaded && state.entries.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: ErrorMessages.confirmClearHistoryTitle,
                  onPressed: () => _clearHistory(context, userId),
                ),
            ],
          ),
          body: _buildBody(context, state, userId),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HistoryState state, String userId) {
    if (state is HistoryLoading || state is HistoryClearing) {
      return LoadingIndicator(
        message: state is HistoryClearing
            ? ErrorMessages.historyClearing
            : ErrorMessages.historyLoading,
      );
    }

    if (state is HistoryLoaded) {
      if (state.entries.isEmpty) {
        return EmptyState(
          icon: Icons.history,
          title: ErrorMessages.historyEmptyTitle,
          subtitle: ErrorMessages.historyEmptySubtitle,
          action: ElevatedButton(
            onPressed: () => AppNavigation.goHome(context),
            child: const Text(ErrorMessages.goBack),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<HistoryBloc>().add(HistoryLoadRequested(userId: userId));
          // Wait for the bloc to finish loading
          await context.read<HistoryBloc>().stream.firstWhere(
            (state) => state is! HistoryLoading,
          );
        },
        child: ListView.separated(
          itemCount: state.entries.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = state.entries[index];
            return _buildHistoryItem(context, item);
          },
        ),
      );
    }

    // Default/Error state
    return EmptyState(
      icon: Icons.history,
      title: ErrorMessages.historyEmptyTitle,
      subtitle: ErrorMessages.historyEmptySubtitle,
      action: ElevatedButton(
        onPressed: () => AppNavigation.goHome(context),
        child: const Text(ErrorMessages.goBack),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, HistoryEntry item) {
    IconData icon;
    String title;
    String subtitle;
    Color iconColor;

    switch (item.type) {
      case HistoryType.restaurantView:
        icon = Icons.restaurant;
        title = item.restaurantName ?? ErrorMessages.restaurantLabel;
        subtitle = 'Restoran görüntülendi';
        iconColor = AppColors.primary;
        break;
      case HistoryType.itemView:
        icon = Icons.restaurant_menu;
        title = item.itemName ?? 'Menü Ürünü';
        subtitle = item.restaurantName != null
            ? '${item.restaurantName} - Ürün görüntülendi'
            : 'Ürün görüntülendi';
        iconColor = Colors.orange;
        break;
      case HistoryType.menuView:
        icon = Icons.menu_book;
        title = item.restaurantName ?? ErrorMessages.menuLabel;
        subtitle = 'Menü görüntülendi';
        iconColor = Colors.green;
        break;
      case HistoryType.search:
        icon = Icons.search;
        title = item.searchQuery ?? 'Arama';
        subtitle = 'Arama yapıldı';
        iconColor = Colors.blue;
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        _formatTimestamp(item.timestamp),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      ),
      onTap: () {
        // Navigate to details if applicable
        if (item.type == HistoryType.restaurantView &&
            item.restaurantId != null) {
          AppNavigation.goRestaurantDetail(context, item.restaurantId!);
        }
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}d önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}s önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}g önce';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
