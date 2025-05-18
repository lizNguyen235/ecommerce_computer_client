import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/models/product_model.dart';
import 'package:ecommerce_computer_client/views/product/product_cart_vertical.dart';
import 'package:ecommerce_computer_client/views/shimmer/vertical_product_shimmer.dart';
import 'package:ecommerce_computer_client/widgets/bg_widget.dart';
import 'package:ecommerce_computer_client/widgets/custom_grid_layout.dart';
import 'package:flutter/material.dart';

class CategoryDetail extends StatelessWidget {
  const CategoryDetail({super.key, this.title, this.categoryId});

  final String? title;
  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: title!.text.fontFamily(bold).white.make(),
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Danh sách sản phẩm
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .where('category', isEqualTo: title ?? '')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: TVerticalProductShimmer());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No products found'));
                    }

                    final products = snapshot.data!.docs;

                    return CustomGridLayout(
                      crossAxisCount: context.screenWidth > 1200
                          ? 6
                          : context.screenWidth > 992
                          ? 5
                          : context.screenWidth > 768
                          ? 4
                          : context.screenWidth > 600
                          ? 3
                          : 2,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final productDoc = products[index];
                        final data = productDoc.data() as Map<String, dynamic>? ?? {};
                        final product = ProductModel(
                          id: productDoc.id,
                          price: (data['price'] as num?)?.toDouble() ?? 0.0,
                          thumbnail: data['thumbnail'] ?? '',
                          title: data['name'] ?? 'No Title',
                          stock: data['stock'] ?? 0,
                          description: data['description'] ?? 'No description',
                          brand: data['brand'] ?? 'No Brand',
                          isFeatured: data['isFeatured'] ?? false,
                          category: data['category'] ?? 'No Category',
                        );
                        return ProductCartVertical(
                          product: product,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}