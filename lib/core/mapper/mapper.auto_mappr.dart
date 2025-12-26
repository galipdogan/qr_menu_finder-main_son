// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoMapprGenerator
// **************************************************************************

// ignore_for_file: type=lint, unnecessary_cast, unused_local_variable

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_mappr_annotation/auto_mappr_annotation.dart' as _i1;

import '../../features/auth/data/models/user_model.dart' as _i2;
import '../../features/auth/domain/entities/user.dart' as _i3;
import '../../features/menu/data/models/menu_item_model.dart' as _i6;
import '../../features/menu/domain/entities/menu_item.dart' as _i7;
import '../../features/restaurant/data/models/restaurant_model.dart' as _i4;
import '../../features/restaurant/domain/entities/restaurant.dart' as _i5;
import '../../features/review/data/models/review_model.dart' as _i8;
import '../../features/review/domain/entities/review.dart' as _i9;
import 'mapper.dart' as _i10;

/// {@template package:qr_menu_finder/core/mapper/mapper.dart}
/// Available mappings:
/// - `UserModel` → `User`.
/// - `User` → `UserModel`.
/// - `RestaurantModel` → `Restaurant`.
/// - `Restaurant` → `RestaurantModel`.
/// - `MenuItemModel` → `MenuItem`.
/// - `MenuItem` → `MenuItemModel`.
/// - `ReviewModel` → `Review`.
/// - `Review` → `ReviewModel`.
/// {@endtemplate}
class $Mappr implements _i1.AutoMapprInterface {
  const $Mappr();

  Type _typeOf<T>() => T;

  List<_i1.AutoMapprInterface> get _delegates => const [];

  /// {@macro AutoMapprInterface:canConvert}
  /// {@macro package:qr_menu_finder/core/mapper/mapper.dart}
  @override
  bool canConvert<SOURCE, TARGET>({bool recursive = true}) {
    final sourceTypeOf = _typeOf<SOURCE>();
    final targetTypeOf = _typeOf<TARGET>();
    if ((sourceTypeOf == _typeOf<_i2.UserModel>() ||
            sourceTypeOf == _typeOf<_i2.UserModel?>()) &&
        (targetTypeOf == _typeOf<_i3.User>() ||
            targetTypeOf == _typeOf<_i3.User?>())) {
      return true;
    }
    if ((sourceTypeOf == _typeOf<_i3.User>() ||
            sourceTypeOf == _typeOf<_i3.User?>()) &&
        (targetTypeOf == _typeOf<_i2.UserModel>() ||
            targetTypeOf == _typeOf<_i2.UserModel?>())) {
      return true;
    }
    if ((sourceTypeOf == _typeOf<_i4.RestaurantModel>() ||
            sourceTypeOf == _typeOf<_i4.RestaurantModel?>()) &&
        (targetTypeOf == _typeOf<_i5.Restaurant>() ||
            targetTypeOf == _typeOf<_i5.Restaurant?>())) {
      return true;
    }
    if ((sourceTypeOf == _typeOf<_i5.Restaurant>() ||
            sourceTypeOf == _typeOf<_i5.Restaurant?>()) &&
        (targetTypeOf == _typeOf<_i4.RestaurantModel>() ||
            targetTypeOf == _typeOf<_i4.RestaurantModel?>())) {
      return true;
    }
    if ((sourceTypeOf == _typeOf<_i6.MenuItemModel>() ||
            sourceTypeOf == _typeOf<_i6.MenuItemModel?>()) &&
        (targetTypeOf == _typeOf<_i7.MenuItem>() ||
            targetTypeOf == _typeOf<_i7.MenuItem?>())) {
      return true;
    }
    if ((sourceTypeOf == _typeOf<_i7.MenuItem>() ||
            sourceTypeOf == _typeOf<_i7.MenuItem?>()) &&
        (targetTypeOf == _typeOf<_i6.MenuItemModel>() ||
            targetTypeOf == _typeOf<_i6.MenuItemModel?>())) {
      return true;
    }
    if ((sourceTypeOf == _typeOf<_i8.ReviewModel>() ||
            sourceTypeOf == _typeOf<_i8.ReviewModel?>()) &&
        (targetTypeOf == _typeOf<_i9.Review>() ||
            targetTypeOf == _typeOf<_i9.Review?>())) {
      return true;
    }
    if ((sourceTypeOf == _typeOf<_i9.Review>() ||
            sourceTypeOf == _typeOf<_i9.Review?>()) &&
        (targetTypeOf == _typeOf<_i8.ReviewModel>() ||
            targetTypeOf == _typeOf<_i8.ReviewModel?>())) {
      return true;
    }
    if (recursive) {
      for (final mappr in _delegates) {
        if (mappr.canConvert<SOURCE, TARGET>()) {
          return true;
        }
      }
    }
    return false;
  }

