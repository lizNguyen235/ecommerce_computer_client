import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: ProductDetailPage()));
}

class ProductDetailPage extends StatelessWidget {
  final String name = "Laptop Lenovo Legion 5";
  final int price = 28999000;
  final String brand = "Lenovo";
  final List<String> images = [
    'https://via.placeholder.com/400x200.png?text=Image+1',
    'https://via.placeholder.com/400x200.png?text=Image+2',
    'https://via.placeholder.com/400x200.png?text=Image+3',
  ];
  final String description = '''
Laptop gaming hiệu năng cao, trang bị CPU AMD Ryzen 7, GPU RTX 4060, màn hình 165Hz QHD. Thiết kế bền bỉ, phù hợp cho cả chơi game và làm việc nặng.

- CPU: AMD Ryzen 7 6800H
- GPU: NVIDIA RTX 4060
- RAM: 16GB DDR5
- Ổ cứng: 512GB SSD NVMe
- Màn hình: 15.6" QHD 165Hz

Hỗ trợ bảo hành 2 năm. Cổng kết nối đa dạng. Khung máy chắc chắn, bàn phím RGB. Trọng lượng 2.4kg, phù hợp cho game thủ và dân kỹ thuật.
''';

  final List<String> variants = ['RAM 16GB - SSD 512GB', 'RAM 32GB - SSD 1TB'];

  final List<Map<String, dynamic>> comments = [
    {
      'user': 'Nguyễn Văn A',
      'comment': 'Sản phẩm rất tốt, chạy mượt.',
      'rating': 5,
    },
    {
      'user': 'Trần Thị B',
      'comment': 'Giá hơi cao nhưng đáng tiền.',
      'rating': 4,
    },
    {'user': 'Lê C', 'comment': 'Máy hơi nóng khi chơi game lâu.', 'rating': 3},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chi tiết sản phẩm")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '$brand | ${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} VNĐ',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),

            // Image Carousel
            SizedBox(
              height: 200,
              child: PageView(
                children:
                    images.map((url) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Image.network(url, fit: BoxFit.cover),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 20),

            Text(
              "Mô tả sản phẩm",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            Text(
              "Biến thể",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: variants.map((v) => Chip(label: Text(v))).toList(),
            ),
            SizedBox(height: 20),

            Text(
              "Đánh giá",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...comments.map(
              (comment) => ListTile(
                leading: Icon(Icons.person),
                title: Text(comment['user']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < comment['rating']
                              ? Icons.star
                              : Icons.star_border,
                          size: 18,
                          color: Colors.orange,
                        );
                      }),
                    ),
                    SizedBox(height: 4),
                    Text(comment['comment']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
