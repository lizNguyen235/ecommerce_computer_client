import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// Điều chỉnh đường dẫn import cho phù hợp
import '../../../../core/service/AuthService.dart';
import '../../../../core/service/UserService.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/sizes.dart';
import '../../../../widgets/appbar.dart'; // Custom AppBar nếu có
import 'edit_profile_screen.dart'; // Màn hình chỉnh sửa hồ sơ

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  Map<String, dynamic>? _userProfileData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        setState(() {
          _errorMessage = "Bạn chưa đăng nhập.";
          _isLoading = false;
        });
        return;
      }

      final profileData = await _userService.getUserProfile(currentUser.uid);
      if (mounted) {
        setState(() {
          _userProfileData = profileData;
          if (_userProfileData == null) {
            _userProfileData = {
              'email': currentUser.email ?? 'N/A',
              'fullName': currentUser.displayName ?? 'Chưa cập nhật',
              'avatarUrl': currentUser.photoURL ?? '',
              'phoneNumber': 'Chưa cập nhật',
              'loyaltyPoints': 0, // Mặc định nếu profile chưa có
            };
          }
          // Đảm bảo loyaltyPoints luôn là số nguyên
          if (_userProfileData!['loyaltyPoints'] == null || _userProfileData!['loyaltyPoints'] is! int) {
            _userProfileData!['loyaltyPoints'] = 0;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Lỗi tải hồ sơ: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditMyProfileScreen()),
    );
    if (result == true || result == null) {
      _loadUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text('Hồ Sơ Của Tôi', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        color: TColors.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: TColors.primary));
    }

    if (_errorMessage != null) {
      return Center( /* ... Error message UI ... */
        child: Padding(
          padding: const EdgeInsets.all(Sizes.defaultSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: TColors.error), textAlign: TextAlign.center),
              const SizedBox(height: Sizes.spaceBtwItems),
              ElevatedButton.icon(
                icon: const Icon(Iconsax.refresh, color: Colors.white),
                label: Text('Thử lại', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
                onPressed: _loadUserProfile,
              )
            ],
          ),
        ),
      );
    }

    if (_userProfileData == null) {
      return Center(
        child: Text('Không thể tải thông tin hồ sơ.', style: Theme.of(context).textTheme.bodyLarge),
      );
    }

    final String fullName = _userProfileData!['fullName'] as String? ?? 'Chưa cập nhật';
    final String email = _userProfileData!['email'] as String? ?? 'N/A';
    final String avatarUrl = _userProfileData!['avatarUrl'] as String? ?? '';
    final String phoneNumber = _userProfileData!['phoneNumber'] as String? ?? 'Chưa cập nhật';
    final int loyaltyPoints = _userProfileData!['loyaltyPoints'] as int? ?? 0; // LẤY ĐIỂM LOYALTY

    return ListView(
      padding: const EdgeInsets.all(Sizes.defaultSpace),
      children: [
        // --- Phần Avatar và Tên ---
        Column( /* ... Avatar, Name, Email, Edit Button ... */
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: TColors.lightContainer,
              backgroundImage: (avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
              child: (avatarUrl.isEmpty)
                  ? const Icon(Iconsax.user_octagon, size: 60, color: TColors.dark)
                  : null,
            ),
            const SizedBox(height: Sizes.spaceBtwItems / 2),
            Text(
              fullName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.spaceBtwSections * 0.8),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.edit, size: Sizes.iconSm, color: Colors.white),
                label: Text('Chỉnh sửa hồ sơ', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: Sizes.sm + 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.buttonRadius)),
                ),
                onPressed: _navigateToEditProfile,
              ),
            ),
          ],
        ),
        const SizedBox(height: Sizes.spaceBtwSections),
        const Divider(thickness: 1, color: TColors.borderPrimary),
        const SizedBox(height: Sizes.spaceBtwItems),

        // --- Chi tiết Hồ sơ ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
          child: Text(
            "Thông tin chi tiết",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: Sizes.spaceBtwItems),

        _buildProfileDetailRow(
          icon: Iconsax.user_octagon,
          title: 'Họ và tên',
          value: fullName,
        ),
        _buildProfileDetailRow(
          icon: Iconsax.direct_right,
          title: 'Email',
          value: email,
        ),
        _buildProfileDetailRow(
          icon: Iconsax.call,
          title: 'Số điện thoại',
          value: phoneNumber,
        ),
        // MỚI: Hiển thị điểm Loyalty
        _buildProfileDetailRow(
          icon: Iconsax.medal_star, // Icon cho điểm
          title: 'Điểm tích lũy',
          value: loyaltyPoints.toString(),
          valueColor: TColors.primary, // Có thể dùng màu khác để nổi bật
        ),

        const SizedBox(height: Sizes.spaceBtwSections),
        const Divider(thickness: 1, color: TColors.borderPrimary),
        const SizedBox(height: Sizes.spaceBtwItems),

      ],
    );
  }

  Widget _buildProfileDetailRow({required IconData icon, required String title, required String value, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.sm + 2, horizontal: Sizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn chỉnh tốt hơn nếu value dài
        children: [
          Icon(icon, size: Sizes.iconMd, color: TColors.primary),
          const SizedBox(width: Sizes.spaceBtwItems),
          Text('$title:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(width: Sizes.sm), // Thêm khoảng cách nhỏ trước khi value
          Expanded(
            child: Text(
              value.isEmpty ? 'Chưa cập nhật' : value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor ?? TColors.textSecondary,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
              // overflow: TextOverflow.ellipsis, // Bỏ ellipsis để có thể xuống dòng
              // maxLines: 2, // Cho phép tối đa 2 dòng
            ),
          ),
        ],
      ),
    );
  }
}