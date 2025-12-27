import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../injection_container.dart' as di;
import '../../../../routing/app_navigation.dart';
import '../../../../core/error/error_messages.dart';
import '../blocs/menu_bloc.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/menu_category_filter.dart';

/// Modern menu page using clean architecture
class MenuPage extends StatefulWidget {
  final String restaurantId;
  final String? restaurantName;

  const MenuPage({super.key, required this.restaurantId, this.restaurantName});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late final MenuBloc _menuBloc;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _menuBloc = di.sl<MenuBloc>();
    _loadMenuItems();
  }

  @override
  void dispose() {
    _menuBloc.close();
    super.dispose();
  }

  void _loadMenuItems() {
    _menuBloc.add(
      MenuItemsByRestaurantRequested(
        restaurantId: widget.restaurantId,
        category: _selectedCategory,
      ),
    );
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _menuBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.restaurantName ?? ErrorMessages.menuTitle),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Future: Implement menu search functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMenuItems,
            ),
          ],
        ),

        body: Column(
          children: [
            // ✅ Menu Links Section (URLs and Photos)
            _buildMenuLinksSection(),

            // ✅ Category filter
            MenuCategoryFilter(
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),

            // ✅ Menu items list
            Expanded(
              child: BlocBuilder<MenuBloc, MenuState>(
                builder: (context, state) {
                  if (state is MenuLoading) {
                    return const LoadingIndicator();
                  }

                  if (state is MenuError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: _loadMenuItems,
                    );
                  }

                  if (state is MenuItemsLoaded) {
                    if (state.menuItems.isEmpty) {
                      return EmptyState(
                        icon: Icons.restaurant_menu,
                        title: ErrorMessages.menuNotFound,
                        subtitle: _selectedCategory != null
                            ? ErrorMessages.menuCategoryEmpty
                            : ErrorMessages.menuEmptyForRestaurant,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadMenuItems(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(
                          AppConstants.defaultPadding,
                        ),
                        itemCount: state.menuItems.length,
                        itemBuilder: (context, index) {
                          final menuItem = state.menuItems[index];
                          return MenuItemCard(
                            menuItem: menuItem,
                            onTap: () {
                              AppNavigation.pushItemDetail(
                                context,
                                widget.restaurantId,
                                menuItem.id,
                              );
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const EmptyState(
                    icon: Icons.restaurant_menu,
                    title: ErrorMessages.menuTitle,
                    subtitle: ErrorMessages.menuEmptyPrompt,
                  );
                },
              ),
            ),
          ],
        ),

        // ✅ Floating button (only when menu is empty)
        floatingActionButton: BlocBuilder<MenuBloc, MenuState>(
          builder: (context, state) {
            if (state is MenuItemsLoaded && state.menuItems.isNotEmpty) {
              return const SizedBox.shrink();
            }

            return FloatingActionButton(
              onPressed: () {
                // Future: Implement add menu item functionality (owner only)
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuLinksSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('restaurantId', isEqualTo: widget.restaurantId)
          .where('type', isEqualTo: 'link')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final menuLinks = snapshot.data!.docs;

        return Container(
          color: AppColors.primary.withValues(alpha: 0.05),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.link, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Menü Linkleri',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...menuLinks.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final url = data['url'] as String?;
                final source = data['source'] as String? ?? 'manual_link';

                if (url == null) return const SizedBox.shrink();

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      source == 'manual_link' ? Icons.link : Icons.photo,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      source == 'manual_link' ? 'Menü URL' : 'Menü Fotoğrafı',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      url.length > 50 ? '${url.substring(0, 50)}...' : url,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(Icons.open_in_new, color: AppColors.primary),
                    onTap: () async {
                      try {
                        await AppNavigation.launchExternalUrl(url);
                      } catch (e) {
                        if (context.mounted) {
                          // Extract clean error message
                          final errorMsg = e.toString().replaceFirst('Exception: ', '');
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMsg),
                              backgroundColor: AppColors.error,
                              action: SnackBarAction(
                                label: ErrorMessages.understood,
                                textColor: Colors.white,
                                onPressed: () {},
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
