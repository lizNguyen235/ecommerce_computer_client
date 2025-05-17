import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../models/category_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/sizes.dart';
import '../core/service/CategoryService.dart';
import 'edit_category_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final CategoryService _categoryService = CategoryService();

  Future<void> _confirmDeleteCategory(BuildContext context, CategoryModel category) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa danh mục "${category.name}"?'),
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
        // Truyền category.image để service có thể xóa ảnh
        await _categoryService.deleteCategory(category.id, category.image);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xóa danh mục "${category.name}".'), backgroundColor: TColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa danh mục: ${e.toString()}'), backgroundColor: TColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<CategoryModel>>(
        stream: _categoryService.getAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: TColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: TColors.error)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có danh mục nào.', style: TextStyle(fontSize: Sizes.fontSizeMd, color: TColors.textSecondary)));
          }
          final categories = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(Sizes.md),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryListItem(context, category);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // StreamBuilder sẽ tự refresh khi có category mới được thêm
          await Get.to(() => AddEditCategoryScreen(category: null));
        },
        backgroundColor: TColors.primary,
        tooltip: 'Thêm danh mục mới',
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryListItem(BuildContext context, CategoryModel category) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.sm, vertical: Sizes.xs),
      leading: category.image.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(Sizes.borderRadiusSm),
        child: Image.network(category.image, width: 50, height: 50, fit: BoxFit.cover,
          errorBuilder: (c,e,s) => CircleAvatar(backgroundColor: TColors.light, radius: 25, child: Icon(Iconsax.gallery_slash, color: TColors.dark)),
          loadingBuilder: (c, child, progress) => progress == null ? child : const SizedBox(width: 50, height: 50, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      )
          : CircleAvatar(backgroundColor: TColors.primary.withOpacity(0.1), radius: 25, child: Icon(Iconsax.folder_2, color: TColors.primary)),
      title: Text(category.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: category.isFeatured
          ? Text('Nổi bật', style: textTheme.labelSmall?.copyWith(color: TColors.success, fontWeight: FontWeight.bold))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Iconsax.edit, color: TColors.primary, size: Sizes.iconMd),
            tooltip: 'Sửa danh mục',
            onPressed: () async {
              await Get.to(() => AddEditCategoryScreen(category: category));
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, color: TColors.error, size: Sizes.iconMd),
            tooltip: 'Xóa danh mục',
            onPressed: () => _confirmDeleteCategory(context, category),
          ),
        ],
      ),
    );
  }
}