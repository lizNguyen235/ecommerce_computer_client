import 'package:ecommerce_computer_client/views/product/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../login/login.dart';

class Product {
  final String name;
  final String imageUrl;
  final double price;
  final double? discount;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    this.discount,
  });

  double get finalPrice => discount != null ? price * (1 - discount!) : price;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  final List<String> categories = [
    "Promotional Products",
    "New Products",
    "Best Sellers",
    "Laptops",
    "Monitors",
    "Hard Drives",
    "Keyboards",
    "Mice",
  ];

  final Map<String, List<Product>> categoryProducts = {};
  bool isDarkMode = false;
  bool showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    for (var cat in categories) {
      categoryProducts[cat] = List.generate(
        6,
        (index) => Product(
          name: "$cat #$index",
          imageUrl: "https://picsum.photos/200?random=${cat.hashCode + index}",
          price: 1000000 + index * 500000,
          discount: index % 2 == 0 ? 0.1 + index * 0.03 : null,
        ),
      );
    }

    _positionsListener.itemPositions.addListener(() {
      final positions = _positionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        final firstVisible = positions.first.index;
        setState(() {
          showScrollToTop = firstVisible > 2;
        });
      }
    });
  }

  void scrollToCategory(int index) {
    _scrollController.scrollTo(
      index: index + 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void scrollToTop() {
    _scrollController.scrollTo(
      index: 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Promotional Products":
        return Icons.local_offer;
      case "New Products":
        return Icons.fiber_new;
      case "Best Sellers":
        return Icons.trending_up;
      case "Laptops":
        return Icons.laptop_mac;
      case "Monitors":
        return Icons.desktop_windows;
      case "Hard Drives":
        return Icons.sd_storage;
      case "Keyboards":
        return Icons.keyboard;
      case "Mice":
        return Icons.mouse;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final bgColor =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFFF7F8FA);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
        elevation: 1,
        leading: PopupMenuButton<int>(
          icon: Icon(Icons.menu, color: textColor),
          itemBuilder:
              (context) => List.generate(categories.length, (index) {
                return PopupMenuItem(
                  value: index,
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(categories[index]),
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      Text(categories[index]),
                    ],
                  ),
                );
              }),
          onSelected: scrollToCategory,
        ),
        centerTitle: true,
        title: Text(
          'Computer Store',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.wb_sunny : Icons.dark_mode,
              color: textColor,
            ),
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle, color: textColor),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'login', child: Text('Đăng nhập')),
                  const PopupMenuItem(
                    value: 'register',
                    child: Text('Đăng ký'),
                  ),
                ],
            onSelected: (value) {
              if (value == 'login') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginDialog()),
                );
              }
              if (value == 'register') {
                // Bạn có thể thay bằng RegisterDialog nếu cần
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginDialog()),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ScrollablePositionedList.builder(
            itemScrollController: _scrollController,
            itemPositionsListener: _positionsListener,
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _buildHeader(isMobile, textColor);
              final cat = categories[index - 1];
              return _buildCategorySection(
                cat,
                categoryProducts[cat]!,
                textColor,
                cardColor,
              );
            },
          ),
          if (showScrollToTop)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: scrollToTop,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.arrow_upward),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile, Color textColor) {
    return Column(
      children: [
        Container(
          height: isMobile ? 120 : 160,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("https://picsum.photos/900/300?blur=3"),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            "🔥 Chào mừng bạn đến với Computer Store 🔥",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    String title,
    List<Product> products,
    Color textColor,
    Color cardColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16, top: 24, bottom: 10),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;
              double screenWidth = constraints.maxWidth;

              if (screenWidth < 400) {
                crossAxisCount = 1;
              } else if (screenWidth > 600) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder:
                    (context, index) => _buildProductCard(
                      products[index],
                      cardColor,
                      textColor,
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, Color bgColor, Color textColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailScreen(
                  product: product,
                  isDarkMode: isDarkMode,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(product.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${product.finalPrice.toStringAsFixed(0)}đ",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.discount != null)
                    Text(
                      "${product.price.toStringAsFixed(0)}đ",
                      style: const TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            if (product.discount != null)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "-${(product.discount! * 100).toInt()}%",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
