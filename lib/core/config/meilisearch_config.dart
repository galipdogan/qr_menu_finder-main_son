import 'package:flutter_dotenv/flutter_dotenv.dart';

/// MeiliSearch configuration
class MeiliSearchConfig {
  /// MeiliSearch host URL
  static String get host {
    return dotenv.env['MEILISEARCH_HOST'] ?? 'http://localhost:7700';
  }

  /// MeiliSearch API key
  static String get apiKey {
    return dotenv.env['MEILISEARCH_API_KEY'] ?? '';
  }

  /// Whether MeiliSearch is enabled
  static bool get isEnabled {
    return dotenv.env['MEILISEARCH_ENABLED']?.toLowerCase() == 'true';
  }

  /// Timeout for MeiliSearch requests
  static Duration get timeout {
    final seconds =
        int.tryParse(dotenv.env['MEILISEARCH_TIMEOUT'] ?? '30') ?? 30;
    return Duration(seconds: seconds);
  }

  /// Index settings for restaurants
  static Map<String, dynamic> get restaurantsIndexSettings => {
    'searchableAttributes': [
      'name',
      'description',
      'categories',
      'address',
      'city',
      'district',
    ],
    'filterableAttributes': [
      'isActive',
      'city',
      'district',
      'categories',
      'rating',
    ],
    'sortableAttributes': ['rating', 'reviewCount', 'createdAt'],
    'displayedAttributes': [
      'id',
      'name',
      'description',
      'categories',
      'address',
      'city',
      'district',
      'rating',
      'reviewCount',
      'imageUrl',
      'isActive',
    ],
    'rankingRules': [
      'words',
      'typo',
      'proximity',
      'attribute',
      'sort',
      'exactness',
    ],
    'stopWords': ['the', 'a', 'an'],
    'synonyms': {
      'restaurant': ['restoran', 'lokanta'],
      'cafe': ['kafe', 'kahve'],
      'pizza': ['pide'],
    },
  };

  /// Index settings for menu items
  static Map<String, dynamic> get menuItemsIndexSettings => {
    'searchableAttributes': [
      'name',
      'description',
      'category',
      'restaurantName',
    ],
    'filterableAttributes': [
      'restaurantId',
      'category',
      'price',
      'isAvailable',
    ],
    'sortableAttributes': ['price', 'popularity', 'createdAt'],
    'displayedAttributes': [
      'id',
      'name',
      'description',
      'category',
      'price',
      'currency',
      'restaurantId',
      'restaurantName',
      'imageUrl',
      'isAvailable',
    ],
    'rankingRules': [
      'words',
      'typo',
      'proximity',
      'attribute',
      'sort',
      'exactness',
    ],
    'stopWords': ['the', 'a', 'an'],
    'synonyms': {
      'burger': ['hamburger'],
      'pizza': ['pide'],
      'kebab': ['kebap'],
    },
  };
}
