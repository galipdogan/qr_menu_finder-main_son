import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:meilisearch/meilisearch.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/meilisearch_config.dart';
import '../core/services/nominatim_service.dart';
import '../core/maps/data/datasources/openstreetmap_details_remote_data_source.dart';
import '../core/maps/data/datasources/photon_remote_data_source.dart';
import '../core/maps/data/datasources/turkey_location_remote_data_source.dart';

import '../core/mapper/mapper.dart';

void injectCore(GetIt sl) {
  sl.registerLazySingleton<Mappr>(() => Mappr());
}

Future<void> injectExternal(GetIt sl) async {
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAnalytics.instance);
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => FirebaseStorage.instance);

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  if (MeiliSearchConfig.isEnabled) {
    sl.registerLazySingleton(
      () => MeiliSearchClient(MeiliSearchConfig.host, MeiliSearchConfig.apiKey),
    );
  }

  // Centralized Nominatim service (replaces old data source)
  sl.registerLazySingleton<NominatimService>(
    () => NominatimService(client: sl()),
  );

  sl.registerLazySingleton<PhotonRemoteDataSource>(
    () => PhotonRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<OpenStreetMapDetailsRemoteDataSource>(
    () => OpenStreetMapDetailsRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<TurkeyLocationRemoteDataSource>(
    () => TurkeyLocationRemoteDataSourceImpl(),
  );
}
