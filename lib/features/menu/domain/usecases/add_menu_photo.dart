import 'dart:io'; // New import
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/menu_repository.dart';
import '../../../storage/domain/usecases/upload_file.dart'; // New import

class AddMenuPhoto implements UseCase<void, AddMenuPhotoParams> {
  final MenuRepository repository;
  final UploadFile uploadFile; // New dependency

  AddMenuPhoto(this.repository, this.uploadFile); // Updated constructor

  @override
  Future<Either<Failure, void>> call(AddMenuPhotoParams params) async {
    // Determine storage path
    final filePath =
        'menus/${params.restaurantId}/photos/${DateTime.now().millisecondsSinceEpoch}_${params.imageFile.path.split('/').last}';

    // Upload file using UploadFile UseCase
    final uploadResult = await uploadFile(
      UploadFileParams(file: params.imageFile, path: filePath),
    );

    return await uploadResult.fold(
      (failure) => Left(failure), // If upload fails, return the failure
      (downloadUrl) async {
        // If upload succeeds, call repository.addMenuPhoto with the URL
        return await repository.addMenuPhoto(
          restaurantId: params.restaurantId,
          photoUrl: downloadUrl, // Pass the URL
        );
      },
    );
  }
}

class AddMenuPhotoParams extends Equatable {
  final String restaurantId;
  final File imageFile; // Updated parameter

  const AddMenuPhotoParams({
    required this.restaurantId,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [restaurantId, imageFile];
}
