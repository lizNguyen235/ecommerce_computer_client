class CouponModel {
  final String code;
  final double discountAmount;
  final int remainingUsage;
  final String type; // "order" hoặc "product"
  final List<String>? productIds; // Danh sách ID của các sản phẩm mà coupon áp dụng

  CouponModel({
    required this.code,
    required this.discountAmount,
    required this.remainingUsage,
    required this.type,
    this.productIds,
  });

  // Kiểm tra xem coupon có áp dụng được cho sản phẩm cụ thể không
  bool isApplicableToProduct(String productId) {
    if (type == 'order') return true; // Coupon cho đơn hàng áp dụng cho tất cả sản phẩm
    if (productIds == null || productIds!.isEmpty) return false;
    return productIds!.contains(productId); // Kiểm tra xem productId có trong danh sách không
  }

  // Mô phỏng lấy thông tin coupon từ database
  static CouponModel? getCouponByCode(String code) {
    final mockCoupons = {
      'SAVE10': CouponModel(
        code: 'SAVE10',
        discountAmount: 10.0,
        remainingUsage: 5,
        type: 'order',
      ),
      'SAVE20': CouponModel(
        code: 'SAVE20',
        discountAmount: 20.0,
        remainingUsage: 3,
        type: 'order',
      ),
      'PRODUCT10': CouponModel(
        code: 'PRODUCT10',
        discountAmount: 10.0,
        remainingUsage: 2,
        type: 'product',
        productIds: ['product123', 'product456'], // Áp dụng cho nhiều sản phẩm
      ),
    };
    return mockCoupons[code];
  }
}