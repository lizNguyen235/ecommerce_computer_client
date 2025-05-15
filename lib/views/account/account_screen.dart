import 'package:ecommerce_computer_client/consts/colors.dart';
import 'package:ecommerce_computer_client/consts/styles.dart';
import 'package:ecommerce_computer_client/core/service/AuthService.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/address/address_screen.dart';
import 'package:ecommerce_computer_client/views/cart/cart_screen.dart';
import 'package:ecommerce_computer_client/views/order/order_screen.dart';
import 'package:ecommerce_computer_client/views/profile/profile_screen.dart';
import 'package:ecommerce_computer_client/widgets/primary_header_container.dart';
import 'package:ecommerce_computer_client/widgets/setting_menu_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../login/change_password.dart';

class AccountScreen extends StatelessWidget {
  final  _auth = AuthService();
  AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// - Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  AppBar(
                    title: Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),

                  /// - User Profile card
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        'assets/images/profile_image.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: const Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'johndoe123@gmail.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        fontFamily: semibold,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Iconsax.edit, color: Colors.white),
                      onPressed: () {
                        // Handle edit profile action
                      },
                    ),
                    onTap: () => Get.to(() => ProfileScreen()),
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections),
                ],
              ),
            ),

            /// - Body
            Padding(
              padding: EdgeInsets.all(Sizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: Sizes.spaceBtwItems),

                  /// - Settings Menu
                  SettingMenuTile(
                    icon: Iconsax.safe_home,
                    title: 'My Addresses',
                    subtitle: 'Set shopping delivery address',
                    trailing: Icon(Iconsax.arrow_circle_right, size: 26),
                    onTap: () => Get.to(() => AddressScreen()),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.shopping_cart,
                    title: 'My Cart',
                    subtitle: 'Add, remove products and move to checkout',
                    trailing: Icon(Iconsax.arrow_circle_right, size: 26),
                    onTap: () => Get.to(() => CartScreen()),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.bag_tick,
                    title: 'My Orders',
                    subtitle: 'In-progress, completed and cancelled orders',
                    trailing: Icon(Iconsax.arrow_circle_right, size: 26),
                    onTap: () => Get.to(() => OrderScreen()),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.discount_shape,
                    title: 'My Coupons',
                    subtitle: 'List of all the discount coupons you have',
                    trailing: Icon(Iconsax.arrow_circle_right, size: 26),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.bank,
                    title: 'Bank Accounts',
                    subtitle: 'Withdraw balance to registered bank accounts',
                    trailing: Icon(Iconsax.arrow_circle_right, size: 26),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.lock,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    trailing: Icon(Iconsax.arrow_circle_right, size: 26),
                    onTap: () {
                      // Handle change password action
                      Get.to(() => ChangePasswordPage());
                    },
                  ),
                  SizedBox(height: Sizes.spaceBtwSections),

                  Text(
                    'App Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: Sizes.spaceBtwItems),
                  SettingMenuTile(
                    icon: Iconsax.language_circle,
                    title: 'Language',
                    subtitle: 'Select your preferred language',
                    trailing: Icon(Iconsax.arrow_circle_right, size: 26),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.notification,
                    title: 'Notifications',
                    subtitle: 'Set any kind of notifications you want',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.moon,
                    title: 'Theme',
                    subtitle: 'Light, Dark and System default',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),
                  SizedBox(height: Sizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _auth.signOut();
                        Get.offAllNamed('/Home');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: Sizes.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.cardRadiusMd,
                          ),
                        ),
                        side: BorderSide(color: Colors.red, width: 1.5),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontFamily: semibold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Sizes.spaceBtwSections * 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
