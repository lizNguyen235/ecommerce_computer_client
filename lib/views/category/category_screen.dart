import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/consts/lists.dart';
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
    return GridView.builder(
      shrinkWrap: true,
      itemCount: categoriesImageList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 200,
      ),
      itemBuilder: (context, index) {
        return _buildCategoryCard(index);
      },
    );
  }

  Widget _buildCategoryCard(int index) {
    return GestureDetector(
      onTap: () {
        Get.to(() => CategoryDetail(title: categoriesList[index]));
      },
      child:
          Column(
            children: [
              Image.asset(
                categoriesImageList[index],
                width: 200,
                height: 120,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              categoriesList[index].text
                  .fontFamily(semibold)
                  .align(TextAlign.center)
                  .color(darkFontGrey)
                  .make(),
            ],
          ).box.white.rounded.clip(Clip.antiAlias).outerShadowSm.make(),
    );
  }
}
