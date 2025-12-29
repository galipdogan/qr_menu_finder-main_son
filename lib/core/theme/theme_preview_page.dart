import 'package:flutter/material.dart';
import 'package:qr_menu_finder/core/theme/app_colors.dart';

/// Tema değişikliklerini test etmek için demo sayfa
class ThemePreviewPage extends StatelessWidget {
  const ThemePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Figma Tema Önizleme'),
        backgroundColor: AppColors.accent, // Golden yellow header
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık
            Text(
              'Food Delivery Tema',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Figma tasarımından uyarlanan modern, sıcak tema',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Renk Paleti
            _buildSection(
              context,
              'Renk Paleti',
              [
                _buildColorCard('Primary (Turuncu)', AppColors.primary),
                _buildColorCard('Accent (Altın)', AppColors.accent),
                _buildColorCard('Success', AppColors.success),
                _buildColorCard('Warning', AppColors.warning),
              ],
            ),

            const SizedBox(height: 32),

            // Butonlar
            _buildSection(
              context,
              'Butonlar (Pill-Shaped)',
              [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Primary Button'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined Button'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text Button'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Kartlar
            _buildSection(
              context,
              'Kartlar (24px Border Radius)',
              [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Restoran Adı',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Türk Mutfağı • 2.5 km',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppColors.ratingStar,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.8',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '30-40 dk',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Input Fields
            _buildSection(
              context,
              'Input Fields (20px Border Radius)',
              [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Restoran Ara',
                    hintText: 'Restoran veya yemek adı girin',
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Konum',
                    hintText: 'Adres girin',
                    prefixIcon: const Icon(Icons.location_on),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tipografi
            _buildSection(
              context,
              'Tipografi (Poppins)',
              [
                Text(
                  'Display Large',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 32,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Headline Large',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Title Large',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Body Large - Modern, yuvarlatılmış Poppins font ailesi ile sıcak ve dostane bir görünüm.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Body Medium - Okunabilirlik için optimize edilmiş satır yüksekliği.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Yeni Restoran'),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildColorCard(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 37, 141, 148),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
