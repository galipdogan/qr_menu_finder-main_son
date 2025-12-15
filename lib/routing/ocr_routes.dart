import 'package:go_router/go_router.dart';
import 'package:qr_menu_finder/features/menu/presentation/pages/ocr_verification_page.dart';
import 'route_names.dart';

final List<GoRoute> ocrRoutes = [
  GoRoute(
    path: RouteNames.ocrVerification,
    builder: (context, state) {
      final restaurantId = state.pathParameters['restaurantId']!;
      final imagePath = state.uri.queryParameters['imagePath'] ?? '';
      return OcrVerificationPage(
        restaurantId: restaurantId,
        imagePath: imagePath,
      );
    },
  ),
];
