import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ViewToggleButtons extends StatelessWidget {
  final bool isMapView;
  final VoidCallback onListViewPressed;
  final VoidCallback onMapViewPressed;

  const ViewToggleButtons({
    super.key,
    required this.isMapView,
    required this.onListViewPressed,
    required this.onMapViewPressed,
  });

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 22,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            icon: Icons.list_rounded,
            isSelected: !isMapView,
            onPressed: onListViewPressed,
            tooltip: 'Liste',
          ),
          Container(
            width: 1,
            height: 32,
            color: AppColors.border,
          ),
          _buildToggleButton(
            icon: Icons.map_rounded,
            isSelected: isMapView,
            onPressed: onMapViewPressed,
            tooltip: 'Harita',
          ),
        ],
      ),
    );
  }
}
