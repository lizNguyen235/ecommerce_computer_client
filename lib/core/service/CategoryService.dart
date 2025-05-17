import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Điều chỉnh đường dẫn đến model của bạn nếu cần
import '../../models/category_model.dart';


class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Để tải ảnh

  late final CollectionReference<CategoryModel> _categoriesCollection;

  CategoryService() {
    _categoriesCollection =
        FirebaseFirestore.instance.collection('categories').withConverter<CategoryModel>(
          fromFirestore: (snapshot, options) => CategoryModel.fromFirestore(snapshot, options),
          toFirestore: (category, options) => category.toFirestore(),
        );
  }

  // --- LẤY TẤT CẢ DANH MỤC ---
  Stream<List<CategoryModel>> getAllCategories() {
    return _categoriesCollection
        .orderBy('date',descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map((doc) => doc.data()).toList())
        .handleError((error, stackTrace) {
      print("CategoryService Error (getAllCategories - stream): $error \n$stackTrace");
      throw Exception('Không thể tải danh sách danh mục: ${error.toString()}');
    });
  }

  // --- LẤY MỘT DANH MỤC THEO ID ---
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      DocumentSnapshot<CategoryModel> doc = await _categoriesCollection.doc(categoryId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print("CategoryService Error (getCategoryById): $e");
      throw Exception('Lỗi lấy chi tiết danh mục: ${e.toString()}');
    }
  }

  // --- HÀM HELPER UPLOAD ẢNH (Tương tự ProductService) ---
  Future<String> _uploadCategoryImage({
    required dynamic imageData, // File hoặc Uint8List
    required String fileName,
    required String categoryNameForPath, // Dùng tên category để tạo đường dẫn dễ quản lý
  }) async {
    try {
      String safeFileName = fileName.replaceAll(RegExp(r'[^\w\.]'), '_');
      String safeCategoryName = categoryNameForPath.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
      String filePath = 'categories/images/$safeCategoryName/${DateTime.now().millisecondsSinceEpoch}_$safeFileName';
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask;
      final metadata = SettableMetadata(contentType: _getMimeType(safeFileName));

      if (kIsWeb && imageData is Uint8List) {
        uploadTask = ref.putData(imageData, metadata);
      } else if (!kIsWeb && imageData is File) {
        uploadTask = ref.putFile(imageData, metadata);
      } else {
        throw Exception("Dữ liệu ảnh không hợp lệ để tải lên.");
      }
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("CategoryService Error (_uploadCategoryImage): $e");
      throw Exception('Lỗi tải ảnh danh mục lên Storage: ${e.toString()}');
    }
  }

  String _getMimeType(String fileName) {
    final lowerCaseFileName = fileName.toLowerCase();
    if (lowerCaseFileName.endsWith('.png')) return 'image/png';
    if (lowerCaseFileName.endsWith('.gif')) return 'image/gif';
    if (lowerCaseFileName.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _deleteImageFromUrl(String imageUrl) async {
    if (imageUrl.isEmpty || !imageUrl.startsWith('https://firebasestorage.googleapis.com')) return;
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print("CategoryService: Image deleted from Storage: $imageUrl");
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        print("CategoryService: Image not found for deletion: $imageUrl");
      } else {
        print("CategoryService Error (_deleteImageFromUrl): $e");
      }
    }
  }

  // --- THÊM DANH MỤC MỚI ---
  Future<String> addCategory(CategoryModel category, {
    File? imageFileMobile,
    Uint8List? imageBytesWeb,
    String? imageFileName,
  }) async {
    try {
      String finalImageUrl = category.image; // Giữ ảnh mặc định/đã có nếu không upload mới

      if ((kIsWeb && imageBytesWeb != null && imageFileName != null) || (!kIsWeb && imageFileMobile != null)) {
        dynamic imageData = kIsWeb ? imageBytesWeb! : imageFileMobile!;
        String uploadFileName = imageFileName ?? (imageFileMobile != null ? imageFileMobile.path.split('/').last : 'category_default.jpg');

        finalImageUrl = await _uploadCategoryImage(
          imageData: imageData,
          fileName: uploadFileName,
          categoryNameForPath: category.name, // Dùng tên category cho đường dẫn
        );
      } else if (finalImageUrl.isEmpty) {
        // Nếu không có ảnh được cung cấp và category.image cũng rỗng, cần xử lý
        // Ví dụ: throw Exception hoặc dùng ảnh placeholder mặc định từ Storage (nếu có)
        throw Exception("Ảnh danh mục là bắt buộc khi thêm mới.");
      }

      CategoryModel categoryToSave = category.copyWith(image: finalImageUrl);

      DocumentReference<CategoryModel> docRef = await _categoriesCollection.add(categoryToSave);
      print("CategoryService: Category added with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("CategoryService Error (addCategory): $e");
      throw Exception('Lỗi thêm danh mục: ${e.toString()}');
    }
  }

  // --- CẬP NHẬT DANH MỤC ---
  Future<void> updateCategory(CategoryModel category, {
    File? newImageFileMobile,
    Uint8List? newImageBytesWeb,
    String? newImageFileName,
  }) async {
    try {
      String finalImageUrl = category.image; // Giữ ảnh hiện tại

      if ((kIsWeb && newImageBytesWeb != null && newImageFileName != null) || (!kIsWeb && newImageFileMobile != null)) {
        dynamic imageData = kIsWeb ? newImageBytesWeb! : newImageFileMobile!;
        String uploadFileName = newImageFileName ?? (newImageFileMobile != null ? newImageFileMobile.path.split('/').last : 'category_default.jpg');

        // Xóa ảnh cũ trên Storage nếu nó tồn tại và không phải placeholder
        if (category.image.isNotEmpty && category.image.startsWith('https://firebasestorage.googleapis.com')) {
          await _deleteImageFromUrl(category.image);
        }
        // Upload ảnh mới
        finalImageUrl = await _uploadCategoryImage(
            imageData: imageData,
            fileName: uploadFileName,
            categoryNameForPath: category.name);
      } else if (finalImageUrl.isEmpty) {
        throw Exception("Ảnh danh mục không thể để trống khi cập nhật.");
      }

      CategoryModel categoryToUpdate = category.copyWith(image: finalImageUrl);

      await _categoriesCollection.doc(category.id).set(categoryToUpdate, SetOptions(merge: true));
      print("CategoryService: Category updated with ID: ${category.id}");
    } catch (e) {
      print("CategoryService Error (updateCategory): $e");
      throw Exception('Lỗi cập nhật danh mục: ${e.toString()}');
    }
  }

  // --- XÓA DANH MỤC ---
  Future<void> deleteCategory(String categoryId, String? currentImageUrl) async {
    try {
      // TODO: Kiểm tra sản phẩm liên quan trước khi xóa
      if (currentImageUrl != null && currentImageUrl.isNotEmpty && currentImageUrl.startsWith('https://firebasestorage.googleapis.com')) {
        await _deleteImageFromUrl(currentImageUrl);
      }
      await _categoriesCollection.doc(categoryId).delete();
      print("CategoryService: Category deleted with ID: $categoryId");
    } catch (e) {
      print("CategoryService Error (deleteCategory): $e");
      throw Exception('Lỗi xóa danh mục: ${e.toString()}');
    }
  }
}