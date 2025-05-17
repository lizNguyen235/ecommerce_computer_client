import 'package:cloud_firestore/cloud_firestore.dart';
// Điều chỉnh đường dẫn đến model của bạn nếu cần
import '../../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sử dụng withConverter để làm việc trực tiếp với CategoryModel
  late final CollectionReference<CategoryModel> _categoriesCollection;

  CategoryService() {
    _categoriesCollection =
        FirebaseFirestore.instance.collection('categories').withConverter<CategoryModel>(
          // Sửa lại fromFirestore và toFirestore cho CategoryModel
          fromFirestore: (snapshot, options) => CategoryModel.fromFirestore(snapshot, options),
          toFirestore: (category, options) => category.toFirestore(),
        );
  }

  // --- LẤY TẤT CẢ DANH MỤC ---
  Stream<List<CategoryModel>> getAllCategories() {
    return _categoriesCollection
        .orderBy('name') // Sắp xếp theo tên danh mục
        .snapshots() // Trả về Stream<QuerySnapshot<CategoryModel>>
        .map((querySnapshot) {
      // Mỗi doc.data() giờ đây là một đối tượng CategoryModel
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    })
        .handleError((error, stackTrace) {
      print("CategoryService Error (getAllCategories - stream): $error");
      print("Stack trace: $stackTrace");
      // Ném lại lỗi để UI có thể xử lý (ví dụ: StreamBuilder sẽ có snapshot.hasError)
      throw Exception('Không thể tải danh sách danh mục: ${error.toString()}');
    });
  }

  // --- LẤY MỘT DANH MỤC THEO ID ---
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      DocumentSnapshot<CategoryModel> doc =
      await _categoriesCollection.doc(categoryId).get();
      if (doc.exists) {
        return doc.data(); // doc.data() trả về CategoryModel?
      }
      return null;
    } catch (e) {
      print("CategoryService Error (getCategoryById): $e");
      throw Exception('Lỗi lấy chi tiết danh mục: ${e.toString()}');
    }
  }

  // --- THÊM DANH MỤC MỚI ---
  Future<String> addCategory(CategoryModel category) async {
    try {
      // Vì CategoryModel này không có trường 'id' trong toJson(),
      // chúng ta không cần truyền 'id' rỗng vào constructor khi tạo mới.
      // Firestore sẽ tự tạo ID.
      // Hàm toJson() của CategoryModel sẽ được gọi tự động bởi Firestore SDK.
      DocumentReference<CategoryModel> docRef =
      await _categoriesCollection.add(category);
      print("CategoryService: Category added with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("CategoryService Error (addCategory): $e");
      throw Exception('Lỗi thêm danh mục: ${e.toString()}');
    }
  }

  // --- CẬP NHẬT DANH MỤC ---
  Future<void> updateCategory(CategoryModel category) async {
    try {
      // toFirestore sẽ được gọi tự động.
      // Đảm bảo category.id có giá trị đúng của document cần cập nhật.
      await _categoriesCollection.doc(category.id).set(category, SetOptions(merge: true));
      // Hoặc nếu toFirestore của bạn chỉ chứa các trường cần update:
      // await _categoriesCollection.doc(category.id).update(category.toFirestore());
      print("CategoryService: Category updated with ID: ${category.id}");
    } catch (e) {
      print("CategoryService Error (updateCategory): $e");
      throw Exception('Lỗi cập nhật danh mục: ${e.toString()}');
    }
  }

  // --- XÓA DANH MỤC ---
  Future<void> deleteCategory(String categoryId) async {
    try {
      // TODO: Cân nhắc xử lý logic nếu có sản phẩm đang thuộc danh mục này
      // Ví dụ: không cho xóa, hoặc gán sản phẩm về "Uncategorized", v.v.
      // Hiện tại, chúng ta chỉ xóa document danh mục.

      await _categoriesCollection.doc(categoryId).delete();
      print("CategoryService: Category deleted with ID: $categoryId");
    } catch (e) {
      print("CategoryService Error (deleteCategory): $e");
      throw Exception('Lỗi xóa danh mục: ${e.toString()}');
    }
  }
}

