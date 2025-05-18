class OrderItemModel {
  final double price; // Giá tại thời điểm mua
  final String productId;
  final int quantity;
  // Bạn có thể thêm các trường khác như productName, imageUrl nếu muốn lưu trữ snapshot
  // hoặc bạn sẽ fetch thông tin này từ productId khi hiển thị

  OrderItemModel({
    required this.price,
    required this.productId,
    required this.quantity,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      price: (map['price'] ?? 0.0).toDouble(),
      productId: map['productId'] ?? '',
      quantity: map['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'productId': productId,
      'quantity': quantity,
    };
  }
}