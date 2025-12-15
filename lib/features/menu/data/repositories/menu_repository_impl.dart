import 'package:dartz/dartz.dart';
import '../../../../core/error/error.dart';
import '../../../../core/utils/repository_helper.dart';
import '../../../ocr/data/datasources/ocr_remote_data_source.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_data_source.dart';

/// Implementation of menu repository
class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;
  final OcrRemoteDataSource ocrRemoteDataSource;

  MenuRepositoryImpl({
    required this.remoteDataSource,
    required this.ocrRemoteDataSource,
  });

  @override
  Future<Either<Failure, List<MenuItem>>> getMenuItemsByRestaurantId({
    required String restaurantId,
    String? category,
    int limit = 50,
  }) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getMenuItemsByRestaurantId(
        restaurantId: restaurantId,
        category: category,
        limit: limit,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, MenuItem>> getMenuItemById(String id) async {
    return RepositoryHelper.execute(
      () => remoteDataSource.getMenuItemById(id),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<MenuItem>>> searchMenuItems({
    required String query,
    String? restaurantId,
    String? category,
    int limit = 20,
  }) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.searchMenuItems(
        query: query,
        restaurantId: restaurantId,
        category: category,
        limit: limit,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, MenuItem>> createMenuItem(MenuItem menuItem) async {
    try {
      // Convert entity to model for data layer
      // Note: This would need additional data like menuId, searchableText
      // In a real implementation, this would be handled by a mapper
      throw UnimplementedError(
        'Create menu item needs additional implementation',
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MenuItem>> updateMenuItem(MenuItem menuItem) async {
    try {
      // Convert entity to model for data layer
      // Note: This would need additional data like menuId, searchableText
      // In a real implementation, this would be handled by a mapper
      throw UnimplementedError(
        'Update menu item needs additional implementation',
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMenuItem(String id) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.deleteMenuItem(id),
    );
  }

  @override
  Future<Either<Failure, List<MenuItem>>> getPopularMenuItems({
    int limit = 10,
  }) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getPopularMenuItems(limit: limit),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<MenuItem>>> getMenuItemsByCategory({
    required String category,
    int limit = 20,
  }) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getMenuItemsByCategory(
        category: category,
        limit: limit,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<MenuItem>>> getMenuItemsByContributor({
    required String contributorId,
    int limit = 20,
  }) async {
    return RepositoryHelper.executeList(
      () => remoteDataSource.getMenuItemsByContributor(
        contributorId: contributorId,
        limit: limit,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, void>> addMenuUrl({
    required String restaurantId,
    required String url,
    required String type,
  }) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.addMenuLink(
        restaurantId: restaurantId,
        url: url,
        type: type,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> addMenuPhoto({
    required String restaurantId,
    required String photoUrl,
  }) async {
    return RepositoryHelper.executeVoid(
      () => remoteDataSource.addMenuLink(
        restaurantId: restaurantId,
        url: photoUrl,
        type: 'photo',
      ),
    );
  }

  @override
  Future<void> processMenuLink(String linkItemId) async {
    // 1) Link item’ı çek
    final linkItem = await remoteDataSource.getMenuItemById(linkItemId);

    if (linkItem.url == null) {
      throw ServerException('Link item has no URL');
    }

    // 2) OCR çalıştır
    final parsedItems = await ocrRemoteDataSource.extractAndParseMenuItems(
      linkItem.url!,
    );

    // 3) OCR item’larını oluştur
    for (final item in parsedItems) {
      await remoteDataSource.createOcrItem(
        restaurantId: linkItem.restaurantId,
        price: item.price,
        currency: item.currency,
      );
    }

    // 4) Link item’ı processed yap
    await remoteDataSource.markLinkAsProcessed(linkItemId);
  }
}
