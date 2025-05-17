import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Đảm bảo đường dẫn tới model của bạn là chính xác
import '../../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Hằng số cho số lượng sản phẩm mỗi trang
  static const int productsPerPage = 15; // Bạn có thể điều chỉnh số này

  late final CollectionReference<ProductModel> _productsCollection;

  ProductService() {
    _productsCollection =
        FirebaseFirestore.instance.collection('products').withConverter<ProductModel>(
          fromFirestore: (snapshot, options) => ProductModel.fromFirestore(snapshot, options),
          toFirestore: (product, options) => product.toFirestore(),
        );
  }

  // --- LẤY DỮ LIỆU SẢN PHẨM (HỖ TRỢ PHÂN TRANG) ---
  // Trả về QuerySnapshot để màn hình có thể lấy cả dữ liệu và document cuối cùng
  Future<QuerySnapshot<ProductModel>> getProductPage({DocumentSnapshot? lastVisibleDocument}) async {
    try {
      Query<ProductModel> query = _productsCollection
          .orderBy('date', descending: true); // Phải có orderBy để dùng startAfter

      if (lastVisibleDocument != null) {
        query = query.startAfterDocument(lastVisibleDocument);
      }

      return await query.limit(productsPerPage).get();
    } catch (e) {
      print("ProductService Error (getProductPage): $e");
      throw Exception('Lỗi tải trang sản phẩm: ${e.toString()}');
    }
  }


  // --- LẤY MỘT SẢN PHẨM THEO ID ---
  Future<ProductModel?> getProductById(String productId) async {
    try {
      DocumentSnapshot<ProductModel> doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("ProductService Error (getProductById): $e");
      throw Exception('Lỗi lấy chi tiết sản phẩm: ${e.toString()}');
    }
  }

  // --- THÊM SẢN PHẨM MỚI ---
  Future<String> addProduct(ProductModel product, {
    File? thumbnailFileMobile,
    Uint8List? thumbnailBytesWeb,
    String? thumbnailFileName,
  }) async {
    try {
      String finalThumbnailUrl = product.thumbnail;

      if ((kIsWeb && thumbnailBytesWeb != null && thumbnailFileName != null) || (!kIsWeb && thumbnailFileMobile != null)) {
        dynamic imageData = kIsWeb ? thumbnailBytesWeb! : thumbnailFileMobile!;
        String uploadFileName = thumbnailFileName ?? (thumbnailFileMobile != null ? thumbnailFileMobile.path.split('/').last : 'thumbnail_default.jpg');
        finalThumbnailUrl = await _uploadImage(
          imageData: imageData,
          fileName: uploadFileName,
          folderPath: '/product_images/thumbnails',
        );
      }

      ProductModel productToSave = product.copyWith(
        thumbnail: finalThumbnailUrl,
        // date sẽ được toFirestore xử lý (FieldValue.serverTimestamp())
      );

      DocumentReference<ProductModel> docRef = await _productsCollection.add(productToSave);
      print("ProductService: Product added with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("ProductService Error (addProduct): $e");
      throw Exception('Lỗi thêm sản phẩm: ${e.toString()}');
    }
  }

  // --- CẬP NHẬT SẢN PHẨM ---
  Future<void> updateProduct(ProductModel product, {
    File? newThumbnailFileMobile,
    Uint8List? newThumbnailBytesWeb,
    String? newThumbnailFileName,
  }) async {
    try {
      String finalThumbnailUrl = product.thumbnail;

      if ((kIsWeb && newThumbnailBytesWeb != null && newThumbnailFileName != null) || (!kIsWeb && newThumbnailFileMobile != null)) {
        dynamic imageData = kIsWeb ? newThumbnailBytesWeb! : newThumbnailFileMobile!;
        String uploadFileName = newThumbnailFileName ?? (newThumbnailFileMobile != null ? newThumbnailFileMobile.path.split('/').last : 'thumbnail_default.jpg');

        if (product.thumbnail.isNotEmpty && product.thumbnail.startsWith('https://firebasestorage.googleapis.com')) {
          await _deleteImageFromUrl(product.thumbnail);
        }
        finalThumbnailUrl = await _uploadImage(
            imageData: imageData, fileName: uploadFileName, folderPath: 'products/thumbnails');
      }

      ProductModel productToUpdate = product.copyWith(
        thumbnail: finalThumbnailUrl,
        // date sẽ được toFirestore xử lý (FieldValue.serverTimestamp()) nếu bạn muốn cập nhật thời gian sửa đổi
      );

      await _productsCollection.doc(product.id).set(productToUpdate, SetOptions(merge: true));
      print("ProductService: Product updated with ID: ${product.id}");
    } catch (e) {
      print("ProductService Error (updateProduct): $e");
      throw Exception('Lỗi cập nhật sản phẩm: ${e.toString()}');
    }
  }

  // --- XÓA SẢN PHẨM ---
  Future<void> deleteProduct(String productId, String? currentThumbnailUrl) async {
    try {
      if (currentThumbnailUrl != null && currentThumbnailUrl.isNotEmpty && currentThumbnailUrl.startsWith('https://firebasestorage.googleapis.com')) {
        await _deleteImageFromUrl(currentThumbnailUrl);
      }
      await _productsCollection.doc(productId).delete();
      print("ProductService: Product deleted with ID: $productId");
    } catch (e) {
      print("ProductService Error (deleteProduct): $e");
      throw Exception('Lỗi xóa sản phẩm: ${e.toString()}');
    }
  }

  // --- HÀM HELPER CHO UPLOAD VÀ DELETE ẢNH ---
  Future<String> _uploadImage({
    required dynamic imageData,
    required String fileName,
    required String folderPath,
  }) async {
    try {
      String safeFileName = fileName.replaceAll(RegExp(r'[^\w\.]'), '_');
      String filePath = '$folderPath/${DateTime.now().millisecondsSinceEpoch}_$safeFileName';
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
      print("ProductService Error (_uploadImage): $e");
      throw Exception('Lỗi tải ảnh lên Storage: ${e.toString()}');
    }
  }

  Future<void> _deleteImageFromUrl(String imageUrl) async {
    if (imageUrl.isEmpty || !imageUrl.startsWith('https://firebasestorage.googleapis.com')) {
      return;
    }
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print("ProductService: Image deleted from Storage: $imageUrl");
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        print("ProductService: Image not found for deletion (already deleted?): $imageUrl");
      } else {
        print("ProductService Error (_deleteImageFromUrl): $e");
      }
    }
  }

  String _getMimeType(String fileName) {
    final lowerCaseFileName = fileName.toLowerCase();
    if (lowerCaseFileName.endsWith('.png')) return 'image/png';
    if (lowerCaseFileName.endsWith('.gif')) return 'image/gif';
    if (lowerCaseFileName.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}