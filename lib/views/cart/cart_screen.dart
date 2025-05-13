import 'package:flutter/material.dart';
import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CartItem {
  final String name;
  final String imagePath;
  int quantity;
  final double price;

  CartItem({
    required this.name,
    required this.imagePath,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;
}

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Dữ liệu giỏ hàng giả lập (chỉ máy tính và linh kiện)
  final List<CartItem> _items = [
    CartItem(
      name: 'MacBook Air 13" M1',
      imagePath: imgP3,
      quantity: 1,
      price: 999.0,
    ),
    CartItem(
      name: 'Monitor Dell 24 inch',
      imagePath: imgP2,
      quantity: 1,
      price: 300.0,
    ),
    CartItem(
      name: 'Keyboard ASUS ROG',
      imagePath: imgP1,
      quantity: 1,
      price: 150.0,
    ),
  ];

  double get _totalPrice => _items.fold(0.0, (sum, item) => sum + item.total);

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _changeQuantity(int index, int delta) {
    setState(() {
      final newQty = _items[index].quantity + delta;
      if (newQty > 0) _items[index].quantity = newQty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 113, 2),
        title: Text(
          'My Cart',
          style: TextStyle(fontFamily: bold, color: whiteColor),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Slidable(
                  key: ValueKey(item.name),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _removeItem(index),
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Hình ảnh sản phẩm từ assets
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              item.imagePath,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Cột chứa Tên, Giá, và Nút tăng giảm số lượng
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontFamily: semibold,
                                    fontSize: 16,
                                    color: darkFontGrey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '\$${item.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontFamily: bold,
                                    fontSize: 14,
                                    color: redColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 20,
                                      ),
                                      color: redColor,
                                      onPressed:
                                          () => _changeQuantity(index, -1),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: darkFontGrey,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        size: 20,
                                      ),
                                      color: Colors.green,
                                      onPressed:
                                          () => _changeQuantity(index, 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Nút xóa
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(
                                0.2,
                              ), // Màu nền nhạt hơn
                              padding: const EdgeInsets.all(12), // Padding tổng
                            ),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent, // Icon giữ màu đậm
                              size: 24,
                            ),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Thông tin đơn hàng
          Container(
            padding: const EdgeInsets.all(12),
            color: whiteColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontFamily: bold,
                    fontSize: 18,
                    color: darkFontGrey,
                  ),
                ),
                Text(
                  '\$${_totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: bold,
                    fontSize: 16,
                    color: redColor,
                  ),
                ),
              ],
            ),
          ),

          // Nút thanh toán
          Container(
            margin: const EdgeInsets.all(12),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Checkout (\$${_totalPrice.toStringAsFixed(2)})',
                style: TextStyle(
                  fontFamily: bold,
                  fontSize: 16,
                  color: whiteColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
