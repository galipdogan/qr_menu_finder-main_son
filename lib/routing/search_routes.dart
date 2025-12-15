import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../injection_container.dart';
import 'route_names.dart';
import '../features/search/presentation/pages/search_page.dart';
import '../features/search/presentation/blocs/search_bloc.dart';

final List<GoRoute> searchRoutes = [
  GoRoute(
    path: RouteNames.search,
    builder: (context, state) {
      final initialQuery = state.uri.queryParameters['q'];
      return BlocProvider(
        create: (context) => sl<SearchBloc>(),
        child: SearchPage(initialQuery: initialQuery),
      );
    },
  ),
];
