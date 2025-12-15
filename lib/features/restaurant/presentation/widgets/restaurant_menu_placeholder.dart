import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../routing/route_names.dart';
import 'package:go_router/go_router.dart';

class RestaurantMenuPlaceholder extends StatelessWidget {
  final String restaurantId;

  const RestaurantMenuPlaceholder({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('items')
          .where('restaurantId', isEqualTo: restaurantId)
          .limit(1) // ✅ sadece var mı yok mu kontrol ediyoruz
          .get(),
      builder: (context, snapshot) {
        final hasMenu = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.menu ?? 'Menu',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Menü varsa: "Menüyü Görüntüle" butonu
              if (hasMenu)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push(RouteNames.menuPath(restaurantId));
                    },
                    icon: const Icon(Icons.menu_book),
                    label: const Text("Show Menu"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // ✅ Her durumda: Add Menu butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push(RouteNames.addMenuPath(restaurantId));
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Menu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
