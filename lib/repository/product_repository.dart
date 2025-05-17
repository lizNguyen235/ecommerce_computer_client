import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find<ProductRepository>();

  final _db = FirebaseFirestore.instance.collection('products');

  Future<List<ProductModel>> getFeaturedProducts({int limit = 8}) async {
    final snap = await _db.where('isFeatured', isEqualTo: true).limit(limit).get();
    return snap.docs.map((d) => ProductModel.fromSnapshot(d)).toList();
  }

  Future<List<ProductModel>> getNewProducts({int limit = 8}) async {
    final snap = await _db.orderBy('date', descending: true).limit(limit).get();
    return snap.docs.map((d) => ProductModel.fromSnapshot(d)).toList();
  }

  Future<List<ProductModel>> getAllProductsSimple({int limit = 8}) async {
    final snap = await _db.orderBy('title').limit(limit).get();
    return snap.docs.map((d) => ProductModel.fromSnapshot(d)).toList();
  }

  Future<List<ProductModel>> getAllProducts({
    int limit = 8,
    DocumentSnapshot? startAfter,
    String? search,
    String? brand,
    String? category,
    RangeValues? priceRange,
    String sortBy = 'titleAsc',
  }) async {
    Query<Map<String, dynamic>> q = _db;

    if (search != null && search.isNotEmpty) {
      q = q
          .where('title', isGreaterThanOrEqualTo: search)
          .where('title', isLessThanOrEqualTo: '$search\uf8ff');
    }
    if (brand != null && brand != 'All') {
      q = q.where('brand', isEqualTo: brand);
    }
    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }
    if (priceRange != null) {
      q = q
          .where('price', isGreaterThanOrEqualTo: priceRange.start)
          .where('price', isLessThanOrEqualTo: priceRange.end);
    }

    switch (sortBy) {
      case 'nameDesc':
        q = q.orderBy('title', descending: true);
        break;
      case 'priceAsc':
        q = q.orderBy('price');
        break;
      case 'priceDesc':
        q = q.orderBy('price', descending: true);
        break;
      default:
        q = q.orderBy('title');
    }

    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }
    q = q.limit(limit);

    final snap = await q.get();
    return snap.docs.map((d) => ProductModel.fromSnapshot(d)).toList();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryAllProducts({
    int limit = 8,
    DocumentSnapshot? startAfter,
    String? search,
    String? brand,
    String? category,
    RangeValues? priceRange,
    String sortBy = 'titleAsc',
  }) async {
    Query<Map<String, dynamic>> q = _db;

    if (search != null && search.isNotEmpty) {
      q = q
          .where('title', isGreaterThanOrEqualTo: search)
          .where('title', isLessThanOrEqualTo: '$search\uf8ff');
    }
    if (brand != null && brand != 'All') {
      q = q.where('brand', isEqualTo: brand);
    }
    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }
    if (priceRange != null) {
      q = q
          .where('price', isGreaterThanOrEqualTo: priceRange.start)
          .where('price', isLessThanOrEqualTo: priceRange.end);
    }

    switch (sortBy) {
      case 'nameDesc':
        q = q.orderBy('title', descending: true);
        break;
      case 'priceAsc':
        q = q.orderBy('price');
        break;
      case 'priceDesc':
        q = q.orderBy('price', descending: true);
        break;
      default:
        q = q.orderBy('title');
    }

    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }

    return q.limit(limit).get();
  }
}