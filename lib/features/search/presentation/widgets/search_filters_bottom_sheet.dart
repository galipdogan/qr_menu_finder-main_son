import 'package:flutter/material.dart';

class SearchFiltersBottomSheet extends StatefulWidget {
  final String? initialCity;
  final String? initialDistrict;
  final String? initialCategory;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final double? initialMinRating;
  final Function(
    String? city,
    String? district,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  ) onApply;

  const SearchFiltersBottomSheet({
    super.key,
    this.initialCity,
    this.initialDistrict,
    this.initialCategory,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialMinRating,
    required this.onApply,
  });

  @override
  State<SearchFiltersBottomSheet> createState() =>
      _SearchFiltersBottomSheetState();
}

class _SearchFiltersBottomSheetState extends State<SearchFiltersBottomSheet> {
  late String? _selectedCity;
  late String? _selectedDistrict;
  late String? _selectedCategory;
  late double? _minPrice;
  late double? _maxPrice;
  late double? _minRating;

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // Sample data - should come from backend/constants
  final List<String> _cities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Antalya',
    'Bursa',
  ];

  final List<String> _categories = [
    'Türk Mutfağı',
    'Fast Food',
    'Pizza',
    'Kebap',
    'Balık',
    'Kahve & Tatlı',
    'Vegan',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialCity;
    _selectedDistrict = widget.initialDistrict;
    _selectedCategory = widget.initialCategory;
    _minPrice = widget.initialMinPrice;
    _maxPrice = widget.initialMaxPrice;
    _minRating = widget.initialMinRating;

    if (_minPrice != null) {
      _minPriceController.text = _minPrice!.toStringAsFixed(0);
    }
    if (_maxPrice != null) {
      _maxPriceController.text = _maxPrice!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _selectedCity = null;
      _selectedDistrict = null;
      _selectedCategory = null;
      _minPrice = null;
      _maxPrice = null;
      _minRating = null;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  void _apply() {
    widget.onApply(
      _selectedCity,
      _selectedDistrict,
      _selectedCategory,
      _minPrice,
      _maxPrice,
      _minRating,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Filtreler',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearAll,
                      child: const Text('Temizle'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _apply,
                      child: const Text('Uygula'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Filters content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // City filter
                    const Text(
                      'Şehir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCity,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Şehir seçin',
                      ),
                      items: _cities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Category filter
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Kategori seçin',
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Price range
                    const Text(
                      'Fiyat Aralığı',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minPriceController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Min (₺)',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _minPrice =
                                  value.isEmpty ? null : double.tryParse(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _maxPriceController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Max (₺)',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _maxPrice =
                                  value.isEmpty ? null : double.tryParse(value);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Rating filter
                    const Text(
                      'Minimum Puan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _minRating ?? 0,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _minRating == null || _minRating == 0
                          ? 'Hepsi'
                          : _minRating!.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _minRating = value == 0 ? null : value;
                        });
                      },
                    ),
                    Center(
                      child: Text(
                        _minRating == null || _minRating == 0
                            ? 'Tüm puanlar'
                            : '${_minRating!.toStringAsFixed(1)} ve üzeri',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
