import 'package:go_router/go_router.dart';
import 'package:qr_menu_finder/features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import 'route_names.dart';

final List<GoRoute> qrRoutes = [
  GoRoute(
    path: RouteNames.qrScanner,
    builder: (context, state) => const QRScannerPage(),
  ),
];
