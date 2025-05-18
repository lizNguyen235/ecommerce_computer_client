import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../repository/product_repository.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find<ProductController>();

  final _repo = Get.put(ProductRepository());

  // Loading states
  final isLoadingFeatured = false.obs;
  final isLoadingNew = false.obs;
  final isLoadingHome = false.obs;
  final isLoadingAll = false.obs;
  final isLoadingProduct = false.obs;

  // Data lists
  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  RxList<ProductModel> newProducts = <ProductModel>[].obs;
  RxList<ProductModel> homeProducts = <ProductModel>[].obs;
  RxList<ProductModel> allProducts = <ProductModel>[].obs;
  RxList<ProductModel> productDetails = <ProductModel>[].obs;

  // Pagination state for "allProducts"
  DocumentSnapshot? startAfterAll;
  final hasMoreAll = true.obs;

  // Filter / Sort / Search state
  RxString searchQuery = ''.obs;
  RxString selectedBrand = 'All'.obs;
  RxString selectedCategory = 'All'.obs;
  Rx<RangeValues> priceRange = const RangeValues(0, 1000).obs;
  RxString sortBy = 'titleAsc'.obs;

  // Dynamic bounds
  double minPrice = 0;
  double maxPrice = 1000;

  // Danh sách có sẵn để filter
  final List<String> brands = [
    'Asus', 'Acer', 'Dell', 'HP', 'Lenovo',
    'MSI', 'Razer', 'Apple', 'Samsung', 'LG', 'Macbook'
  ];
  final List<String> categories = [
    'Laptop', 'Desktop', 'Monitor', 'Storage', 'Memory',
    'Graphics Card', 'Peripherals', 'Accessories', 'Networking'
  ];

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    fetchFeaturedProducts();
    fetchNewProducts();
    fetchHomeProducts();
    fetchAllProducts(reset: true);
  }

  /// 1) Featured products
  Future<void> fetchFeaturedProducts() async {
    try {
      isLoadingFeatured.value = true;
      final list = await _repo.getFeaturedProducts(limit: 6);
      featuredProducts.assignAll(list);
    } catch (e, st) {
      debugPrint('Error featured: $e');
      debugPrintStack(stackTrace: st);
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoadingFeatured.value = false;
    }
  }

  /// 2) Newest products
  Future<void> fetchNewProducts() async {
    try {
      isLoadingNew.value = true;
      final list = await _repo.getNewProducts(limit: 6);
      newProducts.assignAll(list);
    } catch (e, st) {
      debugPrint('Error new: $e');
      debugPrintStack(stackTrace: st);
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoadingNew.value = false;
    }
  }

  /// 3) Home products (simple)
  Future<void> fetchHomeProducts() async {
    try {
      isLoadingHome.value = true;
      final list = await _repo.getAllProductsSimple(limit: 6);
      homeProducts.assignAll(list);
    } catch (e, st) {
      debugPrint('Error home: $e');
      debugPrintStack(stackTrace: st);
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoadingHome.value = false;
    }
  }

  /// 4) All products (pagination + filter + sort)
  Future<void> fetchAllProducts({bool reset = false}) async {
    if (reset) {
      startAfterAll = null;
      hasMoreAll.value = true;
      allProducts.clear();
      debugPrint('Resetting allProducts with search: $searchQuery, brand: $selectedBrand, category: $selectedCategory, priceRange: $priceRange, sortBy: $sortBy');
    }
    if (!hasMoreAll.value) {
      debugPrint('No more products to load');
      return;
    }

    try {
      isLoadingAll.value = true;
      final snapshot = await _repo.queryAllProducts(
        limit: 6,
        startAfter: startAfterAll,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        brand: selectedBrand.value != 'All' ? selectedBrand.value : null,
        category: selectedCategory.value != 'All' ? selectedCategory.value : null,
        priceRange: priceRange.value.start != 0 || priceRange.value.end != 1000 ? priceRange.value : null,
        sortBy: sortBy.value,
      );

      if (snapshot.docs.length < 6) {
        hasMoreAll.value = false;
        debugPrint('No more data, setting hasMoreAll to false');
      }

      if (snapshot.docs.isNotEmpty) {
        startAfterAll = snapshot.docs.last;
        debugPrint('Updated startAfterAll: $startAfterAll');
        final products = snapshot.docs
            .map((doc) => ProductModel.fromSnapshot(doc))
            .toList();
        allProducts.addAll(products);
        debugPrint('Added ${products.length} products, total: ${allProducts.length}');
      } else {
        hasMoreAll.value = false;
        debugPrint('No documents returned, setting hasMoreAll to false');
      }
    } catch (e, st) {
      debugPrint('Error all: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      isLoadingAll.value = false;
    }
  }

  /// 5) Load product base on ID
  Future<void> fetchProductById(String id) async {
    try {
      isLoadingProduct.value = true;
      final product = await _repo.getProductById(id);
      if (product != null) {
        productDetails.assignAll([product]);
      } else {
        debugPrint('No product found with ID: $id');
      }
    } catch (e, st) {
      debugPrint('Error product: $e');
      debugPrintStack(stackTrace: st);
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoadingProduct.value = false;
    }
  }

  // Filter / Sort / Search callbacks
  void onSearchChanged(String q) {
    searchQuery.value = q;
    fetchAllProducts(reset: true);
  }

  void onBrandChanged(String b) {
    selectedBrand.value = b;
    fetchAllProducts(reset: true);
  }

  void onCategoryChanged(String c) {
    selectedCategory.value = c;
    fetchAllProducts(reset: true);
  }

  void onPriceRangeChanging(RangeValues r) {
    priceRange.value = r;
  }

  void onSortByChanged(String s) {
    sortBy.value = s;
    fetchAllProducts(reset: true);
  }

  void applyFilterSort() => fetchAllProducts(reset: true);

  void resetFilterSort() {
    searchQuery.value = '';
    selectedBrand.value = 'All';
    selectedCategory.value = 'All';
    priceRange.value = RangeValues(minPrice, maxPrice);
    sortBy.value = 'titleAsc';
    fetchAllProducts(reset: true);
  }

  // Calculate sale price
  double calculateSalePrice(double price, double discount) {
    // Đảm bảo discount nằm trong khoảng [0, 1]
    discount = discount.clamp(0.0, 1.0);
    if (discount > 0) {
      return price - (price * discount);
    }
    return price;
  }

  String checkProductStockStatus(int stock) {
    if (stock > 0) return 'In Stock';
    if (stock == 0) return 'Out of Stock';
    return 'Pre-Order';
  }
}