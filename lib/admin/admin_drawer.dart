import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart'; // Giả sử bạn dùng Iconsax
// import '../../utils/colors.dart'; // Import TColors của bạn nếu cần trực tiếp
// Import SettingMenuTile của bạn
import '../widgets/setting_menu_tile.dart'; // <<--- ĐIỀU CHỈNH ĐƯỜNG DẪN NÀY

// Enum để quản lý các trang trong admin (giữ nguyên)
enum AdminSection {
  dashboard,
  productManagement,
  userManagement,
  orderManagement,
  couponManagement,
  customerSupport,
  categoryManagement,
}

class AdminDrawer extends StatelessWidget {
  final AdminSection currentSection;
  final ValueChanged<AdminSection> onSectionSelected;

  const AdminDrawer({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy màu primary từ Theme context để đảm bảo tính nhất quán
    // hoặc bạn có thể dùng TColors.primary trực tiếp nếu SettingMenuTile đã dùng nó
    final Color primaryColor = Theme.of(context).primaryColor;
    // final Color darkColor = TColors.dark; // Nếu SettingMenuTile không tự lấy từ Theme
    // final Color subtitleColor = TColors.darkFontGrey; // Nếu SettingMenuTile không tự lấy từ Theme

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: primaryColor, // Sử dụng màu từ Theme
            ),
            child: const Text( // Giữ nguyên hoặc tùy chỉnh style
              'Admin Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Iconsax.category, // Thay icon nếu muốn
            title: 'Dashboard',
            subtitle: 'Overview and statistics',
            section: AdminSection.dashboard,
            context: context,
          ),
          _buildDrawerItem(
            icon: Iconsax.box,
            title: 'Product Management',
            subtitle: 'Manage products and inventory',
            section: AdminSection.productManagement,
            context: context,
          ),
          _buildDrawerItem(
            icon: Iconsax.card_tick_1,
            title: 'Category Management',
            subtitle: 'Manage Categories',
            section: AdminSection.categoryManagement,
            context: context,
          ),
          _buildDrawerItem(
            icon: Iconsax.profile_2user,
            title: 'User Management',
            subtitle: 'View and manage users',
            section: AdminSection.userManagement,
            context: context,
          ),
          _buildDrawerItem(
            icon: Iconsax.shopping_cart,
            title: 'Order Management',
            subtitle: 'Process and track orders',
            section: AdminSection.orderManagement,
            context: context,
          ),
          _buildDrawerItem(
            icon: Iconsax.ticket_discount,
            title: 'Coupon Management',
            subtitle: 'Create and manage coupons',
            section: AdminSection.couponManagement,
            context: context,
          ),
          _buildDrawerItem(
            icon: Iconsax.message_question,
            title: 'Customer Support',
            subtitle: 'Respond to customer inquiries',
            section: AdminSection.customerSupport,
            context: context,
          ),
          const Divider(height: 20, thickness: 1), // Thêm khoảng cách và độ dày cho Divider
          // Logout Tile (có thể dùng SettingMenuTile hoặc ListTile tùy bạn)
          SettingMenuTile(
            icon: Iconsax.logout,
            title: 'Logout',
            subtitle: 'Sign out from admin panel',
            onTap: () {
              // TODO: Implement logout logic
              Navigator.of(context).pop(); // Đóng drawer
              // Ví dụ: Navigator.of(context).pushReplacementNamed('/login');
              // Hoặc gọi authService.signOut();
            },
            // Trailing có thể là null hoặc một Icon(Iconsax.arrow_right_3) nếu muốn
          ),
        ],
      ),
    );
  }

  // Hàm helper để tạo các item sử dụng SettingMenuTile
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required AdminSection section,
    required BuildContext context,
  }) {
    final bool isSelected = currentSection == section;
    final Color primaryColor = Theme.of(context).primaryColor; // Lấy màu từ theme

    // Tùy chỉnh style cho SettingMenuTile khi được chọn
    // SettingMenuTile của bạn đã có style cố định,
    // Nếu muốn thay đổi màu sắc khi chọn, bạn cần sửa SettingMenuTile
    // hoặc truyền thêm tham số isSelected vào SettingMenuTile.

    // Cách 1: SettingMenuTile không có tham số isSelected (như hiện tại)
    // Thì màu sắc sẽ luôn cố định như trong SettingMenuTile.
    // Bạn có thể bọc nó trong một Container để thay đổi nền nếu được chọn.
    return Container(
      color: isSelected ? primaryColor.withOpacity(0.1) : null, // Màu nền khi được chọn
      child: SettingMenuTile(
        icon: icon,
        // Nếu SettingMenuTile dùng TColors.primary cố định cho icon,
        // và bạn muốn icon đổi màu khi chọn, bạn cần sửa SettingMenuTile
        // hoặc truyền màu icon vào đây.
        // iconColor: isSelected ? primaryColor : TColors.primary, // Ví dụ nếu SettingMenuTile có prop iconColor
        title: title,
        // titleStyle: TextStyle( // Ví dụ nếu SettingMenuTile có prop titleStyle
        //   fontSize: 16,
        //   fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        //   color: isSelected ? primaryColor : TColors.dark,
        // ),
        subtitle: subtitle,
        // subtitleStyle: ...
        trailing: isSelected
            ? Icon(Iconsax.arrow_right_3, color: primaryColor, size: 20)
            : null, // Hiển thị mũi tên khi được chọn
        onTap: () {
          onSectionSelected(section);
          Navigator.of(context).pop(); // Đóng drawer sau khi chọn
        },
      ),
    );

    // Cách 2: Nếu bạn sửa SettingMenuTile để nhận isSelected và các style tùy chỉnh
    /*
    return SettingMenuTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: () {
        onSectionSelected(section);
        Navigator.of(context).pop();
      },
      isSelected: isSelected, // Thêm prop này vào SettingMenuTile
      // Và trong SettingMenuTile, bạn sẽ dùng isSelected để điều chỉnh màu sắc
      // ví dụ: iconColor: isSelected ? TColors.white : TColors.primary
      //        backgroundColor: isSelected ? TColors.primary : null
      //        titleColor: isSelected ? TColors.white : TColors.dark
    );
    */
  }
}