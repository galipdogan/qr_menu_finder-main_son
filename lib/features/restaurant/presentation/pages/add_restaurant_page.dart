import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core//utils/geohash_util.dart';
import '../../../auth/presentation/blocs/auth_state.dart';
import '../../../restaurant/data/models/restaurant_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
// import '../../../maps/data/services/location_service.dart'; // Removed
import '../blocs/restaurant_bloc.dart';
import '../blocs/restaurant_event.dart';
import '../blocs/restaurant_state.dart';
import '../../../home/presentation/blocs/home_bloc.dart'; // Import HomeBloc
import '../../../home/domain/entities/location.dart' as domain_location; // Alias to avoid conflict

class AddRestaurantPage extends StatelessWidget {
  const AddRestaurantPage({super.key});

  @override
  Widget build(BuildContext context) {
    // RestaurantBloc is already provided higher up in main.dart's MultiBlocProvider
    // If this page needs its own instance for a specific reason (e.g., different scope),
    // this BlocProvider should remain. Otherwise, it can be removed.
    // For now, assuming RestaurantBloc is already available via context.
    return const AddRestaurantView();
  }
}

class AddRestaurantView extends StatefulWidget {
  const AddRestaurantView({super.key});

  @override
  State<AddRestaurantView> createState() => _AddRestaurantViewState();
}

class _AddRestaurantViewState extends State<AddRestaurantView> {
  final _formKey = GlobalKey<FormState>();
  // final _locationService = LocationService(); // Removed

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();

  domain_location.Location? _selectedLocation; // Use aliased Location
  // bool _isGettingLocation = false; // Managed by HomeBloc state

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _getCurrentLocation() {
    context.read<HomeBloc>().add(HomeLoadCurrentLocation());
  }

  void _saveRestaurant() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen restoran konumunu seçin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu işlem için giriş yapmalısınız'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final lat = _selectedLocation!.latitude;
    final lng = _selectedLocation!.longitude;

    // Create the full RestaurantModel required by the data layer
    final restaurant = RestaurantModel(
      id: '', // Firestore will generate
      name: _nameController.text.trim(),
      ownerId: authState.user.id,
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      placeId:
          'manual_${DateTime.now().millisecondsSinceEpoch}', // Mark as manually added
      latitude: lat,
      longitude: lng,
      geohash: GeohashUtil.encode(lat, lng),
      phoneNumber: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      createdAt: DateTime.now(),
      isActive: true, // Manually added restaurants are active by default
      contributedBy: 'user_manual',
      isFromGooglePlaces: false,
    );

    // Dispatch the event to the bloc
    context.read<RestaurantBloc>().add(
      RestaurantCreateRequested(restaurant: restaurant),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restoran Ekle'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<RestaurantBloc, RestaurantState>(
        listener: (context, state) {
          if (state is RestaurantOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          } else if (state is RestaurantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, restState) {
          final isLoadingRestaurantOperation = restState is RestaurantLoading;

          return BlocListener<HomeBloc, HomeState>(
            listener: (context, homeState) {
              if (homeState is HomeLoaded) {
                setState(() {
                  _selectedLocation = homeState.location;
                  // Optionally, pre-fill city/district if needed,
                  // but for manual add, user input might be preferred.
                  // _cityController.text = homeState.locationName;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Konum başarıyla alındı!'),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (homeState is HomeLocationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Konum alınamadı: ${homeState.message}. Lütfen konum izinlerini kontrol edin.',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                children: [
                  // Restaurant Name
                  TextFormField(
                    controller: _nameController,
                    enabled: !isLoadingRestaurantOperation,
                    decoration: const InputDecoration(
                      labelText: 'Restoran Adı *',
                      prefixIcon: Icon(Icons.restaurant),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Restoran adı gerekli';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // City
                  TextFormField(
                    controller: _cityController,
                    enabled: !isLoadingRestaurantOperation,
                    decoration: const InputDecoration(
                      labelText: 'Şehir *',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Şehir gerekli';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // District
                  TextFormField(
                    controller: _districtController,
                    enabled: !isLoadingRestaurantOperation,
                    decoration: const InputDecoration(
                      labelText: 'İlçe *',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'İlçe gerekli';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    enabled: !isLoadingRestaurantOperation,
                    decoration: const InputDecoration(
                      labelText: 'Adres *',
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Adres gerekli';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    enabled: !isLoadingRestaurantOperation,
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                      hintText: '0555 555 55 55',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !isLoadingRestaurantOperation,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Location Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: AppColors.primary),
                              const SizedBox(width: 8),
                              const Text(
                                'Konum Bilgisi *',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_selectedLocation != null) ...[
                            Text(
                              'Enlem: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Boylam: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child:
                            BlocSelector<HomeBloc, HomeState, bool>(
                                selector: (state) => state is HomeLocationLoading,
                                builder: (context, isGettingLocation) {
                                  return ElevatedButton.icon(
                                    onPressed: isGettingLocation || isLoadingRestaurantOperation
                                        ? null
                                        : _getCurrentLocation,
                                    icon: isGettingLocation
                                        ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                        : const Icon(Icons.my_location),
                                    label: Text(
                                      _selectedLocation == null
                                          ? 'Mevcut Konumu Al'
                                          : 'Konumu Güncelle',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _selectedLocation == null
                                          ? AppColors.primary
                                          : AppColors.success,
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoadingRestaurantOperation ? null : _saveRestaurant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: isLoadingRestaurantOperation
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Restoranı Kaydet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
