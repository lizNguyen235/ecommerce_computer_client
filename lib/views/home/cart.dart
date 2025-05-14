import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:client/services/sharedprefsservice.dart';
import 'dart:convert';

class CartItem {
  final int id;
  final String name;
  final String imageUrl;
  final String brand;
  final double price;
  final double discount;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.brand,
    required this.price,
    required this.discount,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};
    final images = product['productImages']?[r'$values'] ?? [];

    return CartItem(
      id: json['cartId'] ?? 0,
      name: product['name'] ?? 'N/A',
      imageUrl: images.isNotEmpty ? images[0]['image_Url'] ?? '' : '',
      brand: product['brand'] ?? 'Không rõ',
      price: (product['price'] ?? 0).toDouble(),
      discount: (product['discount_Percentage'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  double get discountedPrice => price * (1 - discount / 100);
}

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  late Future<List<CartItem>> _cartItemsFuture;

  @override
  void initState() {
    super.initState();
    _cartItemsFuture = fetchCartItems();
  }

  Future<List<CartItem>> fetchCartItems() async {
    final prefs = SharedPrefsService().prefs;
    final token = prefs.getString('jwt');
    final userId = prefs.getInt('userId');

    if (userId == null || token == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    final response = await http.get(
      Uri.parse('http://localhost:5256/api/cart/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);
      final List<dynamic> list = jsonMap['carts'] ?? [];
      return list.map((item) => CartItem.fromJson(item)).toList();
    } else {
      throw Exception('Lỗi khi tải giỏ hàng: ${response.body}');
    }
  }

  double calculateTotal(List<CartItem> items) {
    return items.fold(
      0,
      (sum, item) => sum + item.discountedPrice * item.quantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🛒 Giỏ hàng')),
      body: FutureBuilder<List<CartItem>>(
        future: _cartItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Giỏ hàng đang trống!'));
          }

          final items = snapshot.data!;
          final total = calculateTotal(items);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        leading: Image.network(
                          item.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Thương hiệu: ${item.brand}'),
                            Text(
                              'Giá sau giảm: ${item.discountedPrice.toStringAsFixed(0)}đ',
                              style: const TextStyle(color: Colors.deepOrange),
                            ),
                            Text('Số lượng: ${item.quantity}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng: ${total.toStringAsFixed(0)}đ',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đặt hàng thành công!')),
                        );
                      },
                      child: const Text('Mua hàng'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
