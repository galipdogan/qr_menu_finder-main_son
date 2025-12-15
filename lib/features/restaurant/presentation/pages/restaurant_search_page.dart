import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../routing/app_navigation.dart';
import '../blocs/restaurant_bloc.dart';
import '../widgets/restaurant_list_item.dart';
import '../../../../injection_container.dart' as di;
import '../blocs/restaurant_event.dart';
import '../blocs/restaurant_state.dart';

/// Wrapper widget to provide the RestaurantBloc.
class RestaurantSearchPage extends StatelessWidget {
  const RestaurantSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<RestaurantBloc>(),
      child: const RestaurantSearchView(),
    );
  }
}

/// The actual search view, now receiving the bloc from its context.
class RestaurantSearchView extends StatefulWidget {
  const RestaurantSearchView({super.key});

  @override
  State<RestaurantSearchView> createState() => _RestaurantSearchViewState();
}

class _RestaurantSearchViewState extends State<RestaurantSearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    context.read<RestaurantBloc>().add(
      RestaurantSearchRequested(query: query.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Restoran veya mutfak ara...',
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: BlocBuilder<RestaurantBloc, RestaurantState>(
        builder: (context, state) {
          if (state is RestaurantLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state is RestaurantError) {
            return Center(child: Text(state.message));
          }

          if (state is RestaurantListLoaded) {
            if (state.restaurants.isEmpty) {
              return const Center(
                child: Text('Aramanızla eşleşen restoran bulunamadı.'),
              );
            }

            return ListView.builder(
              itemCount: state.restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = state.restaurants[index];
                return RestaurantListItem(
                  restaurant: restaurant,
                  onTap: () {
                    AppNavigation.pushRestaurantDetail(
                      context,
                      restaurant.id,
                      initialRestaurant: restaurant,
                    );
                  },
                );
              },
            );
          }

          return const Center(
            child: Text('Restoran bulmak için bir arama yapın.'),
          );
        },
      ),
    );
  }
}
