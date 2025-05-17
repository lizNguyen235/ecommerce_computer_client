import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String id;
  int stock;
  double price;
  String title;
  DateTime? date;
  double salePrice;
  String thumbnail;
  bool? isFeatured;
  String brand;
  String? description;
  String category;

  ProductModel({
    required this.id,
    required this.stock,
    required this.price,
    required this.title,
    this.date,
    this.salePrice = 0.0,
    required this.thumbnail,
    this.isFeatured,
    required this.brand,
    this.description,
    required this.category,
  });

  /// Empty Helper Function
  static ProductModel empty() {
    return ProductModel(
      id: '',
      stock: 0,
      price: 0.0,
      title: '',
      thumbnail: '',
      brand: '',
      category: '',
    );
  }

  /// Convert model to Json structure so that you can store data in Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stock': stock,
      'price': price,
      'title': title,
      'salePrice': salePrice,
      'thumbnail': thumbnail,
      'isFeatured': isFeatured,
      'brand': brand,
      'description': description,
      'category': category,
    };
  }

  /// Map Json oriented document snapshot from Firebase to model
  factory ProductModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      ) {
    if (snapshot.data() == null) {
      return ProductModel.empty();
    } else {
      final data = snapshot.data()!;
      return ProductModel(
        id: snapshot.id,
        stock: data['stock']?.toInt() ?? 0,
        price: double.parse((data['price'] ?? 0.0).toString()),
        title: data['title'] ?? '',
        date: (data['date'] as Timestamp?)?.toDate(),
        salePrice: double.parse((data['salePrice'] ?? 0.0).toString()),
        thumbnail: data['thumbnail'] ?? '',
        isFeatured: data['isFeatured'] ?? false,
        brand: data['brand'] ?? '',
        description: data['description'] ?? '',
        category: data['category'] ?? '',
      );
    }
  }
}