import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils/app_logger.dart';

/// Tüm Repository'ler için temel sınıf
abstract class BaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore instance'ını al
  FirebaseFirestore get firestore => _firestore;

  /// Hata durumunu logla ve rethrow et
  Never handleError(String operation, dynamic error, [StackTrace? stackTrace]) {
    AppLogger.e(
      '$runtimeType: $operation failed',
      error: error,
      stackTrace: stackTrace,
    );
    throw error;
  }

  /// Başarılı operasyonu logla
  void logSuccess(String operation) {
    AppLogger.i('$runtimeType: $operation completed successfully');
  }

  /// Firestore operasyonunu try-catch ile wrap et
  Future<T> executeFirestoreOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    try {
      AppLogger.d('$runtimeType: Starting $operationName');
      final result = await operation();
      logSuccess(operationName);
      return result;
    } catch (error, stackTrace) {
      handleError(operationName, error, stackTrace);
    }
  }

  /// Collection reference'ı al
  CollectionReference collection(String path) {
    return _firestore.collection(path);
  }

  /// Document reference'ı al
  DocumentReference document(String path) {
    return _firestore.doc(path);
  }
}
