import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

abstract class StorageRemoteDataSource {
  Future<String> uploadFile(File file, String path);
  Future<void> deleteFile(String url);
}

class FirebaseStorageDataSourceImpl implements StorageRemoteDataSource {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageDataSourceImpl({required this.firebaseStorage});

  @override
  Future<String> uploadFile(File file, String path) async {
    final ref = firebaseStorage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Future<void> deleteFile(String url) async {
    final ref = firebaseStorage.refFromURL(url);
    await ref.delete();
  }
}
