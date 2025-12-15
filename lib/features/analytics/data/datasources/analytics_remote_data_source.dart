import 'package:firebase_analytics/firebase_analytics.dart';

abstract class AnalyticsRemoteDataSource {
  Future<void> initialize();
  Future<void> logEvent(String name, Map<String, dynamic>? parameters);
  Future<void> setUserProperty(String name, String value);
  Future<void> setUserId(String? id);
}

class FirebaseAnalyticsDataSourceImpl implements AnalyticsRemoteDataSource {
  final FirebaseAnalytics firebaseAnalytics;

  FirebaseAnalyticsDataSourceImpl({required this.firebaseAnalytics});

  @override
  Future<void> initialize() async {
    await firebaseAnalytics.setAnalyticsCollectionEnabled(true);
  }

  @override
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    final Map<String, Object>? convertedParams = parameters?.map(
      (key, value) => MapEntry(key, value as Object),
    );
    await firebaseAnalytics.logEvent(name: name, parameters: convertedParams);
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    await firebaseAnalytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> setUserId(String? id) async {
    await firebaseAnalytics.setUserId(id: id);
  }
}
