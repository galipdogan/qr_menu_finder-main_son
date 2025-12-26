import 'package:get_it/get_it.dart';

import '../features/ocr/data/datasources/ocr_remote_data_source.dart';
import '../features/ocr/data/repositories/ocr_repository_impl.dart';
import '../features/ocr/domain/repositories/ocr_repository.dart';
import '../features/ocr/domain/usecases/extract_and_parse_menu_items_from_image.dart';
import '../features/ocr/domain/usecases/parse_text_to_menu_items.dart';
import '../features/ocr/domain/usecases/recognize_text_from_image.dart';

void injectOcr(GetIt sl) {
  sl.registerLazySingleton(() => RecognizeTextFromImage(sl()));
  sl.registerLazySingleton(() => ParseTextToMenuItems(sl()));
  sl.registerLazySingleton(() => ExtractAndParseMenuItemsFromImage(sl()));

  sl.registerLazySingleton<OcrRepository>(
    () => OcrRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<OcrRemoteDataSource>(() => MLKitOcrDataSourceImpl());
}
