import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Cho DocumentSnapshot
import 'package:intl/intl.dart';
import '../../../models/product_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/sizes.dart';
import '../core/service/ProductService.dart';
import 'edit_product_management.dart'; // Màn hình này bạn sẽ tạo sau

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();

  List<ProductModel> _products = [];
  bool _isLoadingFirstPage = true; // Loading cho lần tải đầu tiên
  bool _isLoadingMore = false;    // Loading khi tải thêm trang
  bool _hasMoreProducts = true;   // Còn sản phẩm để tải không
  DocumentSnapshot? _lastVisibleDocument; // Document cuối cùng của trang đã tải
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialProducts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoadingFirstPage = true;
      _products = [];
      _lastVisibleDocument = null;
      _hasMoreProducts = true;
      _errorMessage = null;
    });

    try {
      final querySnapshot = await _productService.getProductPage(); // Lấy trang đầu tiên
      if (mounted) {
        _processProductPage(querySnapshot);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
          _hasMoreProducts = false; // Dừng tải thêm nếu có lỗi ban đầu
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingFirstPage = false);
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreProducts || !mounted) return;

    setState(() => _isLoadingMore = true);
    try {
      final querySnapshot = await _productService.getProductPage(lastVisibleDocument: _lastVisibleDocument);
      if (mounted) {
        _processProductPage(querySnapshot);
      }
    } catch (e) {
      if (mounted) {
        // Không set _errorMessage ở đây để không ghi đè lỗi tải ban đầu (nếu có)
        // Hoặc bạn có thể có một biến lỗi riêng cho _loadMoreProducts
        print("Error loading more products: $e");
        setState(() {
          _hasMoreProducts = false; // Dừng tải thêm nếu có lỗi
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _processProductPage(QuerySnapshot<ProductModel> querySnapshot) {
    final newProducts = querySnapshot.docs.map((doc) => doc.data()).toList();
    setState(() {
      _products.addAll(newProducts);
      if (newProducts.length < ProductService.productsPerPage) {
        _hasMoreProducts = false;
      }
      if (querySnapshot.docs.isNotEmpty) {
        _lastVisibleDocument = querySnapshot.docs.last;
      } else {
        _hasMoreProducts = false; // Không còn document nào để làm mốc
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && // Gần cuối hơn
        !_isLoadingFirstPage && // Không tải thêm khi đang tải trang đầu
        !_isLoadingMore &&
        _hasMoreProducts) {
      _loadMoreProducts();
    }
  }

  Future<void> _confirmDeleteProduct(BuildContext context, ProductModel product) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product.title}"? Hành động này không thể hoàn tác.'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Hủy')),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: TColors.error),
              child: const Text('Xóa'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(product.id, product.thumbnail);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xóa sản phẩm "${product.title}".'), backgroundColor: TColors.success),
          );
          _refreshProducts(); // Tải lại danh sách sau khi xóa
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa sản phẩm: ${e.toString()}'), backgroundColor: TColors.error),
          );
        }
      }
    }
  }

  Future<void> _refreshProducts() async {
    await _loadInitialProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar thường sẽ được quản lý bởi AdminMainPage
      // appBar: AppBar(title: const Text('Quản Lý Sản Phẩm')),
      body: _buildBodyContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => AddEditProductScreen(product: null)); // product: null -> thêm mới
          if (result == true) {
            _refreshProducts();
          }
        },
        backgroundColor: TColors.primary,
        tooltip: 'Thêm sản phẩm mới',
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoadingFirstPage && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: TColors.primary));
    }
    if (_errorMessage != null && _products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $_errorMessage', style: const TextStyle(color: TColors.error), textAlign: TextAlign.center),
              const SizedBox(height: Sizes.spaceBtwItems),
              ElevatedButton.icon(
                icon: const Icon(Iconsax.refresh, color: Colors.white),
                label: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
                onPressed: _refreshProducts,
              )
            ],
          ),
        ),
      );
    }
    if (_products.isEmpty && !_isLoadingFirstPage) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Chưa có sản phẩm nào. Nhấn "+" để thêm mới.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: Sizes.fontSizeMd, color: TColors.textSecondary)),
              const SizedBox(height: Sizes.spaceBtwItems),
              ElevatedButton.icon(
                icon: const Icon(Iconsax.refresh, color: Colors.white),
                label: const Text('Tải lại', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
                onPressed: _refreshProducts,
              )
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      color: TColors.primary,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(Sizes.md),
        itemCount: _products.length + (_hasMoreProducts ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: Sizes.spaceBtwItems),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            return _isLoadingMore
                ? const Padding(padding: EdgeInsets.symmetric(vertical: Sizes.md), child: Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: TColors.primary)))
                : (_hasMoreProducts ? const SizedBox.shrink() : Padding( // Chỉ hiển thị "đã hết" nếu thực sự hết và không loading
              padding: const EdgeInsets.symmetric(vertical: Sizes.lg),
              child: Center(child: Text("Đã tải hết sản phẩm.", style: TextStyle(color: TColors.textSecondary))),
            ));
          }
          final product = _products[index];
          return _buildProductCard(context, product);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final bool hasDiscount = product.salePrice > 0.0 && product.salePrice <= 0.5;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero, // ListView.separated đã có padding
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.cardRadiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Sizes.borderRadiusMd),
                  child: product.thumbnail.isNotEmpty
                      ? Image.network(
                    product.thumbnail, width: 90, height: 90, fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) => progress == null ? child : Container(width: 90, height: 90, color: TColors.light.withOpacity(0.5), child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: TColors.primary))),
                    errorBuilder: (ctx, err, stack) => Container(width: 90, height: 90, color: TColors.light.withOpacity(0.5), child: const Icon(Iconsax.gallery_slash, color: TColors.dark, size: 30)),
                  )
                      : Container(width: 90, height: 90, color: TColors.light.withOpacity(0.5), child: const Icon(Iconsax.gallery_add, color: TColors.dark, size: 40)),
                ),
                const SizedBox(width: Sizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: Sizes.fontSizeLg -1), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: Sizes.xs),
                      Text('Loại: ${product.category}', style: textTheme.bodyMedium?.copyWith(color: TColors.dark)),
                      Text('Hãng: ${product.brand}', style: textTheme.bodyMedium?.copyWith(color: TColors.dark)),
                      const SizedBox(height: Sizes.sm),
                      Row(
                        children: [
                          Text(
                      NumberFormat.currency(
                          locale: 'en_US', // Locale cho Hoa Kỳ
                          symbol: '\$',    // Ký hiệu đô la Mỹ
                          decimalDigits: 2 // Thông thường dùng 2 chữ số thập phân cho USD
                      ).format(product.effectivePrice),
                            style: textTheme.titleMedium?.copyWith(color: hasDiscount ? TColors.primary : textTheme.titleMedium?.color, fontWeight: FontWeight.bold),
                          ),
                          if (hasDiscount)
                            Padding(
                              padding: const EdgeInsets.only(left: Sizes.sm),
                              child: Text(
                                NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 0).format(product.price),
                                style: textTheme.bodySmall?.copyWith(color: TColors.textSecondary, decoration: TextDecoration.lineThrough, fontSize: Sizes.fontSizeSm -1),
                              ),
                            ),
                        ],
                      ),
                      if (hasDiscount)
                        Text(
                          'Giảm: ${product.discountPercentageDisplay.toStringAsFixed(0)}%',
                          style: textTheme.labelMedium?.copyWith(color: TColors.success, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: Sizes.spaceBtwItems, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kho: ${product.stock}', style: textTheme.bodySmall?.copyWith(color: product.stock < 10 ? TColors.warning : TColors.textSecondary)),
                    if(product.isFeatured ?? false)
                      Chip(
                        avatar: Icon(Iconsax.star_1, color: TColors.secondary.withOpacity(0.9), size: Sizes.iconSm -2),
                        label: Text('Nổi bật', style: textTheme.labelSmall?.copyWith(color: TColors.textPrimary.withOpacity(0.8))),
                        backgroundColor: TColors.secondary.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(horizontal: Sizes.xs, vertical: 0),
                        labelPadding: const EdgeInsets.only(left: Sizes.xs/2),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Iconsax.edit, color: TColors.primary, size: Sizes.iconMd + 2),
                      tooltip: 'Sửa sản phẩm',
                      onPressed: () async {
                        final result = await Get.to(() => AddEditProductScreen(product: product));
                        if (result == true) _refreshProducts();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.trash, color: TColors.error, size: Sizes.iconMd + 2),
                      tooltip: 'Xóa sản phẩm',
                      onPressed: () => _confirmDeleteProduct(context, product),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}