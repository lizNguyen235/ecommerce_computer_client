import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/product/product_cart_vertical.dart';
import 'package:ecommerce_computer_client/widgets/custom_grid_layout.dart';
import 'package:iconsax/iconsax.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'Black Sports Shoes',
      'brand': 'Nike',
      'category': 'Shoes',
      'price': 256.0,
      'rating': 4.5,
    },
    {
      'id': 2,
      'name': 'Green Running Shoes',
      'brand': 'Adidas',
      'category': 'Shoes',
      'price': 180.0,
      'rating': 4.0,
    },
    {
      'id': 3,
      'name': 'Blue Jacket',
      'brand': 'Puma',
      'category': 'Clothing',
      'price': 120.0,
      'rating': 4.2,
    },
    {
      'id': 4,
      'name': 'Red T-Shirt',
      'brand': 'H&M',
      'category': 'Clothing',
      'price': 45.0,
      'rating': 3.8,
    },
    {
      'id': 5,
      'name': 'White Sneakers',
      'brand': 'Nike',
      'category': 'Shoes',
      'price': 220.0,
      'rating': 4.7,
    },
  ];

  List<Map<String, dynamic>> _filteredProducts = [];
  String _searchQuery = '';
  String _sortCriteria = 'Relevance';
  final double _minPrice = 0;
  double _maxPrice = 300;
  String _selectedBrand = 'All';
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 300); // Explicitly initialize
  Timer? _debounce;
  bool _isDraggingSlider = false;

  @override
  void initState() {
    super.initState();
    final maxPriceInProducts = _products
        .map((p) => (p['price'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    _maxPrice = maxPriceInProducts.ceilToDouble();
    _priceRange = RangeValues(_minPrice, _maxPrice);
    _filteredProducts = List.from(_products);
    _applyFiltersAndSort();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _applyFiltersAndSort() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _filteredProducts =
            _products.where((product) {
              final matchesSearch = product['name']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
              final matchesBrand =
                  _selectedBrand == 'All' || product['brand'] == _selectedBrand;
              final matchesCategory =
                  _selectedCategory == 'All' ||
                  product['category'] == _selectedCategory;
              final matchesPrice =
                  product['price'] >= _priceRange.start &&
                  product['price'] <= _priceRange.end;
              return matchesSearch &&
                  matchesBrand &&
                  matchesCategory &&
                  matchesPrice;
            }).toList();

        _filteredProducts.sort((a, b) {
          switch (_sortCriteria) {
            case 'Name (A-Z)':
              return a['name'].compareTo(b['name']);
            case 'Name (Z-A)':
              return b['name'].compareTo(a['name']);
            case 'Price (Low to High)':
              return a['price'].compareTo(b['price']);
            case 'Price (High to Low)':
              return b['price'].compareTo(a['price']);
            default:
              return 0;
          }
        });
      });
    });
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _sortCriteria = 'Relevance';
      _selectedBrand = 'All';
      _selectedCategory = 'All';
      _priceRange = RangeValues(_minPrice, _maxPrice);
      _applyFiltersAndSort();
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => StatefulBuilder(
                  builder:
                      (
                        BuildContext context,
                        StateSetter setModalState,
                      ) => Container(
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics:
                              _isDraggingSlider
                                  ? const NeverScrollableScrollPhysics()
                                  : null,
                          child: Padding(
                            padding: EdgeInsets.all(Sizes.defaultSpace),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Icon(
                                      Icons.drag_handle,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Filter & Sort',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: bold,
                                    color: TColors.dark,
                                  ),
                                ),
                                const Divider(
                                  color: TColors.light,
                                  thickness: 1,
                                ),
                                const SizedBox(height: Sizes.spaceBtwItems),
                                // Brand and Category in One Row
                                Row(
                                  children: [
                                    // Brand Filter
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Brand',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: semibold,
                                                  color: TColors.dark,
                                                ),
                                              ),
                                              Icon(
                                                Icons.filter_list,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          DropdownButtonFormField<String>(
                                            value: _selectedBrand,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Sizes.sm,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: TColors.light,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: TColors.light,
                                            ),
                                            dropdownColor: TColors.light,
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: TColors.dark,
                                            ),
                                            isExpanded: true,
                                            items:
                                                [
                                                      'All',
                                                      'Nike',
                                                      'Adidas',
                                                      'Puma',
                                                      'H&M',
                                                    ]
                                                    .map(
                                                      (brand) =>
                                                          DropdownMenuItem(
                                                            value: brand,
                                                            child: Text(
                                                              brand,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    regular,
                                                              ),
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                            onChanged: (value) {
                                              setModalState(
                                                () => _selectedBrand = value!,
                                              );
                                              _applyFiltersAndSort();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: Sizes.spaceBtwItems),
                                    // Category Filter
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Category',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: semibold,
                                                  color: TColors.dark,
                                                ),
                                              ),
                                              Icon(
                                                Icons.category,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          DropdownButtonFormField<String>(
                                            value: _selectedCategory,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Sizes.sm,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: TColors.light,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: TColors.light,
                                            ),
                                            dropdownColor: TColors.light,
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: TColors.dark,
                                            ),
                                            isExpanded: true,
                                            items:
                                                ['All', 'Shoes', 'Clothing']
                                                    .map(
                                                      (category) =>
                                                          DropdownMenuItem(
                                                            value: category,
                                                            child: Text(
                                                              category,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    regular,
                                                              ),
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                            onChanged: (value) {
                                              setModalState(
                                                () =>
                                                    _selectedCategory = value!,
                                              );
                                              _applyFiltersAndSort();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Sizes.spaceBtwItems),
                                // Price Range Filter with RangeSlider
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Price Range',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: semibold,
                                        color: TColors.dark,
                                      ),
                                    ),
                                    Icon(
                                      Icons.attach_money,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${_priceRange.start.round()}',
                                      style: TextStyle(fontFamily: regular),
                                    ),
                                    Text(
                                      '\$${_priceRange.end.round()}',
                                      style: TextStyle(fontFamily: regular),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 50,
                                  child: RangeSlider(
                                    values: _priceRange,
                                    min: _minPrice,
                                    max: _maxPrice,
                                    divisions: 100,
                                    activeColor: TColors.primary,
                                    inactiveColor: TColors.light,
                                    labels: RangeLabels(
                                      '\$${_priceRange.start.round()}',
                                      '\$${_priceRange.end.round()}',
                                    ),
                                    onChangeStart: (_) {
                                      setState(() {
                                        _isDraggingSlider = true;
                                      });
                                    },
                                    onChangeEnd: (_) {
                                      setState(() {
                                        _isDraggingSlider = false;
                                      });
                                    },
                                    onChanged: (RangeValues values) {
                                      setState(() {
                                        _priceRange =
                                            values; // Update slider position immediately
                                      });
                                      if (_debounce?.isActive ?? false)
                                        _debounce?.cancel();
                                      _debounce = Timer(
                                        const Duration(milliseconds: 300),
                                        () {
                                          _applyFiltersAndSort(); // Apply filters after delay
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: Sizes.spaceBtwItems),
                                // Sort Options
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Sort By',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: semibold,
                                        color: TColors.dark,
                                      ),
                                    ),
                                    Icon(
                                      Icons.sort,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                DropdownButtonFormField<String>(
                                  value: _sortCriteria,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.sm,
                                      ),
                                      borderSide: BorderSide(
                                        color: TColors.light,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: TColors.light,
                                  ),
                                  dropdownColor: TColors.light,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: TColors.dark,
                                  ),
                                  isExpanded: true,
                                  items:
                                      [
                                            'Relevance',
                                            'Name (A-Z)',
                                            'Name (Z-A)',
                                            'Price (Low to High)',
                                            'Price (High to Low)',
                                          ]
                                          .map(
                                            (sort) => DropdownMenuItem(
                                              value: sort,
                                              child: Text(
                                                sort,
                                                style: TextStyle(
                                                  fontFamily: regular,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    setModalState(() => _sortCriteria = value!);
                                    _applyFiltersAndSort();
                                  },
                                ),
                                const SizedBox(height: Sizes.spaceBtwItems),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: TColors.light,
                                        side: BorderSide(color: TColors.light),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            Sizes.sm,
                                          ),
                                        ),
                                      ),
                                      onPressed: _resetFilters,
                                      child: const Text(
                                        'Reset',
                                        style: TextStyle(
                                          color: TColors.dark,
                                          fontFamily: semibold,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: TColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            Sizes.sm,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Apply',
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontFamily: bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Sizes.defaultSpace),
                              ],
                            ),
                          ),
                        ),
                      ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'All Products',
          style: TextStyle(fontSize: 24, fontFamily: bold, color: TColors.dark),
        ),
        backgroundColor: whiteColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter, color: TColors.dark),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Sizes.defaultSpace),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _applyFiltersAndSort();
                },
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(
                    Iconsax.search_favorite,
                    color: TColors.dark,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.sm),
                    borderSide: const BorderSide(
                      color: TColors.light,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.sm),
                    borderSide: const BorderSide(
                      color: TColors.primary,
                      width: 1,
                    ),
                  ),
                  filled: true,
                  fillColor: TColors.light,
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              CustomGridLayout(
                itemCount: _filteredProducts.length,
                itemBuilder: (_, index) => ProductCartVertical(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
