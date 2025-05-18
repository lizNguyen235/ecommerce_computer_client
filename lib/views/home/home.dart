import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/controller/cart_controller.dart';
import 'package:ecommerce_computer_client/controller/home_controller.dart';
import 'package:ecommerce_computer_client/views/cart/cart_screen.dart';
import 'package:ecommerce_computer_client/views/category/category_screen.dart';
import 'package:ecommerce_computer_client/views/home/home_screen.dart';
import 'package:ecommerce_computer_client/views/account/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo HomeController và CartController
    var controller = Get.put(HomeController());
    var cartController = Get.put(CartController()); // Không cần userId

    var navbarItem = [
      BottomNavigationBarItem(icon: Icon(Iconsax.home), label: "Home"),
      BottomNavigationBarItem(
        icon: Icon(Iconsax.category),
        label: "Categories",
      ),
      BottomNavigationBarItem(
        icon: Obx(() => Stack(
          children: [
            Icon(Iconsax.shopping_cart),
            if (cartController.cartCount.value > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: redColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      cartController.cartCount.value.toString(),
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 10,
                        fontFamily: bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        )),
        label: "Cart",
      ),
      BottomNavigationBarItem(icon: Icon(Iconsax.user), label: "Account"),
    ];

    var navBody = [
      HomeScreen(),
      CategoryScreen(),
      CartScreen(),
      AccountScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Obx(
                  () => IndexedStack(
                index: controller.currentNavIndex.value,
                children: navBody,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          currentIndex: controller.currentNavIndex.value,
          selectedItemColor: redColor,
          selectedLabelStyle: TextStyle(fontFamily: semibold),
          type: BottomNavigationBarType.fixed,
          backgroundColor: whiteColor,
          items: navbarItem,
          onTap: (value) {
            controller.currentNavIndex.value = value;
            controller.update();
          },
        ),
      ),
    );
  }
}