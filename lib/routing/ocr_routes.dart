import 'package:go_router/go_router.dart';
import 'package:qr_menu_finder/features/ocr/presentation/pages/ocr_verification_page.dart';
import 'route_names.dart';

final List<GoRoute> ocrRoutes = [
  GoRoute(
    path: RouteNames.ocrVerification,
    builder: (context, state) {
      final restaurantId = state.pathParameters['restaurantId']!;
      
      // Get imagePath from extra or query parameters
      String imagePath = '';
      if (state.extra != null && state.extra is Map) {
        final extraMap = state.extra as Map;
        imagePath = extraMap['imagePath'] ?? '';
      } else {
        imagePath = state.uri.queryParameters['imagePath'] ?? '';
      }
      
      return OcrVerificationPage(
        restaurantId: restaurantId,
        imagePath: imagePath,
      );
    },
  ),
];
