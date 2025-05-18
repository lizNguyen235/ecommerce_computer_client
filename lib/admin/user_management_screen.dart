import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/service/UserService.dart';
import '../../utils/colors.dart';
import '../../utils/sizes.dart';
import '../core/service/AuthService.dart';
import '../data/userModels/address_model.dart';
import '../models/address_model.dart'; // <<--- THÊM IMPORT ADDRESSMODEL

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  String? _selectedRoleDialog;

  String? get currentAdminUid => _authService.getCurrentUser()?.uid;

  // TextEditingControllers cho các dialog
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _loyaltyPointsController = TextEditingController();

  // MỚI: Controllers cho dialog địa chỉ
  final TextEditingController _addressNameController = TextEditingController();
  final TextEditingController _addressPhoneController = TextEditingController();
  final TextEditingController _addressDetailController = TextEditingController();
  bool _addressIsDefaultController = false;


  @override
  void dispose() {
    _phoneNumberController.dispose();
    _fullNameController.dispose();
    _loyaltyPointsController.dispose();
    _addressNameController.dispose();
    _addressPhoneController.dispose();
    _addressDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? adminUid = currentAdminUid;

    return Scaffold(
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
    final int loyaltyPoints = userData['loyaltyPoints'] as int? ?? 0;

    // Lấy và chuyển đổi danh sách địa chỉ một cách an toàn
    final List<dynamic> addressesDynamic = userData['shippingAddress'] as List<dynamic>? ?? [];
    final List<AddressModel> shippingAddresses = addressesDynamic
        .map((addrMap) => AddressModel.fromMap(addrMap as Map<String, dynamic>))
        .toList();

    return Card(
      // ... (Phần Card và thông tin user cơ bản giữ nguyên) ...
      margin: const EdgeInsets.symmetric(vertical: Sizes.sm),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.cardRadiusMd)),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fullName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isCurrentUserTheAdminViewing)
                            SizedBox(
                              height: 24, width: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Iconsax.edit_2, size: Sizes.iconSm, color: TColors.primary),
                                tooltip: 'Sửa tên',
                                onPressed: () => _showEditFullNameDialog(context, uid, userData['fullName'] ?? ''),
                              ),
                            ),
                        ],
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
                              phoneNumber, // SĐT chính của user
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isCurrentUserTheAdminViewing)
                            SizedBox(
                              height: 24, width: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Iconsax.edit_2, size: Sizes.iconSm, color: TColors.primary),
                                tooltip: 'Sửa SĐT chính',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.medal_star, size: Sizes.iconMd, color: TColors.warning),
                    const SizedBox(width: Sizes.sm / 2),
                    Text('Điểm Loyalty: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: TColors.dark)),
                    Text('$loyaltyPoints', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: TColors.primary)),
                  ],
                ),
                if (!isCurrentUserTheAdminViewing)
                  TextButton.icon(
                    icon: const Icon(Iconsax.edit, size: Sizes.iconSm, color: TColors.primary),
                    label: const Text('Sửa điểm', style: TextStyle(fontSize: Sizes.fontSizeSm * 0.9, color: TColors.primary)),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: Sizes.sm/2)),
                    onPressed: () => _showEditLoyaltyPointsDialog(context, uid, fullName, loyaltyPoints),
                  ),
              ],
            ),
            const SizedBox(height: Sizes.sm),
            _buildAddressesSection(context, uid, fullName, shippingAddresses, isCurrentUserTheAdminViewing),
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
                if (!isCurrentUserTheAdminViewing) // Admin có thể sửa vai trò của người khác, nhưng không phải của chính mình nếu điều đó làm mất quyền admin
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

  Widget _buildAddressesSection(BuildContext context, String uid, String userName, List<AddressModel> addresses, bool isCurrentUserTheAdminViewing) {
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
            if (!isCurrentUserTheAdminViewing)
              IconButton(
                icon: const Icon(Iconsax.add_square, color: TColors.primary, size: Sizes.iconMd),
                tooltip: 'Thêm địa chỉ mới',
                onPressed: () => _showAddEditAddressDialog(context, uid, userName),
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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addressModel = addresses[index];
              return Card(
                elevation: 0.5,
                margin: const EdgeInsets.only(bottom: Sizes.xs),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: addressModel.isDefault ? TColors.primary.withOpacity(0.5) : Colors.transparent, width: 1.5),
                    borderRadius: BorderRadius.circular(Sizes.borderRadiusSm)
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.sm, vertical: Sizes.xs/2),
                  // leading: Icon(Iconsax.location, size: Sizes.iconMd, color: addressModel.isDefault ? TColors.primary : TColors.dark),
                  title: Text(addressModel.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(addressModel.phone, style: Theme.of(context).textTheme.bodySmall),
                      Text(addressModel.address, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  trailing: isCurrentUserTheAdminViewing ? (addressModel.isDefault ? Chip(label: Text('Default'), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact,) : null) : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!addressModel.isDefault)
                        IconButton(
                          icon: const Icon(Iconsax.star_1, size: Sizes.iconSm, color: TColors.primaryBackground), // Hoặc star_slash nếu muốn
                          tooltip: 'Đặt làm mặc định',
                          onPressed: () => _confirmSetDefaultAddress(context, uid, userName, addressModel),
                        )
                      else
                        Icon(Iconsax.star_1, color: TColors.warning, size: Sizes.iconMd), // Icon sao vàng cho mặc định
                      IconButton(
                        icon: const Icon(Iconsax.edit_2, size: Sizes.iconSm, color: TColors.primary),
                        tooltip: 'Sửa địa chỉ',
                        onPressed: () => _showAddEditAddressDialog(context, uid, userName, oldAddressModel: addressModel),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.trash, size: Sizes.iconSm, color: TColors.error),
                        tooltip: 'Xóa địa chỉ',
                        onPressed: () => _confirmRemoveAddress(context, uid, userName, addressModel),
                      ),
                    ],
                  ),
                  onTap: isCurrentUserTheAdminViewing || addressModel.isDefault ? null : () => _confirmSetDefaultAddress(context, uid, userName, addressModel), // Set default on tap if not default
                ),
              );
            },
          ),
        const SizedBox(height: Sizes.sm),
      ],
    );
  }

  // --- Dialog thêm/sửa địa chỉ ---
  Future<void> _showAddEditAddressDialog(BuildContext context, String uid, String userName, {AddressModel? oldAddressModel}) async {
    final bool isEditing = oldAddressModel != null;
    // Thiết lập giá trị ban đầu cho controllers
    _addressNameController.text = oldAddressModel?.name ?? '';
    _addressPhoneController.text = oldAddressModel?.phone ?? '';
    _addressDetailController.text = oldAddressModel?.address ?? '';
    _addressIsDefaultController = oldAddressModel?.isDefault ?? false;


    final AddressModel? resultAddress = await showDialog<AddressModel>(
      context: context,
      builder: (BuildContext dialogContext) {
        // Sử dụng StatefulBuilder để cập nhật trạng thái của Checkbox bên trong Dialog
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(isEditing ? 'Sửa địa chỉ cho "$userName"' : 'Thêm địa chỉ mới cho "$userName"'),
                content: SingleChildScrollView( // Cho phép cuộn nếu nội dung dài
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _addressNameController,
                        decoration: const InputDecoration(labelText: 'Tên người nhận', prefixIcon: Icon(Iconsax.user_octagon)),
                      ),
                      const SizedBox(height: Sizes.spaceBtwInputFields),
                      TextField(
                        controller: _addressPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Số điện thoại', prefixIcon: Icon(Iconsax.call_calling)),
                      ),
                      const SizedBox(height: Sizes.spaceBtwInputFields),
                      TextField(
                        controller: _addressDetailController,
                        maxLines: 3, minLines: 1,
                        decoration: const InputDecoration(labelText: 'Địa chỉ chi tiết', prefixIcon: Icon(Iconsax.map_1)),
                      ),
                      const SizedBox(height: Sizes.spaceBtwInputFields),
                      CheckboxListTile(
                        title: const Text("Đặt làm địa chỉ mặc định"),
                        value: _addressIsDefaultController,
                        onChanged: (bool? value) {
                          setDialogState(() { // Cập nhật trạng thái của Checkbox
                            _addressIsDefaultController = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading, // Checkbox ở bên trái
                        contentPadding: EdgeInsets.zero,
                      )
                    ],
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
                      if (_addressNameController.text.trim().isEmpty ||
                          _addressPhoneController.text.trim().isEmpty ||
                          _addressDetailController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin địa chỉ.'), backgroundColor: TColors.warning),
                        );
                        return;
                      }
                      final newAddress = AddressModel(
                        name: _addressNameController.text.trim(),
                        phone: _addressPhoneController.text.trim(),
                        address: _addressDetailController.text.trim(),
                        isDefault: _addressIsDefaultController,
                      );
                      Navigator.of(dialogContext).pop(newAddress);
                    },
                  ),
                ],
              );
            }
        );
      },
    );

    if (resultAddress != null) {
      try {
        if (isEditing) {
          // Chỉ gọi API nếu có thay đổi
          if (resultAddress != oldAddressModel) { // So sánh bằng AddressModel.operator==
            await _userService.editShippingAddress(uid, oldAddressModel!, resultAddress);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã sửa địa chỉ cho "$userName".'), backgroundColor: TColors.success),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Địa chỉ không có thay đổi.'), backgroundColor: Colors.grey),
            );
          }
        } else { // Thêm mới
          await _userService.addShippingAddress(uid, resultAddress);
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
  Future<void> _confirmRemoveAddress(BuildContext context, String uid, String userName, AddressModel addressToRemove) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa địa chỉ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn có chắc muốn xóa địa chỉ của "$userName"?'),
              const SizedBox(height: Sizes.sm),
              Text('Tên: ${addressToRemove.name}'),
              Text('SĐT: ${addressToRemove.phone}'),
              Text('Địa chỉ: ${addressToRemove.address}', style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
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

  // --- MỚI: Dialog xác nhận đặt làm địa chỉ mặc định ---
  Future<void> _confirmSetDefaultAddress(BuildContext context, String uid, String userName, AddressModel addressToSetDefault) async {
    if (addressToSetDefault.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Địa chỉ này đã là mặc định.'), backgroundColor: Colors.grey),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Đặt làm địa chỉ mặc định?'),
          content: Text('Bạn có muốn đặt địa chỉ "${addressToSetDefault.address.substring(0, (addressToSetDefault.address.length > 30) ? 30 : addressToSetDefault.address.length)}..." của "$userName" làm mặc định không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
              child: const Text('Đặt làm mặc định', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _userService.setDefaultShippingAddress(uid, addressToSetDefault);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã đặt địa chỉ làm mặc định cho "$userName".'), backgroundColor: TColors.success),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi đặt địa chỉ mặc định: $e'), backgroundColor: TColors.error),
        );
      }
    }
  }


  // --- Các dialog khác giữ nguyên (ban/unban, sửa tên, sửa vai trò, sửa điểm loyalty) ---
  Future<void> _confirmToggleBanStatus(BuildContext context, String uid, String userName, bool isCurrentlyBanned) async {
    // ... (code giữ nguyên) ...
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

  Future<void> _showEditFullNameDialog(BuildContext context, String uid, String currentFullName) async {
    // ... (code giữ nguyên) ...
    _fullNameController.text = currentFullName;
    final String? newFullName = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sửa họ và tên người dùng'),
          content: TextField(
            controller: _fullNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Họ và tên mới',
              hintText: 'Nhập họ và tên',
              prefixIcon: Icon(Iconsax.user_edit),
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Lưu'),
              onPressed: () {
                if (_fullNameController.text.trim().isNotEmpty) {
                  Navigator.of(dialogContext).pop(_fullNameController.text.trim());
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Họ và tên không được để trống'), backgroundColor: TColors.warning),
                  );
                }
              },
            ),
          ],
        );
      },
    );

    if (newFullName != null && newFullName != currentFullName) {
      try {
        await _userService.updateUserFullName(uid, newFullName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật họ và tên cho người dùng.'), backgroundColor: TColors.success),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật họ và tên: $e'), backgroundColor: TColors.error),
        );
      }
    } else if (newFullName == currentFullName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Họ và tên không thay đổi.'), backgroundColor: Colors.grey),
      );
    }
  }

  Future<void> _showEditRoleDialog(BuildContext context, String uid, String userName, String currentRole) async {
    // ... (code giữ nguyên) ...
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

  Future<void> _showEditPhoneNumberDialog(BuildContext context, String uid, String userName, String currentPhoneNumber) async {
    // ... (code giữ nguyên) ...
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
            ElevatedButton(
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
  Future<void> _showEditLoyaltyPointsDialog(BuildContext context, String uid, String userName, int currentPoints) async {
    // ... (code giữ nguyên) ...
    _loyaltyPointsController.text = currentPoints.toString();
    final String? newPointsStr = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Sửa điểm Loyalty cho "$userName"'),
          content: TextField(
            controller: _loyaltyPointsController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              labelText: 'Số điểm mới',
              hintText: 'Nhập số điểm',
              prefixIcon: Icon(Iconsax.medal_star),
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Lưu'),
              onPressed: () {
                if (_loyaltyPointsController.text.trim().isNotEmpty) {
                  final int? points = int.tryParse(_loyaltyPointsController.text.trim());
                  if (points != null && points >= 0) {
                    Navigator.of(dialogContext).pop(_loyaltyPointsController.text.trim());
                  } else {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Số điểm không hợp lệ hoặc phải lớn hơn bằng 0.'), backgroundColor: TColors.warning),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Số điểm không được để trống.'), backgroundColor: TColors.warning),
                  );
                }
              },
            ),
          ],
        );
      },
    );

    if (newPointsStr != null) {
      final int? newPoints = int.tryParse(newPointsStr);
      if (newPoints != null && newPoints != currentPoints) {
        try {
          await _userService.updateUserLoyaltyPoints(uid, newPoints);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã cập nhật điểm Loyalty cho "$userName".'), backgroundColor: TColors.success),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi cập nhật điểm Loyalty: $e'), backgroundColor: TColors.error),
          );
        }
      } else if (newPoints == currentPoints) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số điểm Loyalty không thay đổi.'), backgroundColor: Colors.grey),
        );
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}