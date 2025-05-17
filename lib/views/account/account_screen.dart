import 'package:ecommerce_computer_client/admin/admin_main_page.dart';
import 'package:ecommerce_computer_client/consts/colors.dart';
import 'package:ecommerce_computer_client/consts/styles.dart';
import 'package:ecommerce_computer_client/core/service/AuthService.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/address/address_screen.dart';
import 'package:ecommerce_computer_client/views/cart/cart_screen.dart';
import 'package:ecommerce_computer_client/views/order/order_screen.dart';
import 'package:ecommerce_computer_client/views/profile/edit_profile_screen.dart';
import 'package:ecommerce_computer_client/views/profile/profile_screen.dart';
import 'package:ecommerce_computer_client/widgets/primary_header_container.dart';
import 'package:ecommerce_computer_client/widgets/setting_menu_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/service/UserService.dart';
import '../login/change_password.dart';
import '../support/support_chat_screen.dart';

class AccountScreen extends StatelessWidget {
  final _auth = AuthService();
  final user = UserService();
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
                    onTap: () => Get.to(() => MyProfileScreen()),
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
                  // SỬ DỤNG FUTUREBUILDER ĐỂ HIỂN THỊ "My Orders" CHO NGƯỜI DÙNG ĐÃ ĐĂNG NHẬP
                  FutureBuilder<String>(
                    future: user.getCurrentUserRole(), // Gọi Future để lấy vai trò người dùng
                    builder: (context, snapshot) {
                      // Trường hợp 1: Đang chờ dữ liệu
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // return SizedBox(height: 50, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                        return SizedBox.shrink(); // Không hiển thị gì trong khi chờ
                      }
                      // Trường hợp 2: Có lỗi khi lấy vai trò (ví dụ: lỗi mạng)
                      else if (snapshot.hasError) {
                        print("Error fetching user role for My Orders: ${snapshot.error}");
                        // Trong trường hợp lỗi, có thể bạn không muốn hiển thị "My Orders"
                        // vì không xác định được trạng thái đăng nhập.
                        return SizedBox.shrink();
                      }
                      // Trường hợp 3: Có dữ liệu vai trò
                      else if (snapshot.hasData) {
                        final userRole = snapshot.data; // userRole có thể là 'guest', 'user', 'admin', etc.

                        // Logic: Chỉ hiển thị "My Orders" nếu người dùng KHÔNG phải là 'guest'
                        if (userRole != null && userRole.toLowerCase() != 'guest') {
                          return SettingMenuTile(
                            icon: Iconsax.bag_tick,
                            title: 'My Orders',
                            subtitle: 'In-progress, completed and cancelled orders',
                            trailing: Icon(Iconsax.arrow_circle_right, size: 26),
                            onTap: () => Get.to(() => OrderScreen()),
                          );
                        } else {
                          // Người dùng là 'guest' hoặc vai trò là null (coi như chưa đăng nhập/guest)
                          // không hiển thị "My Orders"
                          return SizedBox.shrink();
                        }
                      }
                      // Trường hợp 4: Không có dữ liệu vai trò (Future trả về null mà không lỗi)
                      // Coi như người dùng chưa đăng nhập hoặc là guest.
                      else {
                        return SizedBox.shrink();
                      }
                    },
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
                  // SỬ DỤNG FUTUREBUILDER ĐỂ HIỂN THỊ ADMIN PANEL
                  FutureBuilder<String>(
                    future: user.getCurrentUserRole(), // Gọi Future ở đây
                    builder: (context, snapshot) {
                      // Trường hợp 1: Đang chờ dữ liệu
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // return CircularProgressIndicator(); // Hoặc không hiển thị gì cả
                        return SizedBox.shrink(); // Không hiển thị gì trong khi chờ
                      }
                      // Trường hợp 2: Có lỗi
                      else if (snapshot.hasError) {
                        print("Error fetching user role: ${snapshot.error}");
                        // return Text('Error loading role'); // Hoặc không hiển thị gì cả
                        return SizedBox.shrink();
                      }
                      // Trường hợp 3: Có dữ liệu
                      else if (snapshot.hasData) {
                        final userRole = snapshot.data;
                        if (userRole == 'admin') {
                          return SettingMenuTile(
                            icon: Iconsax.shield,
                            title: 'Admin Panel',
                            subtitle: 'Manage products, orders and users',
                            trailing: Icon(
                              Iconsax.arrow_circle_right,
                              size: 26,
                            ),
                            onTap: () {
                              Get.to(
                                () => const AdminMainPage(),
                                transition: Transition.rightToLeft,
                              );
                            },
                          );
                        } else {
                          // Người dùng không phải admin, không hiển thị gì
                          return SizedBox.shrink();
                        }
                      }
                      // Trường hợp 4: Không có dữ liệu (hiếm khi xảy ra nếu Future trả về String hoặc lỗi)
                      else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                  SizedBox(height: Sizes.spaceBtwSections),

                  Text(
                    'App Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: Sizes.spaceBtwItems),
                  SettingMenuTile(
                    icon: Iconsax.support,
                    title: 'Support Center',
                    subtitle: 'Chat with us for any help',
                    trailing: Icon(Iconsax.arrow_circle_right, size: 26),
                    onTap: () {
                      // Handle support center action
                      Get.to(() => const SupportChatPage());
                    },
                  ),
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
