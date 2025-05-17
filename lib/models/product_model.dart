import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String id;
  int stock;
  double price; // Giá gốc
  String title;
  DateTime? date;
  double salePrice; // Tỷ lệ giảm giá từ Firestore (0.0 đến 0.5) -> Admin sẽ nhập % (0-50)
  String thumbnail;
  bool? isFeatured;
  String brand; // Tên thương hiệu (hoặc brandId nếu bạn có collection Brands)
  String? description;
  String category; // Tên danh mục (hoặc categoryId nếu bạn có collection Categories)

  // Thuộc tính tính toán động, không lưu vào DB
  late double _effectivePrice;

  ProductModel({
    required this.id,
    required this.stock,
    required this.price,
    required this.title,
    this.date,
    double salePriceRatio = 0.0, // Nhận tỷ lệ giảm giá (0.0 - 0.5)
    required this.thumbnail,
    this.isFeatured,
    required this.brand,
    this.description,
    required this.category,
  }) : this.salePrice = (salePriceRatio < 0.0) ? 0.0 : (salePriceRatio > 0.5) ? 0.5 : salePriceRatio {
    _calculateEffectivePrice();
  }

  void _calculateEffectivePrice() {
    _effectivePrice = price * (1 - salePrice);
  }

  // Getter cho giá cuối cùng
  double get effectivePrice => _effectivePrice;

  // Getter cho phần trăm giảm giá để hiển thị (0-50)
  double get discountPercentageDisplay {
    return salePrice * 100;
  }

  // Setter cho phần trăm giảm giá (0-50) -> UI sẽ dùng cái này
  // Khi admin set cái này, nó sẽ tự cập nhật salePrice (tỷ lệ) và effectivePrice
  set discountPercentageInput(double percentage) {
    double ratio = percentage / 100.0;
    salePrice = (ratio < 0.0) ? 0.0 : (ratio > 0.5) ? 0.5 : ratio;
    _calculateEffectivePrice();
  }


  static ProductModel empty() {
    return ProductModel(id: '', stock: 0, price: 0.0, title: '', thumbnail: '', brand: '', category: '', salePriceRatio: 0.0);
  }

  Map<String, dynamic> toJson() {
    // Đảm bảo salePrice (tỷ lệ) là hợp lệ trước khi lưu
    double validSalePriceRatio = (salePrice < 0.0) ? 0.0 : (salePrice > 0.5) ? 0.5 : salePrice;
    return {
      'stock': stock,
      'price': price,
      'title': title,
      'date': date != null ? Timestamp.fromDate(date!) : FieldValue.serverTimestamp(),
      'salePrice': validSalePriceRatio, // Lưu TỶ LỆ giảm giá vào trường 'salePrice' của Firestore
      'thumbnail': thumbnail,
      'isFeatured': isFeatured ?? false,
      'brand': brand, // Nếu dùng collection riêng thì đây là brandId
      'description': description,
      'category': category, // Nếu dùng collection riêng thì đây là categoryId
      // KHÔNG LƯU effectivePrice vào DB
    };
  }

  factory ProductModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() == null) return ProductModel.empty();
    final data = snapshot.data()!;

    double salePriceRatioFromDB = 0.0;
    if (data['salePrice'] != null) {
      try {
        salePriceRatioFromDB = double.parse(data['salePrice'].toString());
      } catch (e) {
        print("Warning: Could not parse 'salePrice' for product ${snapshot.id}. Defaulting to 0.0. Error: $e");
      }
    }

    return ProductModel(
      id: snapshot.id,
      stock: data['stock'] is int ? data['stock'] : (data['stock']?.toInt() ?? 0),
      price: data['price'] is double ? data['price'] : double.tryParse(data['price']?.toString() ?? '0.0') ?? 0.0,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate(),
      salePriceRatio: salePriceRatioFromDB, // salePrice từ DB là tỷ lệ
      thumbnail: data['thumbnail'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      brand: data['brand'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
    );
  }

  ProductModel copyWith({
    String? id,
    int? stock,
    double? price,
    String? title,
    DateTime? date,
    double? salePriceRatio, // Nhận tỷ lệ
    String? thumbnail,
    bool? isFeatured,
    String? brand,
    String? description,
    String? category,
  }) {
    return ProductModel(
      id: id ?? this.id,
      stock: stock ?? this.stock,
      price: price ?? this.price,
      title: title ?? this.title,
      date: date ?? this.date,
      salePriceRatio: salePriceRatio ?? this.salePrice,
      thumbnail: thumbnail ?? this.thumbnail,
      isFeatured: isFeatured ?? this.isFeatured,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }

  // THAY THẾ fromSnapshot bằng fromFirestore
  factory ProductModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options, // Thêm tham số này cho withConverter
      ) {
    if (snapshot.data() == null) {
      print("Warning: Snapshot data is null for document ID: ${snapshot.id}. Returning empty ProductModel.");
      return ProductModel.empty();
    }
    final data = snapshot.data()!;
    double salePriceRatioFromDB = 0.0;
    if (data['salePrice'] != null) {
      try {
        salePriceRatioFromDB = double.parse(data['salePrice'].toString());
      } catch (e) {
        print("Warning: Could not parse 'salePrice' for product ${snapshot.id}. Defaulting to 0.0. Error: $e");
      }
    }
    // Constructor sẽ kẹp salePriceRatioFromDB
    return ProductModel(
      id: snapshot.id,
      stock: data['stock'] is int ? data['stock'] : (data['stock']?.toInt() ?? 0),
      price: data['price'] is double ? data['price'] : double.tryParse(data['price']?.toString() ?? '0.0') ?? 0.0,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate(),
      salePriceRatio: salePriceRatioFromDB,
      thumbnail: data['thumbnail'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      brand: data['brand'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
    );
  }
  // THAY THẾ toJson bằng toFirestore
  Map<String, dynamic> toFirestore() {
    double validSalePriceRatio = (salePrice < 0.0) ? 0.0 : (salePrice > 0.5) ? 0.5 : salePrice;
    return {
      'stock': stock,
      'price': price,
      'title': title,
      // Khi ghi, luôn dùng FieldValue.serverTimestamp() cho date nếu muốn server đặt thời gian
      // Hoặc nếu date được set từ client, thì dùng Timestamp.fromDate(date!)
      'date': FieldValue.serverTimestamp(), // Hoặc Timestamp.fromDate(date!) nếu date có giá trị
      'salePrice': validSalePriceRatio,
      'thumbnail': thumbnail,
      'isFeatured': isFeatured ?? false,
      'brand': brand,
      'description': description,
      'category': category,
    };
  }
}