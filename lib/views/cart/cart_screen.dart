import 'package:flutter/material.dart';
import '../home/home_page.dart'; // Đường dẫn đến class Product của bạn

class CartScreen extends StatefulWidget {
  final List<Product> cartItems;
  final bool isDarkMode;

  const CartScreen({Key? key, required this.cartItems, this.isDarkMode = false})
    : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Product> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.cartItems);
  }

  void _removeFromCart(Product product) {
    setState(() => _cartItems.remove(product));
  }

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.finalPrice);

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    final appBarColor = widget.isDarkMode ? Colors.grey[850]! : Colors.white;
    final cardColor = widget.isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor =
        widget.isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    final priceColor =
        widget.isDarkMode ? Colors.tealAccent[200]! : Colors.teal[700]!;
    final iconColor = widget.isDarkMode ? Colors.red[300]! : Colors.redAccent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Giỏ hàng',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body:
          _cartItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: subtitleColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Giỏ hàng trống',
                      style: TextStyle(fontSize: 18, color: subtitleColor),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cartItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = _cartItems[index];
                        return Card(
                          color: cardColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              product.name,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${product.finalPrice.toStringAsFixed(0)}đ',
                              style: TextStyle(
                                color: priceColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: iconColor,
                              ),
                              onPressed: () => _removeFromCart(product),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: cardColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng cộng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '${totalPrice.toStringAsFixed(0)}đ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: priceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thanh toán thành công!'),
                          ),
                        );
                        setState(() => _cartItems.clear());
                      },
                      style: ElevatedButton.styleFrom(
                        primary: priceColor,
                        onPrimary: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Thanh toán',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
