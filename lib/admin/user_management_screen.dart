import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// Điều chỉnh đường dẫn import cho phù hợp với cấu trúc dự án của bạn
import '../../core/service/UserService.dart'; // Giả sử UserService ở thư mục services
import '../../utils/colors.dart';   // Giả sử TColors ở utils/constants
import '../../utils/sizes.dart';
import '../core/service/AuthService.dart';    // Giả sử Sizes ở utils/constants

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  String? _selectedRoleDialog; // Dùng cho Dropdown trong dialog chỉnh sửa vai trò

  // Hàm để lấy người dùng hiện tại (admin) để tránh admin tự ban mình hoặc tự thay đổi vai trò của mình
  // Bạn cần có cách lấy UID của admin đang đăng nhập.
  // Ví dụ, nếu AuthService có getCurrentUser(), bạn có thể dùng nó.
  // Vì mục đích minh họa, ta sẽ giả sử có một biến `currentAdminUid`
  // Trong thực tế, bạn nên lấy nó từ AuthService hoặc Provider.
  String? get currentAdminUid {
    return _authService.getCurrentUser()?.uid; // Nếu _auth là public hoặc có getter
    // Tạm thời hardcode hoặc để null nếu bạn chưa có cách lấy
    // Nếu AuthService().getCurrentUser() có sẵn và trả về User? thì:
    // return AuthService().getCurrentUser()?.uid;
    // Vì _auth trong UserService là private, ta cần một cách khác
    // Giả sử bạn có một instance của AuthService ở đây hoặc thông qua Provider
    // For now, we'll assume it's hard to get here without modifying AuthService visibility or passing it
    return null; // Hoặc lấy UID của admin bằng cách nào đó
  }

  // TextEditingControllers cho các dialog chỉnh sửa
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _addressController.dispose();
    _fullNameController.dispose();
    super.dispose();

  }


  @override
  Widget build(BuildContext context) {
    final String? adminUid = currentAdminUid;

    return Scaffold(
      // AppBar đã được quản lý bởi AdminMainPage
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: TColors.primary));
          }
          if (snapshot.hasError) {
            print("UserManagementScreen Error: ${snapshot.error}");
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}', style: const TextStyle(color: TColors.error)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không tìm thấy người dùng nào.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(Sizes.md),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final bool isCurrentUserTheAdminViewing = (adminUid != null && user['uid'] == adminUid);
              return _buildUserCard(context, user, isCurrentUserTheAdminViewing);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> userData, bool isCurrentUserTheAdminViewing) {
    final String uid = userData['uid'] ?? 'N/A';
    final String email = userData['email'] ?? 'Không có email';
    final String fullName = userData['fullName'] ?? 'Chưa có tên';
    final String role = (userData['role'] as String?)?.capitalize() ?? 'Customer';
    final bool isBanned = userData['isBanned'] as bool? ?? false;
    final String avatarUrl = userData['avatarUrl'] as String? ?? '';
    final String phoneNumber = userData['phoneNumber'] as String? ?? 'Chưa có SĐT';

    // Lấy và chuyển đổi danh sách địa chỉ một cách an toàn
    final List<dynamic> addressesDynamic = userData['shippingAddress'] as List<dynamic>? ?? [];
    final List<String> shippingAddresses = addressesDynamic.map((e) => e.toString()).toList();


    return Card(
      margin: const EdgeInsets.symmetric(vertical: Sizes.sm),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.cardRadiusMd)),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Căn chỉnh tốt hơn khi thông tin nhiều dòng
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: TColors.lightContainer,
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isEmpty
                      ? Icon(Iconsax.user, color: TColors.primary, size: 25)
                      : null,
                ),
                const SizedBox(width: Sizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Sizes.xs),
                      Row(
                        children: [
                          Icon(Iconsax.call, size: Sizes.iconSm, color: TColors.dark),
                          const SizedBox(width: Sizes.sm / 2),
                          Expanded(
                            child: Text(
                              phoneNumber,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Chỉ hiển thị nút sửa SĐT nếu đây không phải là admin đang xem
                          if (!isCurrentUserTheAdminViewing)
                            SizedBox(
                              height: 24, width: 24, // Giảm kích thước vùng chạm
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Iconsax.edit_2, size: Sizes.iconSm, color: TColors.primary),
                                tooltip: 'Sửa SĐT',
                                onPressed: () => _showEditPhoneNumberDialog(context, uid, fullName, userData['phoneNumber'] ?? ''),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    isBanned ? 'Banned' : 'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Sizes.fontSizeSm * 0.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: isBanned ? TColors.error : TColors.success,
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.sm, vertical: Sizes.xs / 2),
                ),
              ],
            ),
            const SizedBox(height: Sizes.sm),
            Row(
              children: [
                Text('Vai trò: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TColors.dark)),
                Text(role, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: TColors.primary)),
              ],
            ),
            const SizedBox(height: Sizes.sm),

            // --- Phần hiển thị và quản lý địa chỉ ---
            _buildAddressesSection(context, uid, fullName, shippingAddresses, isCurrentUserTheAdminViewing),
            // --- Hết phần địa chỉ ---

            const Divider(height: Sizes.spaceBtwItems, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isCurrentUserTheAdminViewing)
                  TextButton.icon(
                    icon: Icon(
                      isBanned ? Iconsax.unlock : Iconsax.forbidden_2,
                      color: isBanned ? TColors.success : TColors.warning,
                      size: Sizes.iconMd,
                    ),
                    label: Text(
                      isBanned ? 'Unban' : 'Ban',
                      style: TextStyle(color: isBanned ? TColors.success : TColors.warning),
                    ),
                    onPressed: () => _confirmToggleBanStatus(context, uid, fullName, isBanned),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('(You)', style: TextStyle(color: TColors.primary, fontStyle: FontStyle.italic)),
                  ),
                const SizedBox(width: Sizes.sm),
                if (!isCurrentUserTheAdminViewing || role != "Admin") // Admin không thể tự sửa vai trò của mình (nếu là admin duy nhất)
                  TextButton.icon(
                    icon: const Icon(Iconsax.edit, size: Sizes.iconMd, color: TColors.primary),
                    label: const Text('Sửa vai trò', style: TextStyle(color: TColors.primary)),
                    onPressed: () => _showEditRoleDialog(context, uid, fullName, userData['role'] ?? 'customer'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesSection(BuildContext context, String uid, String userName, List<String> addresses, bool isCurrentUserTheAdminViewing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Địa chỉ giao hàng (${addresses.length}):',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            // Chỉ hiển thị nút thêm địa chỉ nếu đây không phải là admin đang xem
            if (!isCurrentUserTheAdminViewing)
              IconButton(
                icon: const Icon(Iconsax.add_square, color: TColors.primary, size: Sizes.iconMd),
                tooltip: 'Thêm địa chỉ mới',
                onPressed: () => _showAddEditAddressDialog(context, uid, userName), // Không có oldAddress nghĩa là thêm mới
              ),
          ],
        ),
        const SizedBox(height: Sizes.sm / 2),
        if (addresses.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: Sizes.sm, bottom: Sizes.sm),
            child: Text('Chưa có địa chỉ nào.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TColors.textSecondary)),
          )
        else
          ListView.builder(
            shrinkWrap: true, // Quan trọng khi lồng ListView
            physics: const NeverScrollableScrollPhysics(), // Quan trọng khi lồng ListView
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.sm / 2, vertical: 0),
                leading: Icon(Iconsax.location, size: Sizes.iconMd, color: TColors.dark),
                title: Text(address, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                // Chỉ hiển thị nút sửa/xóa nếu đây không phải là admin đang xem
                trailing: isCurrentUserTheAdminViewing ? null : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Iconsax.edit_2, size: Sizes.iconSm, color: TColors.primary),
                      tooltip: 'Sửa địa chỉ',
                      onPressed: () => _showAddEditAddressDialog(context, uid, userName, oldAddress: address),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.trash, size: Sizes.iconSm, color: TColors.error),
                      tooltip: 'Xóa địa chỉ',
                      onPressed: () => _confirmRemoveAddress(context, uid, userName, address),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: Sizes.sm), // Thêm khoảng đệm dưới cùng cho section địa chỉ
      ],
    );
  }

  // --- Dialog chỉnh sửa số điện thoại ---
  Future<void> _showEditPhoneNumberDialog(BuildContext context, String uid, String userName, String currentPhoneNumber) async {
    _phoneNumberController.text = currentPhoneNumber;
    final String? newPhoneNumber = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Sửa SĐT cho "$userName"'),
          content: TextField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại mới',
              hintText: 'Nhập số điện thoại',
              prefixIcon: Icon(Iconsax.call),
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton( // Sử dụng ElevatedButton cho hành động chính
              child: const Text('Lưu'),
              onPressed: () {
                if (_phoneNumberController.text.trim().isNotEmpty) {
                  Navigator.of(dialogContext).pop(_phoneNumberController.text.trim());
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Số điện thoại không được để trống'), backgroundColor: TColors.warning),
                  );
                }
              },
            ),
          ],
        );
      },
    );

    if (newPhoneNumber != null && newPhoneNumber != currentPhoneNumber) {
      try {
        await _userService.updateUserPhoneNumber(uid, newPhoneNumber);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật SĐT cho "$userName".'), backgroundColor: TColors.success),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật SĐT: $e'), backgroundColor: TColors.error),
        );
      }
    }
  }

  // --- Dialog thêm/sửa địa chỉ ---
  Future<void> _showAddEditAddressDialog(BuildContext context, String uid, String userName, {String? oldAddress}) async {
    _addressController.text = oldAddress ?? ''; // Nếu là sửa thì điền địa chỉ cũ
    final bool isEditing = oldAddress != null;

    final String? newOrEditedAddress = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Sửa địa chỉ cho "$userName"' : 'Thêm địa chỉ mới cho "$userName"'),
          content: TextField(
            controller: _addressController,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              labelText: 'Địa chỉ',
              hintText: 'Nhập địa chỉ chi tiết (số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: Text(isEditing ? 'Lưu thay đổi' : 'Thêm mới'),
              onPressed: () {
                if (_addressController.text.trim().isNotEmpty) {
                  Navigator.of(dialogContext).pop(_addressController.text.trim());
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Địa chỉ không được để trống'), backgroundColor: TColors.warning),
                  );
                }
              },
            ),
          ],
        );
      },
    );

    if (newOrEditedAddress != null) {
      try {
        if (isEditing) {
          // Chỉ gọi API nếu địa chỉ mới khác địa chỉ cũ
          if (newOrEditedAddress != oldAddress) {
            await _userService.editShippingAddress(uid, oldAddress!, newOrEditedAddress);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã sửa địa chỉ cho "$userName".'), backgroundColor: TColors.success),
            );
          } else {
            // Không có gì thay đổi
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Địa chỉ không thay đổi.'), backgroundColor: Colors.grey),
            );
          }
        } else { // Thêm mới
          await _userService.addShippingAddress(uid, newOrEditedAddress);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã thêm địa chỉ mới cho "$userName".'), backgroundColor: TColors.success),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi ${isEditing ? "sửa" : "thêm"} địa chỉ: $e'), backgroundColor: TColors.error),
        );
      }
    }
  }

  // --- Dialog xác nhận xóa địa chỉ ---
  Future<void> _confirmRemoveAddress(BuildContext context, String uid, String userName, String addressToRemove) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa địa chỉ'),
          content: Text('Bạn có chắc muốn xóa địa chỉ:\n"$addressToRemove"\ncủa người dùng "$userName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: TColors.error),
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _userService.removeShippingAddress(uid, addressToRemove);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa địa chỉ của "$userName".'), backgroundColor: TColors.success),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa địa chỉ: $e'), backgroundColor: TColors.error),
        );
      }
    }
  }

  // --- Các dialog ban/unban và sửa vai trò giữ nguyên ---
  Future<void> _confirmToggleBanStatus(BuildContext context, String uid, String userName, bool isCurrentlyBanned) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(isCurrentlyBanned ? 'Bỏ cấm người dùng?' : 'Cấm người dùng?'),
          content: Text('Bạn có chắc muốn ${isCurrentlyBanned ? "bỏ cấm" : "cấm"} người dùng "$userName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: isCurrentlyBanned ? TColors.success : TColors.error),
              child: Text(isCurrentlyBanned ? 'Bỏ cấm' : 'Cấm', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _userService.toggleUserBanStatus(uid, isCurrentlyBanned);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã ${isCurrentlyBanned ? "bỏ cấm" : "cấm"} người dùng "$userName".'),
            backgroundColor: TColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi ${isCurrentlyBanned ? "bỏ cấm" : "cấm"} người dùng: $e'),
            backgroundColor: TColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showEditRoleDialog(BuildContext context, String uid, String userName, String currentRole) async {
    _selectedRoleDialog = currentRole;
    final List<String> roles = ['customer', 'admin'];

    final String? newRole = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text('Chỉnh sửa vai trò cho "$userName"'),
                content: DropdownButtonFormField<String>(
                  value: _selectedRoleDialog,
                  decoration: const InputDecoration(
                    labelText: 'Chọn vai trò mới',
                    border: OutlineInputBorder(),
                  ),
                  items: roles.map((String roleValue) {
                    return DropdownMenuItem<String>(
                      value: roleValue,
                      child: Text(roleValue.capitalize()),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setDialogState(() {
                      _selectedRoleDialog = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Vui lòng chọn một vai trò' : null,
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Hủy'),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                  ElevatedButton(
                    child: const Text('Lưu'),
                    onPressed: () {
                      if (_selectedRoleDialog != null) {
                        Navigator.of(dialogContext).pop(_selectedRoleDialog);
                      }
                    },
                  ),
                ],
              );
            }
        );
      },
    );

    if (newRole != null && newRole != currentRole) {
      try {
        await _userService.updateUserRole(uid, newRole);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật vai trò của "$userName" thành "${newRole.capitalize()}".'),
            backgroundColor: TColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật vai trò: $e'),
            backgroundColor: TColors.error,
          ),
        );
      }
    } else if (newRole == currentRole) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vai trò không thay đổi.'), backgroundColor: Colors.grey),
      );
    }
  }
}

// Tiện ích mở rộng String (giữ nguyên)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return "";
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}