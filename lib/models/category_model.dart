import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id; // Document ID từ Firestore
  String name;
  bool isFeatured;

  CategoryModel({
    required this.id,
    required this.name,
    this.isFeatured = false, // Giá trị mặc định nếu không được cung cấp
  });

  /// Hàm static để tạo một đối tượng CategoryModel rỗng
  /// Hữu ích cho việc khởi tạo hoặc làm giá trị mặc định
  static CategoryModel empty() => CategoryModel(id: '', name: '', isFeatured: false);

  /// Chuyển đổi từ DocumentSnapshot (dữ liệu Firestore) sang CategoryModel object
  factory CategoryModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    // Kiểm tra xem snapshot có dữ liệu không
    if (snapshot.data() == null) {
      print("Warning: Snapshot data is null for category document ID: ${snapshot.id}. Returning empty CategoryModel.");
      return CategoryModel.empty(); // Trả về đối tượng rỗng nếu không có dữ liệu
    }

    final data = snapshot.data()!; // Đảm bảo data không null

    return CategoryModel(
      id: snapshot.id, // Lấy ID của document
      name: data['name'] as String? ?? '', // Lấy 'name', nếu null thì trả về chuỗi rỗng
      isFeatured: data['isFeatured'] as bool? ?? false, // Lấy 'isFeatured', nếu null thì mặc định là false
    );
  }

  /// Chuyển đổi từ CategoryModel object sang Map để lưu vào Firestore
  /// Lưu ý: 'id' không được bao gồm vì nó là ID của document, không phải là một trường bên trong document
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isFeatured': isFeatured,
    };
  }

  /// (Tùy chọn) Hàm copyWith để dễ dàng tạo bản sao và cập nhật một vài thuộc tính
  CategoryModel copyWith({
    String? id,
    String? name,
    bool? isFeatured,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  //==================================================================
  // HÀM MỚI: fromFirestore (cho withConverter)
  //==================================================================
  factory CategoryModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options, // Tham số này là bắt buộc cho signature của fromFirestore
      ) {
    if (snapshot.data() == null) {
      print("Warning: Snapshot data is null for category document ID: ${snapshot.id}. Returning empty CategoryModel.");
      return CategoryModel.empty();
    }
    final data = snapshot.data()!; // Đảm bảo data không null

    return CategoryModel(
      id: snapshot.id,
      name: data['name'] as String? ?? '',
      isFeatured: data['isFeatured'] as bool? ?? false,
    );
  }

  //==================================================================
  // HÀM MỚI: toFirestore (cho withConverter)
  //==================================================================
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isFeatured': isFeatured,
      // Không cần thêm 'id' ở đây vì nó là ID của document
    };
  }
}