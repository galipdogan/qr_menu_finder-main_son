import 'package:get_it/get_it.dart';

import 'injection/analytics_injection.dart';
import 'injection/auth_injection.dart';
import 'injection/core_external_injection.dart';
import 'injection/favorites_injection.dart';
import 'injection/history_injection.dart';
import 'injection/home_injection.dart';
import 'injection/item_moderation_injection.dart';
import 'injection/menu_injection.dart';
import 'injection/notifications_injection.dart';
import 'injection/ocr_injection.dart';
import 'injection/owner_panel_injection.dart';
import 'injection/price_comparison_injection.dart';
import 'injection/profile_injection.dart';
import 'injection/restaurant_injection.dart';
import 'injection/review_injection.dart';
import 'injection/search_injection.dart';
import 'injection/settings_injection.dart';
import 'injection/storage_injection.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  await injectExternal(sl);
  injectCore(sl);
  injectAuth(sl);
  injectRestaurant(sl);
  injectMenu(sl);
  injectAnalytics(sl);
  injectReview(sl);
  injectSearch(sl);
  injectHistory(sl);
  injectFavorites(sl);
  injectProfile(sl);
  injectOwnerPanel(sl);
  injectHome(sl);
  injectItemModeration(sl);
  injectSettings(sl);
  injectNotifications(sl);
  injectOcr(sl);
  injectStorage(sl);
  injectPriceComparison(sl);
}
