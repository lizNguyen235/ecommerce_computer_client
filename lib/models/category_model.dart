import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  String name;
  String image;
  bool isFeatured;
  DateTime? date; // MỚI: Thời gian tạo hoặc cập nhật cuối cùng

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.isFeatured = false,
    this.date, // Thêm vào constructor
  });

  static CategoryModel empty() => CategoryModel(id: '', name: '', image: '', isFeatured: false, date: null);

  factory CategoryModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    if (snapshot.data() == null) {
      print("Warning: Snapshot data is null for category document ID: ${snapshot.id}. Returning empty CategoryModel.");
      return CategoryModel.empty();
    }
    final data = snapshot.data()!;
    return CategoryModel(
      id: snapshot.id,
      name: data['name'] as String? ?? '',
      image: data['image'] as String? ?? '',
      isFeatured: data['isFeatured'] as bool? ?? false,
      date: (data['date'] as Timestamp?)?.toDate(), // MỚI: Chuyển Timestamp sang DateTime
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'image': image,
      'isFeatured': isFeatured,
      // MỚI: Luôn sử dụng FieldValue.serverTimestamp() khi ghi
      // để đảm bảo thời gian được đặt bởi server, tránh lệch múi giờ client.
      // Điều này có nghĩa là mỗi khi bạn gọi set() hoặc update() với đối tượng này,
      // trường 'date' trên Firestore sẽ được cập nhật thành thời gian hiện tại của server.
      'date': FieldValue.serverTimestamp(),
    };
  }

  factory CategoryModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) =>
      CategoryModel.fromFirestore(snapshot, null);

  Map<String, dynamic> toJson() => toFirestore();

  CategoryModel copyWith({
    String? id,
    String? name,
    String? image,
    bool? isFeatured,
    DateTime? date, // MỚI
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      isFeatured: isFeatured ?? this.isFeatured,
      date: date ?? this.date, // MỚI
    );
  }
}