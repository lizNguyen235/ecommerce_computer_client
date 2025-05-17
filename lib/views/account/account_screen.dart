import 'package:ecommerce_computer_client/admin/admin_main_page.dart';
import 'package:ecommerce_computer_client/consts/colors.dart'; // Đảm bảo TColors và whiteColor được định nghĩa ở đây
import 'package:ecommerce_computer_client/consts/styles.dart'; // Đảm bảo semibold được định nghĩa ở đây
import 'package:ecommerce_computer_client/core/service/AuthService.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/address/address_screen.dart';
import 'package:ecommerce_computer_client/views/cart/cart_screen.dart';
import 'package:ecommerce_computer_client/views/order/order_screen.dart';
import 'package:ecommerce_computer_client/views/profile/profile_screen.dart'; // MyProfileScreen
import 'package:ecommerce_computer_client/widgets/primary_header_container.dart';
import 'package:ecommerce_computer_client/widgets/setting_menu_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Vẫn sử dụng GetX cho navigation
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../core/service/UserService.dart';
import '../../utils/colors.dart';
import '../login/change_password.dart';
import '../support/support_chat_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  fb_auth.User? _currentUser;
  Map<String, dynamic>? _userProfileData;
  bool _isLoadingProfile = true; // Bắt đầu với true để hiển thị loading
  String? _currentRole; // Lưu trữ vai trò hiện tại để dùng cho FutureBuilder của Admin/MyOrders

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _authService.authStateChanges.listen((fb_auth.User? user) {
      if (!mounted) return;
      setState(() {
        _currentUser = user;
      });
      if (user != null) {
        _loadUserProfile(user.uid);
        _loadUserRole(); // Tải lại vai trò khi auth state thay đổi
      } else {
        setState(() {
          _userProfileData = null;
          _currentRole = 'guest'; // Hoặc null nếu bạn muốn FutureBuilder chạy lại
          _isLoadingProfile = false;
        });
      }
    });
  }

  Future<void> _initializeUserData() async {
    if (!mounted) return;
    final initialUser = _authService.getCurrentUser();
    setState(() {
      _currentUser = initialUser;
    });
    if (initialUser != null) {
      await _loadUserProfile(initialUser.uid);
      await _loadUserRole();
    } else {
      setState(() {
        _isLoadingProfile = false;
        _currentRole = 'guest';
      });
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    if (!mounted) return;
    setState(() => _isLoadingProfile = true);
    try {
      final profileData = await _userService.getUserProfile(uid);
      if (mounted) {
        setState(() {
          _userProfileData = profileData;
        });
      }
    } catch (e) {
      print("AccountScreen: Error fetching user profile: $e");
      if (mounted) {
        // Có thể hiển thị SnackBar lỗi ở đây nếu muốn
        setState(() {
          _userProfileData = null; // Reset nếu có lỗi
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _loadUserRole() async {
    if (!mounted) return;
    try {
      final role = await _userService.getCurrentUserRole();
      if (mounted) {
        setState(() {
          _currentRole = role;
        });
      }
    } catch (e) {
      print("AccountScreen: Error fetching user role: $e");
      if (mounted) {
        setState(() {
          _currentRole = 'guest'; // Mặc định nếu lỗi
        });
      }
    }
  }

  void _refreshDataAfterNavigation() {
    if (_currentUser != null) {
      _loadUserProfile(_currentUser!.uid);
      _loadUserRole(); // Tải lại cả vai trò
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget userProfileCardContent;

    if (_currentUser == null && !_isLoadingProfile) {
      userProfileCardContent = _buildGuestProfileTile(context);
    } else if (_isLoadingProfile || (_currentUser != null && _userProfileData == null && _authService.getCurrentUser() != null) ) {
      userProfileCardContent = _buildLoadingProfileTile(context, _currentUser);
    } else if (_currentUser != null && _userProfileData != null) {
      String displayName = _userProfileData!['fullName'] ?? _currentUser!.displayName ?? 'Người dùng';
      String? avatarUrl = _userProfileData!['avatarUrl'];
      if ((avatarUrl == null || avatarUrl.isEmpty) && _currentUser!.photoURL != null && _currentUser!.photoURL!.isNotEmpty) {
        avatarUrl = _currentUser!.photoURL;
      }

      userProfileCardContent = _buildUserProfileTile(
        context: context,
        avatarUrl: avatarUrl,
        displayName: displayName,
        email: _currentUser!.email ?? 'N/A',
        onEditPressed: () async {
          final result = await Get.to(() => const MyProfileScreen());
          if (result == true || result == null) { // MyProfileScreen/EditProfileScreen có thể trả về true nếu có thay đổi
            _refreshDataAfterNavigation();
          }
        },
      );
    } else {
      userProfileCardContent = _buildGuestProfileTile(context);
    }

    return Scaffold(
      backgroundColor: TColors.primaryBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  AppBar(
                    title: const Text(
                      'Tài Khoản',
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
                  const SizedBox(height: Sizes.spaceBtwItems),
                  userProfileCardContent,
                  const SizedBox(height: Sizes.spaceBtwSections),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Sizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cài đặt tài khoản',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),

                  SettingMenuTile(
                    icon: Iconsax.safe_home,
                    title: 'Địa chỉ của tôi',
                    subtitle: 'Thiết lập địa chỉ giao hàng',
                    trailing: const Icon(Iconsax.arrow_circle_right, size: 26),
                    onTap: () => Get.to(() => AddressScreen()),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.shopping_cart,
                    title: 'Giỏ hàng của tôi',
                    subtitle: 'Thêm, xóa sản phẩm và thanh toán',
                    trailing: const Icon(Iconsax.arrow_circle_right, size: 26),
                    onTap: () => Get.to(() => const CartScreen()),
                  ),
                  // Sử dụng _currentRole đã được load từ initState hoặc authStateChanges
                  if (_currentRole != null && _currentRole!.toLowerCase() != 'guest')
                    SettingMenuTile(
                      icon: Iconsax.bag_tick,
                      title: 'Đơn hàng của tôi',
                      subtitle: 'Đơn hàng đang xử lý, đã hoàn thành, đã hủy',
                      trailing: const Icon(Iconsax.arrow_circle_right, size: 26),
                      onTap: () => Get.to(() => OrderScreen()),
                    )
                  else if (_currentRole == null && _currentUser != null) // Đang chờ load role, nhưng đã đăng nhập
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(height: 20, child: LinearProgressIndicator(color: TColors.primary.withOpacity(0.5), backgroundColor: TColors.light)),
                    )
                  else
                    const SizedBox.shrink(),


                  SettingMenuTile(
                    icon: Iconsax.discount_shape,
                    title: 'Phiếu giảm giá',
                    subtitle: 'Danh sách các phiếu giảm giá bạn có',
                    trailing: const Icon(Iconsax.arrow_circle_right, size: 26),
                    onTap: () {/* TODO: Navigate to Coupons Screen */},
                  ),
                  SettingMenuTile(
                    icon: Iconsax.bank,
                    title: 'Tài khoản ngân hàng',
                    subtitle: 'Rút tiền về tài khoản ngân hàng đã đăng ký',
                    trailing: const Icon(Iconsax.arrow_circle_right, size: 26),
                    onTap: () {/* TODO: Navigate to Bank Accounts Screen */},
                  ),
                  SettingMenuTile(
                    icon: Iconsax.lock,
                    title: 'Đổi mật khẩu',
                    subtitle: 'Cập nhật mật khẩu của bạn',
                    trailing: const Icon(Iconsax.arrow_circle_right, size: 26),
                    onTap: () => Get.to(() => ChangePasswordPage()),
                  ),
                  // Sử dụng _currentRole đã được load
                  if (_currentRole == 'admin')
                    SettingMenuTile(
                      icon: Iconsax.shield_tick,
                      title: 'Bảng điều khiển Admin',
                      subtitle: 'Quản lý sản phẩm, đơn hàng và người dùng',
                      trailing: const Icon(Iconsax.arrow_circle_right, size: 26),
                      onTap: () => Get.to(() => const AdminMainPage(), transition: Transition.rightToLeft),
                    )
                  else if (_currentRole == null && _currentUser != null) // Đang chờ load role
                    const SizedBox.shrink() // Hoặc LinearProgressIndicator nếu muốn
                  else
                    const SizedBox.shrink(),


                  const SizedBox(height: Sizes.spaceBtwSections),
                  const Text('Cài đặt ứng dụng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: Sizes.spaceBtwItems),

                  SettingMenuTile(
                    icon: Iconsax.support,
                    title: 'Trung tâm hỗ trợ',
                    subtitle: 'Chat với chúng tôi để được giúp đỡ',
                    trailing: const Icon(Iconsax.arrow_circle_right, size: 26),
                    onTap: () => Get.to(() => const SupportChatPage()),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.language_circle,
                    title: 'Ngôn ngữ',
                    subtitle: 'Chọn ngôn ngữ ưa thích của bạn',
                    trailing: const Icon(Iconsax.arrow_circle_right, size: 26),
                    onTap: () {/* TODO: Navigate to Language Settings */},
                  ),
                  SettingMenuTile(
                    icon: Iconsax.notification,
                    title: 'Thông báo',
                    subtitle: 'Thiết lập các loại thông báo bạn muốn',
                    trailing: Switch(value: false, onChanged: (value) {}, activeColor: TColors.primary),
                  ),
                  SettingMenuTile(
                    icon: Iconsax.moon,
                    title: 'Chủ đề',
                    subtitle: 'Sáng, Tối và Mặc định hệ thống',
                    trailing: Switch(value: Get.isDarkMode, onChanged: (value) {
                      Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    }, activeColor: TColors.primary),
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final confirmLogout = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Xác nhận đăng xuất'),
                            content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                            actions: [
                              TextButton(onPressed: () => Get.back(result: false), child: const Text('Hủy')),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Đăng xuất', style: TextStyle(color: TColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirmLogout == true) {
                          await _authService.signOut();
                          // Không cần Get.offAllNamed nếu StreamBuilder trong initState tự động xử lý
                          // việc build lại UI khi _currentUser thành null.
                          // Get.offAllNamed('/Home'); // Bạn có thể giữ lại nếu muốn clear navigation stack
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: Sizes.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.cardRadiusMd)),
                        side: const BorderSide(color: TColors.error, width: 1.5),
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(color: TColors.error, fontSize: 16, fontFamily: semibold),
                      ),
                    ),
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections * 1.5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingProfileTile(BuildContext context, fb_auth.User? authUser) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.md, vertical: Sizes.sm / 2),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: (authUser?.photoURL != null && authUser!.photoURL!.isNotEmpty)
            ? Image.network(authUser.photoURL!, width: 60, height: 60, fit: BoxFit.cover,
            errorBuilder: (_,__,___) => Image.asset('assets/images/profile_image.png', width: 60, height: 60, fit: BoxFit.cover))
            : Image.asset('assets/images/profile_image.png', width: 60, height: 60, fit: BoxFit.cover),
      ),
      title: Text(
        authUser?.displayName ?? 'Đang tải...',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      subtitle: Text(
        authUser?.email ?? '...',
        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontFamily: semibold),
      ),
      trailing: const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
    );
  }

  Widget _buildGuestProfileTile(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.md, vertical: Sizes.sm / 2),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.asset('assets/images/profile_image.png', width: 60, height: 60, fit: BoxFit.cover),
      ),
      title: const Text('Khách', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
      subtitle: Text('Vui lòng đăng nhập', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontFamily: semibold)),
      trailing: IconButton(
        icon: const Icon(Iconsax.login, color: Colors.white),
        tooltip: 'Đăng nhập',
        onPressed: () => Get.offAllNamed('/Login'), // Điều hướng đến trang Login
      ),
      onTap: () => Get.offAllNamed('/Login'), // Điều hướng đến trang Login
    );
  }

  Widget _buildUserProfileTile({
    required BuildContext context,
    required String? avatarUrl,
    required String displayName,
    required String email,
    VoidCallback? onEditPressed,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.md, vertical: Sizes.sm / 2),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: (avatarUrl != null && avatarUrl.isNotEmpty)
            ? Image.network(
          avatarUrl, width: 60, height: 60, fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) =>
          progress == null ? child : Container(width: 60, height: 60, color: Colors.grey.shade700, child: const Center(child: Icon(Iconsax.user, color: Colors.white54, size: 30))),
          errorBuilder: (ctx, error, stackTrace) =>
              Image.asset('assets/images/profile_image.png', width: 60, height: 60, fit: BoxFit.cover),
        )
            : Image.asset('assets/images/profile_image.png', width: 60, height: 60, fit: BoxFit.cover),
      ),
      title: Text(
        displayName,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        maxLines: 1, overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        email,
        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontFamily: semibold),
        maxLines: 1, overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Iconsax.edit, color: Colors.white, size: 26),
        tooltip: 'Xem & Chỉnh sửa hồ sơ',
        onPressed: onEditPressed, // Sử dụng callback đã truyền
      ),
      onTap: onEditPressed, // Sử dụng callback đã truyền
    );
  }
}