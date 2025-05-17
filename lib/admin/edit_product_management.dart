import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart'; // Để dùng GetX cho navigation và SnackBar
import 'package:intl/intl.dart'; // Cho NumberFormat.currency

// Điều chỉnh đường dẫn
import '../../../models/product_model.dart';
import '../../../models/category_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/sizes.dart';// Giả sử bạn có widget này
import '../../../widgets/custom_text_form_field.dart';
import '../core/service/CategoryService.dart';
import '../core/service/ProductService.dart';
import '../widgets/custom_evalated_button.dart'; // Giả sử bạn có widget này

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product; // Null nếu thêm mới, có giá trị nếu chỉnh sửa

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  // Controllers cho các trường
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  late TextEditingController _brandController;
  late TextEditingController _discountPercentageController; // Admin nhập % (0-50)

  // Trạng thái cho các lựa chọn và file
  CategoryModel? _selectedCategory;
  bool _isFeatured = false;
  File? _thumbnailFileMobile;
  Uint8List? _thumbnailBytesWeb;
  String? _thumbnailFileName;
  String? _currentThumbnailUrl; // URL thumbnail hiện tại (nếu sửa) hoặc đã upload

  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSaving = false;
  // Không cần _isUploadingThumbnail ở đây vì ProductService đã quản lý trạng thái đó

  double _calculatedEffectivePrice = 0.0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
    _descriptionController = TextEditingController();
    _brandController = TextEditingController();
    _discountPercentageController = TextEditingController(text: '0'); // Mặc định 0%

    // Lắng nghe thay đổi để tự động tính toán giá
    _priceController.addListener(_calculatePrices);
    _discountPercentageController.addListener(_calculatePrices);

    _loadInitialData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _discountPercentageController.dispose();
    _priceController.removeListener(_calculatePrices);
    _discountPercentageController.removeListener(_calculatePrices);
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadCategories();

    if (widget.product != null) {
      // Chế độ chỉnh sửa, điền dữ liệu từ product hiện tại
      final p = widget.product!;
      _titleController.text = p.title;
      _priceController.text = p.price.toStringAsFixed(0);
      _stockController.text = p.stock.toString();
      _descriptionController.text = p.description ?? '';
      _brandController.text = p.brand;
      _isFeatured = p.isFeatured ?? false;
      _currentThumbnailUrl = p.thumbnail;
      _discountPercentageController.text = p.discountPercentageDisplay.toStringAsFixed(0);

      // Tìm category đã chọn trong danh sách _categories
      if (_categories.isNotEmpty && p.category.isNotEmpty) {
        _selectedCategory = _categories.firstWhere(
              (cat) => cat.name == p.category,
          orElse: () => _categories.first, // Fallback hoặc để null nếu không tìm thấy
        );
      }
    } else {
      // Chế độ thêm mới
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
    }
    _calculatePrices(); // Tính giá lần đầu sau khi điền dữ liệu (hoặc mặc định)
    if (mounted) setState(() {});
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    setState(() => _isLoadingCategories = true);
    try {
      _categories = await _categoryService.getAllCategories().first;
    } catch (e) {
      print("Error loading categories: $e");
      if (mounted) _showErrorSnackBar('Lỗi tải danh mục: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  void _calculatePrices() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final discountPercent = double.tryParse(_discountPercentageController.text) ?? 0.0;
    double discountRatio = (discountPercent / 100.0).clamp(0.0, 0.5).toDouble(); // Kẹp tỷ lệ

    if (mounted) {
      setState(() {
        _calculatedEffectivePrice = price * (1 - discountRatio);
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70, maxWidth: 1024, maxHeight: 1024);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _thumbnailBytesWeb = bytes;
            _thumbnailFileName = pickedFile.name;
            _thumbnailFileMobile = null;
            _currentThumbnailUrl = null; // Ảnh mới sẽ được hiển thị
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _thumbnailFileMobile = File(pickedFile.path);
            _thumbnailFileName = pickedFile.path.split('/').last;
            _thumbnailBytesWeb = null;
            _currentThumbnailUrl = null; // Ảnh mới sẽ được hiển thị
          });
        }
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      _showWarningSnackBar('Vui lòng kiểm tra lại các thông tin đã nhập.');
      return;
    }
    if (_selectedCategory == null) {
      _showWarningSnackBar('Vui lòng chọn một danh mục cho sản phẩm.');
      return;
    }
    if (widget.product == null && // Chế độ thêm mới
        (_thumbnailFileMobile == null && _thumbnailBytesWeb == null && (_currentThumbnailUrl == null || _currentThumbnailUrl!.isEmpty))) {
      _showWarningSnackBar('Vui lòng chọn ảnh thumbnail cho sản phẩm mới.');
      return;
    }

    if (mounted) setState(() => _isSaving = true);

    try {
      final title = _titleController.text.trim();
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final stock = int.tryParse(_stockController.text) ?? 0;
      final description = _descriptionController.text.trim();
      final brand = _brandController.text.trim();
      final discountPercent = double.tryParse(_discountPercentageController.text) ?? 0.0;
      final discountRatio = (discountPercent / 100.0).clamp(0.0, 0.5).toDouble();

      ProductModel productData = ProductModel(
        id: widget.product?.id ?? '',
        title: title,
        price: price,
        stock: stock,
        category: _selectedCategory!.name, // Hoặc _selectedCategory.id nếu bạn lưu ID
        brand: brand,
        description: description.isNotEmpty ? description : null,
        isFeatured: _isFeatured,
        thumbnail: _currentThumbnailUrl ?? '',
        salePriceRatio: discountRatio,
        date: widget.product?.date, // Giữ date cũ nếu sửa, hoặc toMap sẽ đặt serverTimestamp
        // KHÔNG CÓ SKU
      );

      if (widget.product == null) { // Thêm mới
        await _productService.addProduct(
          productData,
          thumbnailFileMobile: _thumbnailFileMobile,
          thumbnailBytesWeb: _thumbnailBytesWeb,
          thumbnailFileName: _thumbnailFileName,
        );
        _showSuccessSnackBar('Sản phẩm đã được thêm thành công!');
      } else { // Chỉnh sửa
        await _productService.updateProduct(
          productData,
          newThumbnailFileMobile: _thumbnailFileMobile,
          newThumbnailBytesWeb: _thumbnailBytesWeb,
          newThumbnailFileName: _thumbnailFileName,
        );
        _showSuccessSnackBar('Sản phẩm đã được cập nhật thành công!');
      }
      if (mounted) Navigator.of(context).pop(true); // Trả về true để ProductManagementScreen biết cần refresh

    } catch (e) {
      print("Error saving product: $e");
      _showErrorSnackBar('Lỗi lưu sản phẩm: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    Get.snackbar('Lỗi', message, backgroundColor: TColors.error.withOpacity(0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }
  void _showWarningSnackBar(String message) {
    if (!mounted) return;
    Get.snackbar('Chú ý', message, backgroundColor: TColors.warning.withOpacity(0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    Get.snackbar('Thành công', message, backgroundColor: TColors.success.withOpacity(0.8), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }


  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.product != null;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Chỉnh Sửa Sản Phẩm' : 'Thêm Sản Phẩm Mới'),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: Sizes.md),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: TColors.primary, strokeWidth: 2.5)),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Sizes.defaultSpace),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Ảnh Thumbnail ---
              Text('Ảnh Đại Diện Sản Phẩm', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: Sizes.spaceBtwItems / 2),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickThumbnail,
                      child: Container(
                        width: 150, height: 150,
                        decoration: BoxDecoration(
                          color: TColors.light,
                          borderRadius: BorderRadius.circular(Sizes.borderRadiusMd),
                          border: Border.all(color: TColors.borderPrimary),
                        ),
                        alignment: Alignment.center,
                        child: _thumbnailBytesWeb != null && kIsWeb
                            ? Image.memory(_thumbnailBytesWeb!, fit: BoxFit.cover, width: 150, height: 150)
                            : _thumbnailFileMobile != null && !kIsWeb
                            ? Image.file(_thumbnailFileMobile!, fit: BoxFit.cover, width: 150, height: 150)
                            : (_currentThumbnailUrl != null && _currentThumbnailUrl!.isNotEmpty)
                            ? Image.network(_currentThumbnailUrl!, fit: BoxFit.cover, width: 150, height: 150,
                            errorBuilder: (c,e,s) => const Icon(Iconsax.gallery_slash, size: 50, color: TColors.dark))
                            : const Icon(Iconsax.image, size: 50, color: TColors.dark),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Iconsax.gallery_edit, size: Sizes.iconSm),
                      label: const Text('Chọn ảnh Thumbnail'),
                      onPressed: _pickThumbnail,
                    )
                  ],
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),

              // --- Thông tin cơ bản ---
              Text('Thông Tin Cơ Bản', style: textTheme.titleLarge),
              const SizedBox(height: Sizes.spaceBtwInputFields),
              CustomTextFormField(controller: _titleController, labelText: 'Tên sản phẩm *', validator: (v) => v == null || v.isEmpty ? 'Tên sản phẩm không được để trống' : null),
              const SizedBox(height: Sizes.spaceBtwInputFields),
              CustomTextFormField(controller: _descriptionController, labelText: 'Mô tả sản phẩm', maxLines: 4),
              // ĐÃ BỎ TRƯỜNG SKU Ở ĐÂY
              const SizedBox(height: Sizes.spaceBtwSections),


              // --- Giá & Tồn Kho & Giảm Giá ---
              Text('Giá & Tồn Kho', style: textTheme.titleLarge),
              const SizedBox(height: Sizes.spaceBtwInputFields),
              Row(
                children: [
                  Expanded(child: CustomTextFormField(controller: _priceController, labelText: 'Giá gốc (VNĐ) *', keyboardType: TextInputType.number, validator: (v) => (double.tryParse(v ?? '0') ?? 0) <=0 ? 'Giá phải lớn hơn 0' : null)),
                  const SizedBox(width: Sizes.spaceBtwInputFields),
                  Expanded(child: CustomTextFormField(controller: _stockController, labelText: 'Tồn kho *', keyboardType: TextInputType.number, validator: (v) => (int.tryParse(v ?? '-1') ?? -1) < 0 ? 'Tồn kho không hợp lệ' : null)),
                ],
              ),
              const SizedBox(height: Sizes.spaceBtwInputFields),
              CustomTextFormField(
                controller: _discountPercentageController,
                labelText: 'Phần trăm giảm giá (%)',
                hintText: 'Từ 0 đến 50',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final val = double.tryParse(v);
                  if (val == null) return 'Phải là số';
                  if (val < 0 || val > 50) return 'Từ 0 đến 50';
                  return null;
                },
              ),
              const SizedBox(height: Sizes.xs),
              Text('Giá sau giảm: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(_calculatedEffectivePrice)}', style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
              const SizedBox(height: Sizes.spaceBtwSections),


              // --- Danh mục & Thương hiệu ---
              Text('Phân Loại', style: textTheme.titleLarge),
              const SizedBox(height: Sizes.spaceBtwInputFields),
              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<CategoryModel>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Danh mục sản phẩm *', border: OutlineInputBorder()),
                items: _categories.map((CategoryModel category) {
                  return DropdownMenuItem<CategoryModel>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (CategoryModel? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Vui lòng chọn danh mục' : null,
              ),
              const SizedBox(height: Sizes.spaceBtwInputFields),
              CustomTextFormField(controller: _brandController, labelText: 'Thương hiệu *', validator: (v) => v == null || v.isEmpty ? 'Thương hiệu không để trống' : null),
              const SizedBox(height: Sizes.spaceBtwSections),


              // --- Thuộc tính khác ---
              Text('Thuộc Tính Khác', style: textTheme.titleLarge),
              const SizedBox(height: Sizes.spaceBtwInputFields),
              Row(
                children: [
                  Checkbox(value: _isFeatured, onChanged: (value) => setState(() => _isFeatured = value ?? false)),
                  const Text('Sản phẩm nổi bật?'),
                ],
              ),
              const SizedBox(height: Sizes.spaceBtwSections * 1.5),


              // --- Nút Lưu ---
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  text: isEditMode ? 'Lưu Thay Đổi' : 'Thêm Sản Phẩm',
                  onPressed: _isSaving ? null : _saveProduct,
                  isLoading: _isSaving,
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}

