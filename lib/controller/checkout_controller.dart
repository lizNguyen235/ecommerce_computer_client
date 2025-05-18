import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/controller/address_controller.dart';
import 'package:ecommerce_computer_client/controller/cart_controller.dart';
import 'package:ecommerce_computer_client/controller/product_controller.dart';
import 'package:ecommerce_computer_client/core/service/AuthService.dart';
import 'package:ecommerce_computer_client/models/address_model.dart';
import 'package:ecommerce_computer_client/models/order_model.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/success/order_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CheckoutController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CartController cartController = Get.find<CartController>();
  final ProductController productController = Get.find<ProductController>();
  final AddressController addressController = Get.find<AddressController>();

  // Shipping address information
  final RxString recipientName = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString shippingAddress = ''.obs;
  final RxInt chooseAddress = 0.obs;

  // Payment method
  final RxString paymentMethod = 'COD'.obs;
  final RxString paymentImage = 'assets/images/cod.png'.obs;

  // Totals and fees
  final RxDouble subtotal = 0.0.obs;
  final RxDouble shippingFee = 0.0.obs;
  final RxDouble tax = 0.0.obs;
  final RxDouble discountAmount = 0.0.obs;
  final RxDouble pointAmount = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;

  // Loyalty points
  final RxDouble loyaltyPoints = 0.0.obs;
  final RxDouble pointsToRedeem = 0.0.obs;

  // Coupon
  final RxList<Map<String, dynamic>> availableCoupons = <Map<String, dynamic>>[].obs;
  final RxString selectedCouponCode = ''.obs;
  final RxString couponError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    calculateTotal();
    loadCoupons();
  }

  Future<void> loadUserData() async {
    final String? userId = AuthService().getCurrentUser()?.uid;
    if (userId == null) return;

    await addressController.loadAddresses(userId);

    if (addressController.shippingAddresses.isNotEmpty) {
      chooseAddress.value = addressController.chooseAddress.value;
      final address = addressController.shippingAddresses[chooseAddress.value];
      recipientName.value = address.name;
      phoneNumber.value = address.phone;
      shippingAddress.value = address.address;
    } else {
      recipientName.value = '';
      phoneNumber.value = '';
      shippingAddress.value = '';
      Get.snackbar('Error', 'Please add a shipping address');
    }

    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      loyaltyPoints.value = (userDoc.data()!['loyaltyPoints'] ?? 0.0).toDouble();
    }
  }

  Future<void> loadCoupons() async {
    final String? userId = AuthService().getCurrentUser()?.uid;
    final snapshot = await _firestore.collection('coupons').get();
    availableCoupons.clear();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final usedOrders = List<String>.from(data['usedOrders'] ?? []);
      final usedCount = (data['usedCount'] ?? 0) as int;
      final maxUses = (data['maxUses'] ?? 10) as int;

      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('couponCode', isEqualTo: data['code'])
          .get();
      if (usedCount < maxUses && ordersSnapshot.docs.isEmpty) {
        availableCoupons.add({
          'code': data['code'],
          'discountAmount': data['discountAmount'].toDouble(),
          'maxUses': maxUses,
          'usedCount': usedCount,
          'usedOrders': usedOrders,
        });
      }
    }
  }

  void calculateTotal() {
    subtotal.value = cartController.cartItems.entries.fold(0.0, (sum, entry) {
      final product = entry.key;
      final int quantity = entry.value;
      return sum + (productController.calculateSalePrice(product.price, product.salePrice) * quantity);
    });

    tax.value = subtotal.value * 0.05;
    shippingFee.value = subtotal.value > 500 ? 0.0 : 5.0;
    totalAmount.value = subtotal.value + tax.value + shippingFee.value - discountAmount.value - pointAmount.value;
  }

  void applyCoupon(String code) {
    final coupon = availableCoupons.firstWhereOrNull((c) => c['code'] == code);
    if (coupon != null && coupon['discountAmount'] <= subtotal.value) {
      discountAmount.value = coupon['discountAmount'];
      selectedCouponCode.value = code;
      couponError.value = '';
      calculateTotal();
    } else {
      couponError.value = 'Invalid coupon code or exceeds order value';
      discountAmount.value = 0.0;
      selectedCouponCode.value = '';
      calculateTotal();
    }
  }

  void removeCoupon() {
    discountAmount.value = 0.0;
    selectedCouponCode.value = '';
    couponError.value = '';
    calculateTotal();
  }

  void applyLoyaltyPoints(double points) {
    if (points <= loyaltyPoints.value) {
      pointAmount.value = points;
      pointsToRedeem.value = points;
      calculateTotal();
    } else {
      Get.snackbar('Error', 'Insufficient loyalty points!');
    }
  }

  void showPaymentMethodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(Sizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Image.asset('assets/images/cod.png', width: 30, height: 30),
              title: const Text('COD'),
              onTap: () {
                paymentMethod.value = 'COD';
                paymentImage.value = 'assets/images/cod.png';
                Get.back();
              },
            ),
            ListTile(
              leading: Image.asset('assets/images/bank.png', width: 30, height: 30),
              title: const Text('Bank'),
              onTap: () {
                paymentMethod.value = 'Bank';
                paymentImage.value = 'assets/images/bank.png';
                Get.back();
              },
            ),
            ListTile(
              leading: Image.asset('assets/images/wallet.png', width: 30, height: 30),
              title: const Text('Wallet'),
              onTap: () {
                paymentMethod.value = 'Wallet';
                paymentImage.value = 'assets/images/wallet.png';
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> placeOrder() async {
    try {
      final String? userId = AuthService().getCurrentUser()?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'Please log in to place an order');
        return;
      }
      if (shippingAddress.value.isEmpty) {
        Get.snackbar('Error', 'Please select a shipping address');
        return;
      }

      final order = OrderModel(
        userId: userId,
        shippingAddress: Address(
          name: recipientName.value,
          address: shippingAddress.value,
          phone: phoneNumber.value,
        ),
        paymentMethod: paymentMethod.value,
        shippingFee: shippingFee.value,
        tax: tax.value,
        discountAmount: discountAmount.value,
        pointAmount: pointAmount.value,
        totalAmount: totalAmount.value,
        items: cartController.cartItems.entries.map((e) => {
          'productId': e.key.id,
          'quantity': e.value,
          'price': productController.calculateSalePrice(e.key.price, e.key.salePrice),
          'name': e.key.title, // Map product name from ProductModel
        }).toList(),
        createdAt: DateTime.now(),
        status: 'PENDING',
        statusHistory: [
          {'status': 'PENDING', 'timestamp': DateTime.now()}
        ],
      );

      final orderRef = await _firestore.collection('orders').add({
        ...order.toJson(),
        'couponCode': selectedCouponCode.value,
      });

      if (selectedCouponCode.value.isNotEmpty) {
        await _firestore.collection('coupons').doc(selectedCouponCode.value).update({
          'usedCount': FieldValue.increment(1),
          'usedOrders': FieldValue.arrayUnion([orderRef.id]),
        });
      }

      final earnedPoints = totalAmount.value * 0.10;
      final newPoints = loyaltyPoints.value - pointsToRedeem.value + earnedPoints;
      await _firestore.collection('users').doc(userId).update({
        'loyaltyPoints': newPoints,
      });

      cartController.clearCart();

      await sendOrderConfirmationEmail(orderRef.id, order);

      Get.off(() => OrderSuccessScreen(orderId: orderRef.id, order: order));
    } catch (e) {
      Get.snackbar('Error', 'Failed to place order: $e');
      print('Order placement error: $e');
    }
  }

  Future<void> sendOrderConfirmationEmail(String orderId, OrderModel order) async {
    const functionUrl = 'YOUR_CLOUD_FUNCTION_URL'; // Replace with your Cloud Function URL
    try {
      await http.post(
        Uri.parse(functionUrl),
        body: {
          'orderId': orderId,
          'email': AuthService().getCurrentUser()?.email,
          'order': order.toJson().toString(),
        },
      );
    } catch (e) {
      print('Failed to send email: $e');
    }
  }
}