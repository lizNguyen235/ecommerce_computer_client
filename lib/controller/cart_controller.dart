import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/consts/colors.dart';
import 'package:ecommerce_computer_client/core/service/AuthService.dart';
import 'package:ecommerce_computer_client/models/product_model.dart';
import 'package:ecommerce_computer_client/repository/product_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final RxMap<ProductModel, int> _cartItems = <ProductModel, int>{}.obs;
  final RxInt cartCount = 0.obs; // Thêm cartCount để đếm số lượng sản phẩm
  final AuthService _authService = AuthService();
  final ProductRepository _productRepo = ProductRepository.instance;

  Map<ProductModel, int> get cartItems => _cartItems;

  @override
  void onInit() {
    super.onInit();
    _loadCartFromFirestore();
    _updateCartCount(); // Cập nhật số lượng ban đầu
  }

  void addToCart(ProductModel product) {
    if (_cartItems.containsKey(product)) {
      _cartItems[product] = (_cartItems[product] ?? 0) + 1;
    } else {
      _cartItems[product] = 1;
    }
    _updateCartCount();
    saveCartToFirestore();
  }

  void removeFromCart(ProductModel product) {
    if (_cartItems.containsKey(product)) {
      if (_cartItems[product]! > 1) {
        _cartItems[product] = _cartItems[product]! - 1;
      } else {
        _cartItems.remove(product);
      }
    }
    _updateCartCount();
    saveCartToFirestore();
  }

  void updateQuantity(ProductModel product, int newQuantity) {
    if (newQuantity <= 0) {
      _cartItems.remove(product);
    } else {
      _cartItems[product] = newQuantity;
    }
    _updateCartCount();
    saveCartToFirestore();
  }

  void clearCart() {
    _cartItems.clear();
    _updateCartCount();
    saveCartToFirestore();
  }

  void _updateCartCount() {
    cartCount.value = _cartItems.length; // Cập nhật số lượng sản phẩm
  }

  Future<void> _loadCartFromFirestore() async {
    try {
      User? user = _authService.getCurrentUser();
      if (user != null) {
        String uid = user.uid;
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('carts')
            .doc(uid)
            .get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _cartItems.clear();
          // Kiểm tra xem data có chứa trường 'items' không
          if (data.containsKey('items')) {
            Map<String, dynamic> items = data['items'] as Map<String, dynamic>;
            for (var entry in items.entries) {
              String productId = entry.key;
              int quantity;
              // Xử lý cả hai cấu trúc dữ liệu
              if (entry.value is int) {
                quantity = entry.value as int; // Cấu trúc đúng: value là int
              } else if (entry.value is Map) {
                // Cấu trúc cũ: value là Map, lấy trường 'quantity'
                quantity = (entry.value as Map)['quantity'] as int? ?? 0;
              } else {
                quantity = 0; // Dữ liệu không hợp lệ, bỏ qua
              }
              if (quantity > 0) {
                ProductModel? product = await _productRepo.getProductById(productId);
                if (product != null) {
                  _cartItems[product] = quantity;
                }
              }
            }
          }
          _updateCartCount();
        }
      }
    } catch (e) {
      print("Error loading cart from Firestore: $e");
      Get.snackbar(
        'Error',
        'Failed to load cart. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade500,
        colorText: whiteColor,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> saveCartToFirestore() async {
    User? user = _authService.getCurrentUser();
    if (user != null) {
      String uid = user.uid;
      Map<String, int> cartData = {};
      _cartItems.forEach((product, quantity) {
        cartData[product.id] = quantity;
      });
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(uid)
          .set({'items': cartData});
    }
  }

  Future<void> mergeAnonymousCart(String newUid) async {
    User? user = _authService.getCurrentUser();
    if (user != null && user.isAnonymous) {
      String oldUid = user.uid;
      DocumentSnapshot anonCartDoc = await FirebaseFirestore.instance
          .collection('carts')
          .doc(oldUid)
          .get();
      if (anonCartDoc.exists) {
        Map<String, dynamic> anonCart = anonCartDoc.data() as Map<String, dynamic>;
        Map<String, int> mergedItems = {...anonCart['items'] as Map<String, int>};
        _cartItems.forEach((product, quantity) {
          mergedItems[product.id] = (mergedItems[product.id] ?? 0) + quantity;
        });
        await FirebaseFirestore.instance
            .collection('carts')
            .doc(newUid)
            .set({'items': mergedItems});
        await FirebaseFirestore.instance.collection('carts').doc(oldUid).delete();
        _loadCartFromFirestore(); // Tải lại giỏ hàng với newUid
      }
    }
  }
}