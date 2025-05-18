import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/views/category/category_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imgBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: _buildCategoryGrid(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: categories.text.fontFamily(bold).white.make(),
      centerTitle: true,
    );
  }

  Widget _buildCategoryGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No categories found'));
        }

        final categories = snapshot.data!.docs;
        return GridView.builder(
          shrinkWrap: true,
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 200,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            final data = category.data() as Map<String, dynamic>;
            final imageUrl = data['image'] as String;
            final name = data['name'] as String;

            return _buildCategoryCard(imageUrl, name, category.id);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(String imageUrl, String name, String categoryId) {
    return GestureDetector(
      onTap: () {
        Get.to(() => CategoryDetail(title: name, categoryId: categoryId));
      },
      child: Column(
        children: [
          Image.network(
            imageUrl,
            width: 200,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                imgP1, // Hình ảnh dự phòng nếu load imageUrl thất bại
                width: 200,
                height: 120,
                fit: BoxFit.cover,
              );
            },
          ),
          const SizedBox(height: 10),
          name.text
              .fontFamily(semibold)
              .align(TextAlign.center)
              .color(darkFontGrey)
              .make(),
        ],
      ).box.white.rounded.clip(Clip.antiAlias).outerShadowSm.make(),
    );
  }
}