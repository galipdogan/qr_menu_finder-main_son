import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import '../../domain/entities/menu_item.dart';
import '../../domain/usecases/get_menu_items_by_restaurant.dart';
import '../../domain/usecases/process_menu_link.dart';
import '../../domain/usecases/search_menu_items.dart';
import '../../domain/usecases/get_popular_menu_items.dart';
import '../../domain/usecases/get_menu_items_by_category.dart';
import '../../domain/usecases/add_menu_photo.dart';
import '../../domain/usecases/add_menu_url.dart';

// EVENTS
abstract class MenuEvent extends Equatable {
  const MenuEvent();
  @override
  List<Object?> get props => [];
}

class ProcessMenuLinkEvent extends MenuEvent {
  final String linkItemId;
  const ProcessMenuLinkEvent(this.linkItemId);
  @override
  List<Object?> get props => [linkItemId];
}

class MenuItemsByRestaurantRequested extends MenuEvent {
  final String restaurantId;
  final String? category;
  final int limit;

  const MenuItemsByRestaurantRequested({
    required this.restaurantId,
    this.category,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [restaurantId, category, limit];
}

class MenuItemSearchRequested extends MenuEvent {
  final String query;
  final String? restaurantId;
  final String? category;
  final int limit;

  const MenuItemSearchRequested({
    required this.query,
    this.restaurantId,
    this.category,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, restaurantId, category, limit];
}

class MenuPopularItemsRequested extends MenuEvent {
  final int limit;
  const MenuPopularItemsRequested({this.limit = 10});
  @override
  List<Object> get props => [limit];
}

class MenuItemsByCategoryRequested extends MenuEvent {
  final String category;
  final int limit;
  const MenuItemsByCategoryRequested({required this.category, this.limit = 20});
  @override
  List<Object> get props => [category, limit];
}

class UploadMenuPhoto extends MenuEvent {
  final String restaurantId;
  final File imageFile;
  const UploadMenuPhoto({required this.restaurantId, required this.imageFile});
  @override
  List<Object?> get props => [restaurantId, imageFile];
}

class UploadMenuUrl extends MenuEvent {
  final String restaurantId;
  final String url;
  final String type;
  const UploadMenuUrl({
    required this.restaurantId,
    required this.url,
    required this.type,
  });
  @override
  List<Object?> get props => [restaurantId, url, type];
}

// STATES
abstract class MenuState extends Equatable {
  const MenuState();
  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuItemsLoaded extends MenuState {
  final List<MenuItem> menuItems;
  final String? category;

  const MenuItemsLoaded({required this.menuItems, this.category});

  @override
  List<Object?> get props => [menuItems, category];
}

class MenuError extends MenuState {
  final String message;
  const MenuError({required this.message});
  @override
  List<Object> get props => [message];
}

class MenuUploadLoading extends MenuState {}

class MenuUploadSuccess extends MenuState {}

class MenuUploadFailure extends MenuState {
  final String message;
  const MenuUploadFailure({required this.message});
  @override
  List<Object> get props => [message];
}

// ✅ FINAL CLEAN BLOC
class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetMenuItemsByRestaurant getMenuItemsByRestaurant;
  final SearchMenuItems searchMenuItems;
  final GetPopularMenuItems getPopularMenuItems;
  final GetMenuItemsByCategory getMenuItemsByCategory;
  final AddMenuPhoto addMenuPhoto;
  final AddMenuUrl addMenuUrl;
  final ProcessMenuLink processMenuLinkUseCase;

  // ✅ Son yüklenen restoran ID'sini saklıyoruz
  String? _lastRestaurantId;

  MenuBloc({
    required this.getMenuItemsByRestaurant,
    required this.searchMenuItems,
    required this.getPopularMenuItems,
    required this.getMenuItemsByCategory,
    required this.addMenuPhoto,
    required this.addMenuUrl,
    required this.processMenuLinkUseCase,
  }) : super(MenuInitial()) {
    on<MenuItemsByRestaurantRequested>(_onMenuItemsByRestaurantRequested);
    on<MenuItemSearchRequested>(_onMenuItemSearchRequested);
    on<MenuPopularItemsRequested>(_onMenuPopularItemsRequested);
    on<MenuItemsByCategoryRequested>(_onMenuItemsByCategoryRequested);
    on<UploadMenuPhoto>(_onUploadMenuPhoto);
    on<UploadMenuUrl>(_onUploadMenuUrl);
    on<ProcessMenuLinkEvent>(_onProcessMenuLink);
  }

  // ✅ MENU LINK PROCESSING
  Future<void> _onProcessMenuLink(
    ProcessMenuLinkEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(MenuLoading());

    try {
      await processMenuLinkUseCase(event.linkItemId);

      if (_lastRestaurantId != null) {
        add(MenuItemsByRestaurantRequested(restaurantId: _lastRestaurantId!));
      } else {
        emit(MenuError(message: "Restaurant ID bulunamadı"));
      }
    } catch (e) {
      emit(MenuError(message: e.toString()));
    }
  }

  // ✅ MENU LOAD
  Future<void> _onMenuItemsByRestaurantRequested(
    MenuItemsByRestaurantRequested event,
    Emitter<MenuState> emit,
  ) async {
    _lastRestaurantId = event.restaurantId;

    emit(MenuLoading());

    final result = await getMenuItemsByRestaurant(
      MenuItemsByRestaurantParams(
        restaurantId: event.restaurantId,
        category: event.category,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(MenuError(message: failure.message)),
      (menuItems) =>
          emit(MenuItemsLoaded(menuItems: menuItems, category: event.category)),
    );
  }

  // ✅ SEARCH
  Future<void> _onMenuItemSearchRequested(
    MenuItemSearchRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(MenuLoading());

    final result = await searchMenuItems(
      SearchMenuItemsParams(
        query: event.query,
        restaurantId: event.restaurantId,
        category: event.category,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(MenuError(message: failure.message)),
      (menuItems) => emit(MenuItemsLoaded(menuItems: menuItems)),
    );
  }

  // ✅ POPULAR
  Future<void> _onMenuPopularItemsRequested(
    MenuPopularItemsRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(MenuLoading());

    final result = await getPopularMenuItems(
      PopularMenuItemsParams(limit: event.limit),
    );

    result.fold(
      (failure) => emit(MenuError(message: failure.message)),
      (menuItems) => emit(MenuItemsLoaded(menuItems: menuItems)),
    );
  }

  // ✅ CATEGORY
  Future<void> _onMenuItemsByCategoryRequested(
    MenuItemsByCategoryRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(MenuLoading());

    final result = await getMenuItemsByCategory(
      MenuItemsByCategoryParams(category: event.category, limit: event.limit),
    );

    result.fold(
      (failure) => emit(MenuError(message: failure.message)),
      (menuItems) =>
          emit(MenuItemsLoaded(menuItems: menuItems, category: event.category)),
    );
  }

  // ✅ UPLOAD PHOTO
  Future<void> _onUploadMenuPhoto(
    UploadMenuPhoto event,
    Emitter<MenuState> emit,
  ) async {
    emit(MenuUploadLoading());

    final result = await addMenuPhoto(
      AddMenuPhotoParams(
        restaurantId: event.restaurantId,
        imageFile: event.imageFile,
      ),
    );

    result.fold(
      (failure) => emit(MenuUploadFailure(message: failure.message)),
      (_) => emit(MenuUploadSuccess()),
    );
  }

  // ✅ UPLOAD URL
  Future<void> _onUploadMenuUrl(
    UploadMenuUrl event,
    Emitter<MenuState> emit,
  ) async {
    emit(MenuUploadLoading());

    final result = await addMenuUrl(
      AddMenuUrlParams(
        restaurantId: event.restaurantId,
        url: event.url,
        type: event.type,
      ),
    );

    result.fold(
      (failure) => emit(MenuUploadFailure(message: failure.message)),
      (_) => emit(MenuUploadSuccess()),
    );
  }
}
