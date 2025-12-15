import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/loading_indicator.dart';
import '../blocs/menu_bloc.dart';

/// OCR Verification Page - Migrated to Spark Plan
/// Uses client-side ML Kit instead of Cloud Vision
class OcrVerificationPage extends StatefulWidget {
  final String imagePath;
  final String restaurantId;

  const OcrVerificationPage({
    super.key,
    required this.imagePath,
    required this.restaurantId,
  });

  @override
  State<OcrVerificationPage> createState() => _OcrVerificationPageState();
}

class _OcrVerificationPageState extends State<OcrVerificationPage> {
  @override
  void initState() {
    super.initState();
    // Load menu items for restaurant
    context.read<MenuBloc>().add(
          MenuItemsByRestaurantRequested(restaurantId: widget.restaurantId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Menu Items'),
      ),
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state is MenuLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingIndicator(),
                  SizedBox(height: 16),
                  Text('Loading menu items...'),
                ],
              ),
            );
          }

          if (state is MenuError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (state is MenuItemsLoaded) {
            if (state.menuItems.isEmpty) {
              return const Center(
                child: Text('No items found in menu'),
              );
            }

            return ListView.builder(
              itemCount: state.menuItems.length,
              itemBuilder: (context, index) {
                final item = state.menuItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('${item.price} ${item.currency}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      // Approve item
                    },
                  ),
                );
              },
            );
          }

          return const Center(
            child: Text('Ready to process menu'),
          );
        },
      ),
    );
  }
}
