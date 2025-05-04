import 'package:flutter/material.dart';
import '../home/home_page.dart'; // import Product class

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final bool isDarkMode;

  const ProductDetailScreen({
    Key? key,
    required this.product,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Palette
    final bgColor = isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    final appBarColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    final priceColor = isDarkMode ? Colors.tealAccent[200]! : Colors.teal[700]!;
    final oldPriceColor = isDarkMode ? Colors.grey[500]! : Colors.grey[600]!;
    final buttonColor = priceColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Chi tiết sản phẩm',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Name
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              // Price row
              Row(
                children: [
                  Text(
                    '${product.finalPrice.toStringAsFixed(0)}đ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: priceColor,
                    ),
                  ),
                  if (product.discount != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      '${product.price.toStringAsFixed(0)}đ',
                      style: TextStyle(
                        fontSize: 16,
                        color: oldPriceColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.red[400]! : Colors.redAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${(product.discount! * 100).toInt()}%',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              // Description section
              Text(
                'Mô tả sản phẩm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Đây là sản phẩm chất lượng cao, được nhiều khách hàng tin dùng. Bảo hành chính hãng 12 tháng. '
                  'Đảm bảo trải nghiệm mượt mà và độ bền tối ưu.',
                  style: TextStyle(
                    fontSize: 16,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Add to cart button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, product),
                  style: ElevatedButton.styleFrom(
                    primary: buttonColor,
                    onPrimary: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Thêm vào giỏ hàng',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
