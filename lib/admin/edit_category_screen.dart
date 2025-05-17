import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/category_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/sizes.dart';
import '../../../widgets/custom_text_form_field.dart';
import '../core/service/CategoryService.dart';
import '../widgets/custom_evalated_button.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final CategoryService _categoryService = CategoryService();

  late TextEditingController _nameController;
  bool _isFeatured = false;
  String? _currentImageUrl; // URL ảnh hiện tại (nếu sửa)
  File? _imageFileMobile;   // File ảnh mới chọn cho mobile
  Uint8List? _imageBytesWeb; // Dữ liệu byte ảnh mới chọn cho web
  String? _imageFileName;   // Tên file ảnh mới chọn

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _isFeatured = widget.category!.isFeatured;
      _currentImageUrl = widget.category!.image;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 512, maxHeight: 512);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        if (mounted) setState(() { _imageBytesWeb = bytes; _imageFileName = pickedFile.name; _imageFileMobile = null; _currentImageUrl = null; });
      } else {
        if (mounted) setState(() { _imageFileMobile = File(pickedFile.path); _imageFileName = pickedFile.path.split('/').last; _imageBytesWeb = null; _currentImageUrl = null; });
      }
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      _showWarningSnackBar('Vui lòng điền tên danh mục.');
      return;
    }
    // Ảnh là bắt buộc khi thêm mới nếu _currentImageUrl rỗng
    if (widget.category == null && (_imageFileMobile == null && _imageBytesWeb == null) && (_currentImageUrl == null || _currentImageUrl!.isEmpty) ) {
      _showWarningSnackBar('Vui lòng chọn ảnh cho danh mục mới.');
      return;
    }
    // Ảnh không được để trống khi cập nhật nếu trước đó nó có ảnh (trừ khi bạn có cơ chế xóa ảnh riêng)
    if (widget.category != null && (_currentImageUrl == null || _currentImageUrl!.isEmpty) && (_imageFileMobile == null && _imageBytesWeb == null) ) {
      _showWarningSnackBar('Ảnh danh mục không được để trống.');
      return;
    }


    if (mounted) setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();

      CategoryModel categoryData = CategoryModel(
        id: widget.category?.id ?? '',
        name: name,
        isFeatured: _isFeatured,
        image: _currentImageUrl ?? '', // Service sẽ cập nhật nếu có ảnh mới
      );

      if (widget.category == null) { // Thêm mới
        await _categoryService.addCategory(
          categoryData,
          imageFileMobile: _imageFileMobile,
          imageBytesWeb: _imageBytesWeb,
          imageFileName: _imageFileName,
        );
        _showSuccessSnackBar('Danh mục đã được thêm thành công!');
      } else { // Chỉnh sửa
        await _categoryService.updateCategory(
          categoryData, // categoryData chứa ID và image URL cũ (nếu có)
          newImageFileMobile: _imageFileMobile, // Ảnh mới nếu người dùng chọn
          newImageBytesWeb: _imageBytesWeb,
          newImageFileName: _imageFileName,
        );
        _showSuccessSnackBar('Danh mục đã được cập nhật thành công!');
      }
      if (mounted) Navigator.of(context).pop(true);

    } catch (e) {
      print("Error saving category: $e");
      _showErrorSnackBar('Lỗi lưu danh mục: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBarBase({
    required String title,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required IconData icon,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!mounted) return; // Kiểm tra nếu widget còn tồn tại

    Get.snackbar(
      title, // Tiêu đề của SnackBar
      message, // Nội dung của SnackBar
      snackPosition: snackPosition,
      backgroundColor: backgroundColor,
      colorText: textColor,
      borderRadius: Sizes.borderRadiusMd, // Bo góc
      margin: const EdgeInsets.all(Sizes.md), // Margin xung quanh SnackBar
      icon: Icon(icon, color: textColor, size: Sizes.iconMd),
      shouldIconPulse: true, // Hiệu ứng pulse cho icon
      duration: duration,
      isDismissible: true, // Cho phép người dùng vuốt để đóng
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCirc,
      reverseAnimationCurve: Curves.easeOutSine,
      snackStyle: SnackStyle.FLOATING, // Hoặc SnackStyle.GROUNDED
      // overlayBlur: 0.5, // (Tùy chọn) Làm mờ nền phía sau
      // overlayColor: Colors.black.withOpacity(0.1), // (Tùy chọn) Màu nền mờ
    );
  }

  void _showErrorSnackBar(String message) {
    _showSnackBarBase(
      title: 'Lỗi',
      message: message,
      backgroundColor: TColors.error.withOpacity(0.9), // Màu nền cho lỗi
      textColor: Colors.white,                        // Màu chữ
      icon: Icons.error_outline,                      // Icon lỗi
    );
  }

  void _showWarningSnackBar(String message) {
    _showSnackBarBase(
      title: 'Chú ý',
      message: message,
      backgroundColor: TColors.warning.withOpacity(0.9), // Màu nền cho cảnh báo
      textColor: Colors.black87,                         // Màu chữ (có thể là đen cho nền vàng)
      icon: Icons.warning_amber_rounded,               // Icon cảnh báo
    );
  }

  void _showSuccessSnackBar(String message) {
    _showSnackBarBase(
      title: 'Thành công',
      message: message,
      backgroundColor: TColors.success.withOpacity(0.9), // Màu nền cho thành công
      textColor: Colors.white,                          // Màu chữ
      icon: Icons.check_circle_outline,                 // Icon thành công
    );
  }


  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.category != null;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Chỉnh Sửa Danh Mục' : 'Thêm Danh Mục Mới'),
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
              Text('Ảnh Danh Mục', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: Sizes.spaceBtwItems / 2),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(color: TColors.light, borderRadius: BorderRadius.circular(Sizes.borderRadiusMd), border: Border.all(color: TColors.borderPrimary)),
                        alignment: Alignment.center,
                        child: _imageBytesWeb != null && kIsWeb
                            ? Image.memory(_imageBytesWeb!, fit: BoxFit.cover, width: 120, height: 120)
                            : _imageFileMobile != null && !kIsWeb
                            ? Image.file(_imageFileMobile!, fit: BoxFit.cover, width: 120, height: 120)
                            : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                            ? Image.network(_currentImageUrl!, fit: BoxFit.cover, width: 120, height: 120,
                            errorBuilder: (c,e,s) => const Icon(Iconsax.gallery_slash, size: 40, color: TColors.dark))
                            : const Icon(Iconsax.image, size: 40, color: TColors.dark),
                      ),
                    ),
                    TextButton.icon(icon: const Icon(Iconsax.gallery_edit, size: Sizes.iconSm), label: const Text('Chọn ảnh'), onPressed: _pickImage)
                  ],
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),

              CustomTextFormField(
                controller: _nameController,
                labelText: 'Tên danh mục *',
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Tên không được để trống.' : null,
              ),
              const SizedBox(height: Sizes.spaceBtwInputFields),
              Row(
                children: [
                  Checkbox(value: _isFeatured, activeColor: TColors.primary, onChanged: (value) => setState(() => _isFeatured = value ?? false)),
                  const Text('Đặt làm danh mục nổi bật?'),
                ],
              ),
              const SizedBox(height: Sizes.spaceBtwSections * 1.5),
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  text: isEditMode ? 'Lưu Thay Đổi' : 'Thêm Danh Mục',
                  onPressed: _isSaving ? null : _saveCategory,
                  isLoading: _isSaving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}