import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/compared_price_model.dart';

/// Remote data source for price comparison operations
abstract class PriceComparisonRemoteDataSource {
  /// Fetch compared prices for a menu item from Firestore
  Future<List<ComparedPriceModel>> getComparedPrices(
    String itemName,
    String currentRestaurantId,
  );
}

/// Implementation of PriceComparisonRemoteDataSource using Firestore
class PriceComparisonRemoteDataSourceImpl
    implements PriceComparisonRemoteDataSource {
  final FirebaseFirestore firestore;

  PriceComparisonRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ComparedPriceModel>> getComparedPrices(
    String itemName,
    String currentRestaurantId,
  ) async {
    try {
      AppLogger.i(
        'Fetching compared prices for "$itemName" excluding restaurant "$currentRestaurantId"',
      );

      // Query items with the same name but from different restaurants.
      // Firestore doesn't support inequality checks on different fields in the same query,
      // so we filter the current restaurant ID on the client-side.
      final querySnapshot = await firestore
          .collection('items') // Assuming a root 'items' collection
          .where('name', isEqualTo: itemName)
          .limit(10) // Limit to prevent excessive reads
          .get();

      if (querySnapshot.docs.isEmpty) {
        AppLogger.i('No items found with name "$itemName"');
        return [];
      }

      final results = querySnapshot.docs
          .where((doc) => doc.data()['restaurantId'] != currentRestaurantId)
          .map((doc) => ComparedPriceModel.fromFirestore(doc))
          .toList();

      AppLogger.i('Found ${results.length} compared prices');
      return results;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error fetching compared prices',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException('Failed to load price comparisons.');
    }
  }
}
