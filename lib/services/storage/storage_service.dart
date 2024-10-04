import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, File file) async {
    Reference storageRef = _storage.ref().child(path);
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> deleteFolder(String folderPath) async {
    final ref = _storage.ref(folderPath);
    final result = await ref.listAll();

    await Future.wait(result.items.map((item) => item.delete()));
    await Future.wait(
        result.prefixes.map((prefix) => deleteFolder(prefix.fullPath)));
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }
}
