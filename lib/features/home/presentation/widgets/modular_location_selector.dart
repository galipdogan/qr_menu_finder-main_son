import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/turkey_location.dart';
import '../blocs/location_selection/location_selection_bloc.dart';

/// Modular Location Selector Widget - Clean Architecture Compliant
/// No direct service dependencies, only BLoC communication
class ModularLocationSelector extends StatefulWidget {
  final Function(double lat, double lng, String locationName) onLocationSelected;
  final String? initialCity;

  const ModularLocationSelector({
    super.key,
    required this.onLocationSelected,
    this.initialCity,
  });

  @override
  State<ModularLocationSelector> createState() => _ModularLocationSelectorState();
}

class _ModularLocationSelectorState extends State<ModularLocationSelector> {
  @override
  void initState() {
    super.initState();
    context.read<LocationSelectionBloc>().add(
      LocationSelectionLoadRequested(initialCity: widget.initialCity),
    );
  }

  void _onLocationConfirmed(TurkeyLocation location) {
    if (location.latitude != null && location.longitude != null) {
      widget.onLocationSelected(
        location.latitude!,
        location.longitude!,
        _buildLocationName(location),
      );
    }
  }

  String _buildLocationName(TurkeyLocation location) {
    final currentState = context.read<LocationSelectionBloc>().state;
    if (currentState is LocationSelectionLoaded) {
      final parts = <String>[];
      
      if (currentState.selectedNeighborhood != null) {
        parts.add(currentState.selectedNeighborhood!.name);
      }
      if (currentState.selectedDistrict != null) {
        parts.add(currentState.selectedDistrict!.name);
      }
      if (currentState.selectedCity != null) {
        parts.add(currentState.selectedCity!.name);
      }
      
      return parts.join(', ');
    }
    return location.name;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationSelectionBloc, LocationSelectionState>(
      listener: (context, state) {
        if (state is LocationSelectionConfirmedState) {
          _onLocationConfirmed(state.selectedLocation);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Konum Seçin',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            BlocBuilder<LocationSelectionBloc, LocationSelectionState>(
              builder: (context, state) {
                if (state is LocationSelectionLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: LoadingIndicator(),
                    ),
                  );
                }

                if (state is LocationSelectionError) {
                  return _buildErrorWidget(state.message);
                }

                if (state is LocationSelectionLoaded) {
                  return _buildLocationSelectors(state);
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Hata: $message',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelectors(LocationSelectionLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // City Selector
        _buildDropdown<TurkeyLocation>(
          label: 'İl Seçin',
          value: state.selectedCity,
          items: state.cities,
          onChanged: (city) {
            if (city != null) {
              context.read<LocationSelectionBloc>().add(
                LocationSelectionCityChanged(city),
              );
            }
          },
          itemBuilder: (city) => city.name,
        ),

        if (state.selectedCity != null) ...[
          const SizedBox(height: 16),
          // District Selector
          _buildDropdown<TurkeyLocation>(
            label: 'İlçe Seçin',
            value: state.selectedDistrict,
            items: state.districts,
            onChanged: (district) {
              if (district != null) {
                context.read<LocationSelectionBloc>().add(
                  LocationSelectionDistrictChanged(district),
                );
              }
            },
            itemBuilder: (district) => district.name,
            enabled: state.districts.isNotEmpty,
          ),
        ],

        if (state.selectedDistrict != null && state.neighborhoods.isNotEmpty) ...[
          const SizedBox(height: 16),
          // Neighborhood Selector
          _buildDropdown<TurkeyLocation>(
            label: 'Mahalle Seçin (İsteğe Bağlı)',
            value: state.selectedNeighborhood,
            items: state.neighborhoods,
            onChanged: (neighborhood) {
              if (neighborhood != null) {
                context.read<LocationSelectionBloc>().add(
                  LocationSelectionNeighborhoodChanged(neighborhood),
                );
              }
            },
            itemBuilder: (neighborhood) => neighborhood.name,
          ),
        ],

        const SizedBox(height: 24),

        // Confirm Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canConfirm(state) ? () {
              final location = state.selectedNeighborhood ?? 
                              state.selectedDistrict ?? 
                              state.selectedCity!;
              context.read<LocationSelectionBloc>().add(
                LocationSelectionConfirmed(location),
              );
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Konumu Onayla',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemBuilder,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: enabled ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: enabled ? AppColors.border : AppColors.textMuted,
            ),
            borderRadius: BorderRadius.circular(8),
            color: enabled ? Colors.white : AppColors.background,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text(
                'Seçiniz...',
                style: TextStyle(color: AppColors.textMuted),
              ),
              isExpanded: true,
              onChanged: enabled ? onChanged : null,
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemBuilder(item),
                    style: TextStyle(
                      color: enabled ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  bool _canConfirm(LocationSelectionLoaded state) {
    return state.selectedCity != null &&
           (state.selectedCity!.latitude != null && state.selectedCity!.longitude != null ||
            state.selectedDistrict?.latitude != null && state.selectedDistrict?.longitude != null ||
            state.selectedNeighborhood?.latitude != null && state.selectedNeighborhood?.longitude != null);
  }
}