import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb; // For kIsWeb check

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload user avatar and return download URL
  // Trong StorageService
  Future<String> uploadUserAvatar(String userId, dynamic imageData, {String? fileName}) async { // imageData có thể là File hoặc Uint8List
    try {
      String actualFileName = fileName ?? '${DateTime.now().millisecondsSinceEpoch}_avatar.jpg';
      // SỬA ĐƯỜNG DẪN Ở ĐÂY
      String filePath = 'profile_images/$userId/$actualFileName'; // Đường dẫn mới
      Reference ref = _storage.ref().child(filePath);

      UploadTask uploadTask;
      final metadata = SettableMetadata(contentType: 'image/jpeg'); // Hoặc tùy chỉnh

      if (kIsWeb && imageData is Uint8List) {
        uploadTask = ref.putData(imageData, metadata);
      } else if (!kIsWeb && imageData is File) {
        uploadTask = ref.putFile(imageData, metadata);
      } else {
        throw Exception("Loại dữ liệu ảnh không được hỗ trợ hoặc không khớp với nền tảng.");
      }

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("StorageService: Avatar uploaded successfully. URL: $downloadUrl");
      return downloadUrl;
    } on FirebaseException catch (e) {
      print("StorageService Error (uploadUserAvatar): FirebaseException - Code: ${e.code}, Message: ${e.message}");
      throw Exception('Lỗi tải lên ảnh đại diện: ${e.message ?? "Không rõ nguyên nhân."}');
    } catch (e) {
      print("StorageService Error (uploadUserAvatar): General Error - $e");
      throw Exception('Đã xảy ra lỗi không mong muốn khi tải ảnh lên.');
    }
  }

  // (Optional) Delete old avatar if needed
  Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty) {
      print("StorageService: No image URL provided to delete.");
      return;
    }
    try {
      Reference photoRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await photoRef.delete();
      print("StorageService: Image deleted successfully from URL: $imageUrl");
    } on FirebaseException catch (e) {
      // Xử lý lỗi cụ thể của Firebase (ví dụ: object-not-found nếu ảnh đã bị xóa)
      if (e.code == 'object-not-found') {
        print("StorageService: Image not found at URL (possibly already deleted): $imageUrl");
      } else {
        print("StorageService Error (deleteImage): FirebaseException - Code: ${e.code}, Message: ${e.message} for URL: $imageUrl");
        // Bạn có thể không muốn ném lỗi ở đây nếu việc xóa ảnh không tồn tại là chấp nhận được
        // throw Exception('Lỗi xóa ảnh: ${e.message}');
      }
    } catch (e) {
      print("StorageService Error (deleteImage): General Error - $e for URL: $imageUrl");
      // throw Exception('Đã xảy ra lỗi không mong muốn khi xóa ảnh.');
    }
  }
}