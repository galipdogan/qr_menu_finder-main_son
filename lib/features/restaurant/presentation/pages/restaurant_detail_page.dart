import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_menu_finder/features/restaurant/presentation/widgets/restaurant_detail_view.dart';
import 'package:qr_menu_finder/features/restaurant/presentation/widgets/restaurant_error_view.dart';
import 'package:qr_menu_finder/features/restaurant/presentation/widgets/restaurant_fallback_view.dart';

import '../../../../core//widgets/loading_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../analytics/domain/usecases/log_analytics_event.dart';
import '../../domain/entities/restaurant.dart';
import '../blocs/restaurant_bloc.dart';
import '../blocs/restaurant_event.dart';
import '../blocs/restaurant_state.dart';
import '../../../../injection_container.dart' as di;

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;
  final Restaurant? initialRestaurant;

  const RestaurantDetailPage({
    super.key,
    required this.restaurantId,
    this.initialRestaurant,
  });

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  @override
  void initState() {
    super.initState();

    context.read<RestaurantBloc>().add(
      RestaurantDetailRequested(id: widget.restaurantId),
    );

    AppLogger.i(
      '🏪 RestaurantDetailPage: Loading restaurant ${widget.restaurantId}',
    );

    di.sl<LogAnalyticsEvent>()(
      const LogAnalyticsEventParams(name: 'view_restaurant_detail_screen'),
    );
    di.sl<LogAnalyticsEvent>()(
      LogAnalyticsEventParams(
        name: 'view_restaurant',
        parameters: {'restaurant_id': widget.restaurantId},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocBuilder<RestaurantBloc, RestaurantState>(
        builder: (context, state) {
          if (state is RestaurantDetailLoaded) {
            final isMinimal =
                state.restaurant.address == null ||
                state.restaurant.address!.isEmpty ||
                state.restaurant.address == 'Adres bilgisi mevcut değil';

            if (isMinimal && widget.initialRestaurant != null) {
              AppLogger.i(
                '🔄 Using initialRestaurant (lat: ${widget.initialRestaurant!.latitude}, lon: ${widget.initialRestaurant!.longitude})',
              );
              return RestaurantDetailView(
                restaurant: widget.initialRestaurant!,
                isStale: false,
              );
            }

            return RestaurantDetailView(
              restaurant: state.restaurant,
              isStale: false,
            );
          }

          if (state is RestaurantError) {
            if (widget.initialRestaurant != null) {
              return RestaurantFallbackView(
                restaurant: widget.initialRestaurant!,
                message: state.message,
              );
            }

            return RestaurantErrorView(
              message: state.message,
              restaurantId: widget.restaurantId,
              onRetry: () {
                context.read<RestaurantBloc>().add(
                  RestaurantDetailRequested(id: widget.restaurantId),
                );
              },
            );
          }

          if (widget.initialRestaurant != null) {
            return RestaurantDetailView(
              restaurant: widget.initialRestaurant!,
              isStale: true,
            );
          }

          return const LoadingIndicator();
        },
      ),
    );
  }
}
