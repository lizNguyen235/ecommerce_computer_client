import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/controller/product_controller.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/views/product/product_cart_vertical.dart';
import 'package:ecommerce_computer_client/views/shimmer/vertical_product_shimmer.dart';
import 'package:ecommerce_computer_client/widgets/custom_grid_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final ProductController controller = ProductController.instance;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.searchQuery.value = '';
    controller.selectedBrand.value = 'All';
    controller.selectedCategory.value = 'All';
    controller.priceRange.value = const RangeValues(0, 1000);
    controller.sortBy.value = 'titleAsc';
    fetchProducts();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.9) {
      if (!controller.isLoadingAll.value && controller.hasMoreAll.value) {
        debugPrint('Reached bottom, loading more products...');
        fetchProducts(loadMore: true);
      }
    }
  }

  Future<void> fetchProducts({bool loadMore = false}) async {
    try {
      controller.isLoadingAll.value = true;
      if (loadMore) {
        debugPrint('Loading more products with startAfterAll: ${controller.startAfterAll}');
        await controller.fetchAllProducts();
      } else {
        controller.searchQuery.value = searchController.text;
        debugPrint('Resetting and fetching products with search: ${searchController.text}');
        await controller.fetchAllProducts(reset: true);
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      controller.isLoadingAll.value = false;
    }
  }

  void _showFilterBottomSheet() {
    String tempBrand = controller.selectedBrand.value;
    String tempCategory = controller.selectedCategory.value;
    RangeValues tempPriceRange = controller.priceRange.value;
    String tempSortBy = controller.sortBy.value == 'titleAsc' ? 'Relevance' : controller.sortBy.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.2,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter & Sort',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: tempBrand,
                      items: ['All', ...controller.brands]
                          .map((brand) => DropdownMenuItem(
                        value: brand,
                        child: Text(brand),
                      ))
                          .toList(),
                      onChanged: (value) => tempBrand = value!,
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: tempCategory,
                      items: ['All', ...controller.categories]
                          .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                          .toList(),
                      onChanged: (value) => tempCategory = value!,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => RangeSlider(
                values: controller.priceRange.value,
                min: 0,
                max: 1000,
                divisions: 100,
                labels: RangeLabels(
                  controller.priceRange.value.start.round().toString(),
                  controller.priceRange.value.end.round().toString(),
                ),
                onChanged: (values) {
                  controller.priceRange.value = values;
                  tempPriceRange = values;
                },
                activeColor: TColors.primary,
                inactiveColor: Colors.grey,
              )),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: tempSortBy,
                items: ['Relevance', 'nameDesc', 'priceAsc', 'priceDesc']
                    .map((sort) => DropdownMenuItem(
                  value: sort,
                  child: Text(sort),
                ))
                    .toList(),
                onChanged: (value) => tempSortBy = value!,
                decoration: const InputDecoration(labelText: 'Sort By'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.resetFilterSort();
                      searchController.clear();
                      Navigator.pop(context);
                      fetchProducts();
                    },
                    child: const Text('Reset', style: TextStyle(fontFamily: bold)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      controller.searchQuery.value = searchController.text;
                      controller.selectedBrand.value = tempBrand;
                      controller.selectedCategory.value = tempCategory;
                      controller.priceRange.value = tempPriceRange;
                      controller.sortBy.value = tempSortBy == 'Relevance' ? 'titleAsc' : tempSortBy;
                      Navigator.pop(context);
                      fetchProducts();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      textStyle: const TextStyle(fontSize: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Apply', style: TextStyle(fontFamily: bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
                fetchProducts();
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingAll.value && controller.allProducts.isEmpty) {
                return const TVerticalProductShimmer();
              }
              return CustomGridLayout(
                scrollController: scrollController,
                itemCount: controller.allProducts.length +
                    (controller.isLoadingAll.value && controller.hasMoreAll.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.allProducts.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ProductCartVertical(
                    product: controller.allProducts[index],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}