  /// {@macro AutoMapprInterface:convert}
  /// {@macro package:qr_menu_finder/core/mapper/mapper.dart}
  @override
  TARGET convert<SOURCE, TARGET>(SOURCE? model) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return _convert(model)!;
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.convert(model)!;
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  /// {@macro AutoMapprInterface:tryConvert}
  /// {@macro package:qr_menu_finder/core/mapper/mapper.dart}
  @override
  TARGET? tryConvert<SOURCE, TARGET>(
    SOURCE? model, {
    void Function(Object error, StackTrace stackTrace, SOURCE? source)?
        onMappingError,
  }) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return _safeConvert(
        model,
        onMappingError: onMappingError,
      );
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.tryConvert(
          model,
          onMappingError: onMappingError,
        );
      }
    }

    return null;
  }

  /// {@macro AutoMapprInterface:convertIterable}
  /// {@macro package:qr_menu_finder/core/mapper/mapper.dart}
  @override
  Iterable<TARGET> convertIterable<SOURCE, TARGET>(Iterable<SOURCE?> model) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return model.map<TARGET>((item) => _convert(item)!);
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.convertIterable(model);
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  /// For iterable items, converts from SOURCE to TARGET if such mapping is configured, into Iterable.
  ///
  /// When an item in the source iterable is null, uses `whenSourceIsNull` if defined or null
  ///
  /// {@macro package:qr_menu_finder/core/mapper/mapper.dart}
  @override
  Iterable<TARGET?> tryConvertIterable<SOURCE, TARGET>(
    Iterable<SOURCE?> model, {
    void Function(Object error, StackTrace stackTrace, SOURCE? source)?
        onMappingError,
  }) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return model.map<TARGET?>(
          (item) => _safeConvert(item, onMappingError: onMappingError));
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.tryConvertIterable(
          model,
          onMappingError: onMappingError,
        );
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  /// {@macro AutoMapprInterface:convertList}
  /// {@macro package:qr_menu_finder/core/mapper/mapper.dart}
  @override
  List<TARGET> convertList<SOURCE, TARGET>(Iterable<SOURCE?> model) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return convertIterable<SOURCE, TARGET>(model).toList();
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.convertList(model);
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  /// For iterable items, converts from SOURCE to TARGET if such mapping is configured, into List.
  ///
  /// When an item in the source iterable is null, uses `whenSourceIsNull` if defined or null
  ///
  /// {@macro package:qr_menu_finder/core/mapper/mapper.dart}
  @override
  List<TARGET?> tryConvertList<SOURCE, TARGET>(
    Iterable<SOURCE?> model, {
    void Function(Object error, StackTrace stackTrace, SOURCE? source)?
        onMappingError,
  }) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return tryConvertIterable<SOURCE, TARGET>(
        model,
        onMappingError: onMappingError,
      ).toList();
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.tryConvertList(
          model,
          onMappingError: onMappingError,
        );
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  /// {@macro AutoMapprInterface:convertSet}
  /// {@macro package:qr_menu_finder/core/mapper/mapper.dart}
  @override
  Set<TARGET> convertSet<SOURCE, TARGET>(Iterable<SOURCE?> model) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return convertIterable<SOURCE, TARGET>(model).toSet();
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.convertSet(model);
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  /// For iterable items, converts from SOURCE to TARGET if such mapping is configured, into Set.
  ///
  /// When an item in the source iterable is null, uses `whenSourceIsNull` if defined or null
  ///
  /// {@macro package:qr_menu_finder/core/mapper/mapper.dart}
  @override
  Set<TARGET?> tryConvertSet<SOURCE, TARGET>(
    Iterable<SOURCE?> model, {
    void Function(Object error, StackTrace stackTrace, SOURCE? source)?
        onMappingError,
  }) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return tryConvertIterable<SOURCE, TARGET>(
        model,
        onMappingError: onMappingError,
      ).toSet();
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.tryConvertSet(
          model,
          onMappingError: onMappingError,
        );
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  TARGET? _convert<SOURCE, TARGET>(
    SOURCE? model, {
    bool canReturnNull = false,
  }) {
    final sourceTypeOf = _typeOf<SOURCE>();
    final targetTypeOf = _typeOf<TARGET>();
    if ((sourceTypeOf == _typeOf<_i2.UserModel>() ||
            sourceTypeOf == _typeOf<_i2.UserModel?>()) &&
        (targetTypeOf == _typeOf<_i3.User>() ||
            targetTypeOf == _typeOf<_i3.User?>())) {
      if (canReturnNull && model == null) {
        return null;
      }
      return (_map__i2$UserModel_To__i3$User((model as _i2.UserModel?))
          as TARGET);
    }
    if ((sourceTypeOf == _typeOf<_i3.User>() ||
            sourceTypeOf == _typeOf<_i3.User?>()) &&
        (targetTypeOf == _typeOf<_i2.UserModel>() ||
            targetTypeOf == _typeOf<_i2.UserModel?>())) {
      if (canReturnNull && model == null) {
        return null;
      }
      return (_map__i3$User_To__i2$UserModel((model as _i3.User?)) as TARGET);
    }
    if ((sourceTypeOf == _typeOf<_i4.RestaurantModel>() ||
            sourceTypeOf == _typeOf<_i4.RestaurantModel?>()) &&
        (targetTypeOf == _typeOf<_i5.Restaurant>() ||
            targetTypeOf == _typeOf<_i5.Restaurant?>())) {
      if (canReturnNull && model == null) {
        return null;
      }
      return (_map__i4$RestaurantModel_To__i5$Restaurant(
          (model as _i4.RestaurantModel?)) as TARGET);
    }
    if ((sourceTypeOf == _typeOf<_i5.Restaurant>() ||
            sourceTypeOf == _typeOf<_i5.Restaurant?>()) &&
        (targetTypeOf == _typeOf<_i4.RestaurantModel>() ||
            targetTypeOf == _typeOf<_i4.RestaurantModel?>())) {
      if (canReturnNull && model == null) {
        return null;
      }
      return (_map__i5$Restaurant_To__i4$RestaurantModel(
          (model as _i5.Restaurant?)) as TARGET);
    }
    if ((sourceTypeOf == _typeOf<_i6.MenuItemModel>() ||
            sourceTypeOf == _typeOf<_i6.MenuItemModel?>()) &&
        (targetTypeOf == _typeOf<_i7.MenuItem>() ||
            targetTypeOf == _typeOf<_i7.MenuItem?>())) {
      if (canReturnNull && model == null) {
        return null;
      }
      return (_map__i6$MenuItemModel_To__i7$MenuItem(
          (model as _i6.MenuItemModel?)) as TARGET);
    }
    if ((sourceTypeOf == _typeOf<_i7.MenuItem>() ||
            sourceTypeOf == _typeOf<_i7.MenuItem?>()) &&
        (targetTypeOf == _typeOf<_i6.MenuItemModel>() ||
            targetTypeOf == _typeOf<_i6.MenuItemModel?>())) {
      if (canReturnNull && model == null) {
        return null;
      }
      return (_map__i7$MenuItem_To__i6$MenuItemModel((model as _i7.MenuItem?))
          as TARGET);
    }
    if ((sourceTypeOf == _typeOf<_i8.ReviewModel>() ||
            sourceTypeOf == _typeOf<_i8.ReviewModel?>()) &&
        (targetTypeOf == _typeOf<_i9.Review>() ||
            targetTypeOf == _typeOf<_i9.Review?>())) {
      if (canReturnNull && model == null) {
        return null;
      }
      return (_map__i8$ReviewModel_To__i9$Review((model as _i8.ReviewModel?))
          as TARGET);
    }
    if ((sourceTypeOf == _typeOf<_i9.Review>() ||
            sourceTypeOf == _typeOf<_i9.Review?>()) &&
        (targetTypeOf == _typeOf<_i8.ReviewModel>() ||
            targetTypeOf == _typeOf<_i8.ReviewModel?>())) {
      if (canReturnNull && model == null) {
        return null;
      }
      return (_map__i9$Review_To__i8$ReviewModel((model as _i9.Review?))
          as TARGET);
    }
    throw Exception('No ${model.runtimeType} -> $targetTypeOf mapping.');
  }

  TARGET? _safeConvert<SOURCE, TARGET>(
    SOURCE? model, {
    void Function(Object error, StackTrace stackTrace, SOURCE? source)?
        onMappingError,
  }) {
    if (!useSafeMapping<SOURCE, TARGET>()) {
      return _convert(
        model,
        canReturnNull: true,
      );
    }
    try {
      return _convert(
        model,
        canReturnNull: true,
      );
    } catch (e, s) {
      onMappingError?.call(e, s, model);
      return null;
    }
  }

  /// {@macro AutoMapprInterface:useSafeMapping}
  /// {@macro package:qr_menu_finder/core/mapper/mapper.dart}
  @override
  bool useSafeMapping<SOURCE, TARGET>() {
    return false;
  }

  _i3.User _map__i2$UserModel_To__i3$User(_i2.UserModel? input) {
    final model = input;
    if (model == null) {
      throw Exception(
          r'Mapping UserModel → User failed because UserModel was null, and no default value was provided. '
          r'Consider setting the whenSourceIsNull parameter on the MapType<UserModel, User> to handle null values during mapping.');
    }
    return _i3.User(
      id: model.id,
      name: model.name,
      email: model.email,
      displayName: model.displayName,
      photoURL: model.photoURL,
      isEmailVerified: model.isEmailVerified,
      createdAt: model.createdAt,
      lastLoginAt: model.lastLoginAt,
      metadata: model.metadata,
      role: model.role,
      favorites: model.favorites,
    );
  }

  _i2.UserModel _map__i3$User_To__i2$UserModel(_i3.User? input) {
    final model = input;
    if (model == null) {
      throw Exception(
          r'Mapping User → UserModel failed because User was null, and no default value was provided. '
          r'Consider setting the whenSourceIsNull parameter on the MapType<User, UserModel> to handle null values during mapping.');
    }
    return _i2.UserModel(
      id: model.id,
      name: model.name,
      email: model.email,
      displayName: model.displayName,
      photoURL: model.photoURL,
      isEmailVerified: model.isEmailVerified,
      createdAt: model.createdAt,
      lastLoginAt: model.lastLoginAt,
      metadata: model.metadata,
      role: model.role,
      favorites: model.favorites,
    );
  }

  _i5.Restaurant _map__i4$RestaurantModel_To__i5$Restaurant(
      _i4.RestaurantModel? input) {
    final model = input;
    if (model == null) {
      throw Exception(
          r'Mapping RestaurantModel → Restaurant failed because RestaurantModel was null, and no default value was provided. '
          r'Consider setting the whenSourceIsNull parameter on the MapType<RestaurantModel, Restaurant> to handle null values during mapping.');
    }
    return _i5.Restaurant(
      id: model.id,
      name: model.name,
      description: model.description,
      address: model.address,
      latitude: model.latitude,
      longitude: model.longitude,
      phoneNumber: model.phoneNumber,
      website: model.website,
      imageUrls: model.imageUrls,
      rating: model.rating,
      reviewCount: model.reviewCount,
      categories: model.categories,
      openingHours: model.openingHours,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      ownerId: model.ownerId,
      hasMenu: model.hasMenu,
    );
  }

  _i4.RestaurantModel _map__i5$Restaurant_To__i4$RestaurantModel(
      _i5.Restaurant? input) {
    final model = input;
    if (model == null) {
      throw Exception(
          r'Mapping Restaurant → RestaurantModel failed because Restaurant was null, and no default value was provided. '
          r'Consider setting the whenSourceIsNull parameter on the MapType<Restaurant, RestaurantModel> to handle null values during mapping.');
    }
    return _i4.RestaurantModel(
      id: model.id,
      name: model.name,
      description: model.description,
      address: model.address,
      latitude: model.latitude,
      longitude: model.longitude,
      phoneNumber: model.phoneNumber,
      website: model.website,
      imageUrls: model.imageUrls,
      rating: model.rating,
      reviewCount: model.reviewCount,
      categories: model.categories,
      openingHours: model.openingHours,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      ownerId: model.ownerId,
      hasMenu: model.hasMenu,
      placeId: _i10.Mappr.generatePlaceId(model),
      geohash: _i10.Mappr.generateGeohash(model),
    );
  }

  _i7.MenuItem _map__i6$MenuItemModel_To__i7$MenuItem(
      _i6.MenuItemModel? input) {
    final model = input;
    if (model == null) {
      throw Exception(
          r'Mapping MenuItemModel → MenuItem failed because MenuItemModel was null, and no default value was provided. '
          r'Consider setting the whenSourceIsNull parameter on the MapType<MenuItemModel, MenuItem> to handle null values during mapping.');
    }
    return _i7.MenuItem(
      id: model.id,
      name: model.name,
      description: model.description,
      price: model.price,
      currency: model.currency,
      category: model.category,
      imageUrls: model.imageUrls,
      isAvailable: model.isAvailable,
      restaurantId: model.restaurantId,
      nutritionInfo: model.nutritionInfo,
      allergens: model.allergens,
      tags: model.tags,
      rating: model.rating,
      reviewCount: model.reviewCount,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      contributedBy: model.contributedBy,
      url: model.url,
      type: model.type,
      status: model.status,
      source: model.source,
    );
  }

  _i6.MenuItemModel _map__i7$MenuItem_To__i6$MenuItemModel(
      _i7.MenuItem? input) {
    final model = input;
    if (model == null) {
      throw Exception(
          r'Mapping MenuItem → MenuItemModel failed because MenuItem was null, and no default value was provided. '
          r'Consider setting the whenSourceIsNull parameter on the MapType<MenuItem, MenuItemModel> to handle null values during mapping.');
    }
    return _i6.MenuItemModel(
      id: model.id,
      name: model.name,
      description: model.description,
      price: model.price,
      currency: model.currency,
      category: model.category,
      imageUrls: model.imageUrls,
      isAvailable: model.isAvailable,
      restaurantId: model.restaurantId,
      nutritionInfo: model.nutritionInfo,
      allergens: model.allergens,
      tags: model.tags,
      rating: model.rating,
      reviewCount: model.reviewCount,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      contributedBy: model.contributedBy,
      type: model.type,
      url: model.url,
      source: model.source,
      status: model.status,
    );
  }

  _i9.Review _map__i8$ReviewModel_To__i9$Review(_i8.ReviewModel? input) {
    final model = input;
    if (model == null) {
      throw Exception(
          r'Mapping ReviewModel → Review failed because ReviewModel was null, and no default value was provided. '
          r'Consider setting the whenSourceIsNull parameter on the MapType<ReviewModel, Review> to handle null values during mapping.');
    }
    return _i9.Review(
      id: model.id,
      userId: model.userId,
      restaurantId: model.restaurantId,
      text: model.text,
      rating: model.rating,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  _i8.ReviewModel _map__i9$Review_To__i8$ReviewModel(_i9.Review? input) {
    final model = input;
    if (model == null) {
      throw Exception(
          r'Mapping Review → ReviewModel failed because Review was null, and no default value was provided. '
          r'Consider setting the whenSourceIsNull parameter on the MapType<Review, ReviewModel> to handle null values during mapping.');
    }
    return _i8.ReviewModel(
      id: model.id,
      userId: model.userId,
      restaurantId: model.restaurantId,
      text: model.text,
      rating: model.rating,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
