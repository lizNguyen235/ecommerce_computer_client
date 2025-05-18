import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

// Giả sử AuthService nằm trong thư mục này, nếu không, hãy sửa đường dẫn
import '../../../../core/service/AuthService.dart';
import '../../../../core/service/UserService.dart';
import '../../../../utils/colors.dart'; // TColors của bạn
import '../../../../utils/sizes.dart';  // Sizes của bạn
import '../../../../widgets/appbar.dart';
import '../../core/service/StorageService.dart'; // Custom AppBar nếu có

class EditMyProfileScreen extends StatefulWidget {
  const EditMyProfileScreen({super.key});

  @override
  State<EditMyProfileScreen> createState() => _EditMyProfileScreenState();
}

class _EditMyProfileScreenState extends State<EditMyProfileScreen> {
  // Services
  final AuthService _authService = AuthService(); // Khởi tạo AuthService
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  // Form Key and Controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;

  // State variables
  String? _currentAvatarUrl;
  File? _selectedImageFile;
  Uint8List? _selectedImageBytesWeb; // MỚI: Dùng cho web
  bool _isLoadingData = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _loadUserProfileData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // ... trong lớp _EditMyProfileScreenState ...

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || !mounted) {
      return;
    }

    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;

    setState(() => _isSaving = true);
    bool success = false; // Biến để theo dõi thành công
    try {
      final Map<String, dynamic> dataToUpdate = {
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
      };

      await _userService.updateUserProfile(currentUser.uid, dataToUpdate);
      _showSnackBar('Thông tin đã được lưu thành công!');
      success = true; // Đánh dấu thành công
    } catch (e) {
      _showSnackBar('Lỗi lưu thông tin: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          Navigator.of(context).pop(true); // << TRẢ VỀ TRUE KHI THÀNH CÔNG
        }
      }
    }
  }

  // ... trong lớp _EditMyProfileScreenState ...

  // ... trong _EditMyProfileScreenState ...
  Future<void> _uploadAndSaveAvatar() async {
    // Kiểm tra xem có dữ liệu ảnh nào để tải lên không
    if ((!kIsWeb && _selectedImageFile == null) && (kIsWeb && _selectedImageBytesWeb == null)) {
      _showSnackBar('Vui lòng chọn một ảnh để tải lên.', isError: true);
      return;
    }

    if (!mounted) return;
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      String newAvatarUrl;
      if (kIsWeb) {
        newAvatarUrl = await _storageService.uploadUserAvatar(currentUser.uid, _selectedImageBytesWeb!);
      } else {
        newAvatarUrl = await _storageService.uploadUserAvatar(currentUser.uid, _selectedImageFile!);
      }
      await _storageService.deleteImage(_currentAvatarUrl ?? ''); // Xóa ảnh cũ nếu có
      await _userService.updateUserProfile(currentUser.uid, {'avatarUrl': newAvatarUrl});

      if (mounted) {
        setState(() {
          _currentAvatarUrl = newAvatarUrl;
          _selectedImageFile = null;
          _selectedImageBytesWeb = null; // Reset cả hai
        });
      }
      _showSnackBar('Ảnh đại diện đã được cập nhật!');
    } catch (e) {
      _showSnackBar('Lỗi tải lên ảnh: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _loadUserProfileData() async {
    if (!mounted) return;
    setState(() => _isLoadingData = true);
    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        _showSnackBar('Không tìm thấy người dùng. Vui lòng đăng nhập lại.', isError: true);
        // Có thể điều hướng về trang đăng nhập
        if (mounted) Navigator.of(context).pop();
        return;
      }

      _emailController.text = currentUser.email ?? 'N/A';

      final userProfile = await _userService.getUserProfile(currentUser.uid);
      if (mounted && userProfile != null) {
        _fullNameController.text = userProfile['fullName'] ?? currentUser.displayName ?? '';
        _phoneNumberController.text = userProfile['phoneNumber'] ?? '';
        setState(() {
          _currentAvatarUrl = userProfile['avatarUrl'];
        });
      } else if (mounted) {
        _fullNameController.text = currentUser.displayName ?? '';
      }
    } catch (e) {
      _showSnackBar('Lỗi tải thông tin: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Sizes.cardRadiusLg)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Iconsax.camera, color: TColors.primary),
                title: const Text('Chụp ảnh mới'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.gallery, color: TColors.primary),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        if (kIsWeb) { // KIỂM TRA NỀN TẢNG WEB
          final bytes = await pickedFile.readAsBytes();
          if (mounted) {
            setState(() {
              _selectedImageBytesWeb = bytes; // Lưu dữ liệu bytes cho web
              _selectedImageFile = null; // Reset file cho mobile nếu có
            });
          }
        } else { // NỀN TẢNG MOBILE
          if (mounted) {
            setState(() {
              _selectedImageFile = File(pickedFile.path); // Lưu File object cho mobile
              _selectedImageBytesWeb = null; // Reset bytes cho web nếu có
            });
          }
        }
        // Sau khi chọn và set state, gọi hàm tải lên.
        // Hàm _uploadAndSaveAvatar sẽ cần được điều chỉnh để xử lý cả File và Uint8List.
        await _uploadAndSaveAvatar();
      }
    } catch (e) {
      _showSnackBar('Lỗi chọn ảnh: ${e.toString()}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TAppBar(
        title: Text('Chỉnh Sửa Hồ Sơ', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: TColors.primary))
          : GestureDetector( // Để ẩn bàn phím khi chạm ra ngoài
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Sizes.defaultSpace),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(65),
                      child: kIsWeb && _selectedImageBytesWeb != null // ƯU TIÊN HIỂN THỊ ẢNH MỚI CHỌN CHO WEB
                          ? Image.memory(_selectedImageBytesWeb!, fit: BoxFit.cover, width: 130, height: 130)
                          : !kIsWeb && _selectedImageFile != null // Ưu tiên ảnh mới chọn cho mobile
                          ? Image.file(_selectedImageFile!, fit: BoxFit.cover, width: 130, height: 130)
                          : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) // Ảnh đã lưu từ server
                          ? Image.network(
                        _currentAvatarUrl!,
                        fit: BoxFit.cover, width: 130, height: 130,
                        loadingBuilder: (context, child, progress) =>
                        progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(TColors.light))),
                        errorBuilder: (context, error, stack) =>
                        const CircleAvatar(radius: 65, backgroundColor: TColors.lightContainer, child: Icon(Iconsax.user_octagon, size: 70, color: TColors.dark)),
                      )
                          : const CircleAvatar(radius: 65, backgroundColor: TColors.lightContainer, child: Icon(Iconsax.user_octagon, size: 70, color: TColors.dark)), // Ảnh mặc định
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _isUploadingAvatar
                        ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: TColors.dark.withOpacity(0.7), shape: BoxShape.circle),
                      child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                    )
                        : InkWell(
                      onTap: _showImageSourceActionSheet,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(Sizes.sm - 2),
                        decoration: BoxDecoration(
                            color: TColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: Theme.of(context).scaffoldBackgroundColor),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))]
                        ),
                        child: const Icon(Iconsax.camera, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sizes.sm / 2),
              TextButton(
                onPressed: _isUploadingAvatar ? null : _showImageSourceActionSheet,
                child: const Text('Thay đổi ảnh đại diện', style: TextStyle(color: TColors.primary)),
              ),
              const SizedBox(height: Sizes.spaceBtwSections * 0.8),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Thông tin cá nhân", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: Sizes.spaceBtwItems),

                    TextFormField(
                      controller: _fullNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Họ và tên',
                        prefixIcon: const Icon(Iconsax.user_edit),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Sizes.inputFieldRadius)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ và tên.';
                        if (value.trim().length < 3) return 'Họ và tên phải có ít nhất 3 ký tự.';
                        return null;
                      },
                    ),
                    const SizedBox(height: Sizes.spaceBtwInputFields),

                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Iconsax.direct_right),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Sizes.inputFieldRadius)),
                        filled: true,
                        fillColor: TColors.dark.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: Sizes.spaceBtwInputFields),

                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        hintText: 'Chưa cập nhật',
                        prefixIcon: const Icon(Iconsax.call_add),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Sizes.inputFieldRadius)),
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (!RegExp(r"^(0|\+84)?[0-9]{9}$").hasMatch(value.trim())) { // Regex SĐT Việt Nam cơ bản
                            return 'Số điện thoại không hợp lệ.';
                          }
                        }
                        return null; // Cho phép để trống nếu không bắt buộc
                      },
                    ),
                    const SizedBox(height: Sizes.spaceBtwSections * 1.5),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isSaving || _isUploadingAvatar) ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: Sizes.md),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.buttonRadius)),
                          elevation: _isSaving || _isUploadingAvatar ? 0 : 2,
                        ),
                        child: (_isSaving)
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text('Lưu Thay Đổi', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  void _showSnackBar(String message, {bool isError = false, Duration duration = const Duration(seconds: 3)}) {
    // 1. Kiểm tra xem Widget có còn "mounted" không.
    // Điều này rất quan trọng để tránh lỗi nếu hàm được gọi sau khi Widget đã bị dispose
    // (ví dụ: trong một callback bất đồng bộ hoàn thành sau khi người dùng đã điều hướng đi nơi khác).
    if (!mounted) {
      print("SnackBar not shown: Widget is not mounted. Message: $message");
      return;
    }

    // 2. Xóa SnackBar hiện tại (nếu có) trước khi hiển thị cái mới.
    // Điều này giúp tránh việc nhiều SnackBar chồng chéo lên nhau.
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    // 3. Tạo SnackBar.
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: isError ? TColors.textWhite : TColors.textWhite, // Tùy chỉnh màu chữ nếu cần
          // fontWeight: FontWeight.w500, // Tùy chỉnh font weight
        ),
      ),
      backgroundColor: isError ? TColors.error : TColors.success, // Màu nền dựa trên trạng thái lỗi
      duration: duration, // Thời gian hiển thị SnackBar
      behavior: SnackBarBehavior.floating, // 'floating' hoặc 'fixed' (fixed ở dưới cùng)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.borderRadiusMd), // Bo góc cho đẹp hơn
      ),
      margin: const EdgeInsets.all(Sizes.md), // Thêm margin nếu là 'floating'
      // elevation: 4.0, // Thêm đổ bóng nếu muốn
      // action: SnackBarAction( // (Tùy chọn) Thêm hành động cho SnackBar
      //   label: 'ĐÓNG',
      //   textColor: isError ? Colors.white70 : Colors.white70,
      //   onPressed: () {
      //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
      //   },
      // ),
    );

    // 4. Hiển thị SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}