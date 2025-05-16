import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// Import Services and Models
import '../../core/service/AuthService.dart';
import '../../core/service/ChatService.dart';
import '../../models/message.dart';
// Import style utils
import '../../utils/colors.dart';
import '../../utils/sizes.dart';
import '../../consts/colors.dart';
import '../../widgets/appbar.dart';
import 'package:iconsax/iconsax.dart';


class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();

  User? _currentUser; // Người dùng hiện tại

  // Lấy UID Admin từ ChatService (hoặc nơi khác an toàn)
  // Phải khớp với UID được thiết lập trong ChatService và Security Rules
  final String _adminUid = 'YOUR_ADMIN_UID_HERE';


  // Biến state để theo dõi việc đang tải lên nhiều ảnh
  bool _isUploadingImages = false;


  @override
  void initState() {
    super.initState();
    // Lấy người dùng hiện tại khi Widget được tạo
    _currentUser = _authService.getCurrentUser();

    // Optional: Lắng nghe trạng thái auth changes nếu muốn tự động thoát trang chat khi đăng xuất
    // _authService.authStateChanges.listen((user) {
    //    if (user == null && mounted) { // Check mounted before context operations
    //       Navigator.pop(context);
    //    }
    // });

    // Tự động cuộn xuống cuối tin nhắn cuối cùng sau khi có dữ liệu ban đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Có thể cần delay ngắn để đảm bảo ListView đã render item
      Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Hàm gửi tin nhắn text
  void _sendTextMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      try {
        await _chatService.sendMessage(
          recipientUid: _adminUid, // Gửi đến admin
          text: _messageController.text.trim(),
        );
        _messageController.clear();
        // Cuộn xuống sau khi gửi tin nhắn (khi stream update)
        // _scrollToBottom(); // Đã gọi ở StreamBuilder
      } catch (e) {
        print("Error sending text message: ${e.toString()}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gửi tin nhắn thất bại: ${e.toString()}")),
        );
      }
    }
  }

  // Hàm gửi NHIỀU tin nhắn ảnh
  Future<void> _sendImageMessage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(); // Chọn nhiều ảnh

    if (pickedFiles == null || pickedFiles.isEmpty) {
      print("No images selected.");
      return;
    }

    setState(() {
      _isUploadingImages = true;
      // Tùy chọn: hiển thị dialog loading
      // showDialog(context: context, builder: (context) => AlertDialog(content: Text('Đang tải ${pickedFiles.length} ảnh lên...'), barrierDismissible: false));
    });

    try {
      // Tải lên tuần tự
      for (final pickedFile in pickedFiles) {
        File imageFile = File(pickedFile.path);
        await _chatService.sendMessage(
          recipientUid: _adminUid,
          imageFile: imageFile,
        );
        // Có thể thêm delay ngắn nếu cần
        // await Future.delayed(const Duration(milliseconds: 100));
      }

      print("All selected images sent successfully.");
      // Cuộn xuống sau khi gửi xong tất cả ảnh (khi stream update)
      // _scrollToBottom(); // Đã gọi ở StreamBuilder


    } catch (e) {
      print("Error sending one or more images: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gửi ảnh thất bại: ${e.toString()}")),
      );

    } finally {
      setState(() {
        _isUploadingImages = false;
      });
      // Tùy chọn: Đóng dialog loading
      // if (Navigator.of(context).canPop()) {
      //   Navigator.of(context).pop();
      // }
    }
  }

  // Hàm cuộn xuống cuối danh sách tin nhắn
  void _scrollToBottom() {
    // Thêm một delay nhỏ để đợi ListView render tin nhắn mới sau khi stream update
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        appBar: TAppBar(title: Text('Chat Support'), showBackArrow: true),
        body: Center(
          child: Text('Vui lòng đăng nhập để sử dụng chức năng chat support.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text(
          'Chat Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Phần hiển thị tin nhắn (sử dụng StreamBuilder)
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessagesForCurrentUser(), // Lắng nghe stream tin nhắn của user hiện tại
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print("Chat Stream Error: ${snapshot.error}");
                  return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Bắt đầu cuộc trò chuyện mới!'));
                }

                final messages = snapshot.data!;
                // Cuộn xuống cuối mỗi khi có tin nhắn mới và UI được build lại
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());


                return ListView.builder(
                  controller: _scrollController, // Gắn controller để cuộn
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // Kiểm tra xem tin nhắn là của người dùng hiện tại hay của admin
                    bool isCurrentUser = message.senderId == _currentUser!.uid;
                    bool isSentByAdmin = message.senderId == _adminUid;


                    return Align( // Canh lề tin nhắn dựa vào người gửi
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft, // User gửi bên phải, Admin gửi bên trái
                      child: Column( // Sử dụng Column để chứa bubble và thời gian
                        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                            decoration: BoxDecoration(
                              color: isCurrentUser ? TColors.primary.withOpacity(0.8) : Colors.grey[300], // Màu khác nhau
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: isCurrentUser ? const Radius.circular(12) : const Radius.circular(0), // Bo góc dưới khác nhau
                                bottomRight: isCurrentUser ? const Radius.circular(0) : const Radius.circular(12),
                              ),
                            ),
                            child: message.type == 'image' && message.imageUrl != null
                                ? ClipRRect( // Bo góc ảnh
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                message.imageUrl!,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center( // Hiển thị loading khi tải ảnh
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text('Không thể tải ảnh');
                                },
                                width: 150, // Chiều rộng ảnh
                              ),
                            )
                                : Text( // Hiển thị text
                              message.text ?? '', // text có thể null nếu type là 'image'
                              style: TextStyle(
                                color: isCurrentUser ? whiteColor : Colors.black87, // Màu chữ khác nhau
                              ),
                            ),
                          ),
                          // Hiển thị thời gian tin nhắn (tùy chọn, cần import intl)
                          Padding(
                            padding: isCurrentUser
                                ? const EdgeInsets.only(right: 8.0, bottom: 8.0)
                                : const EdgeInsets.only(left: 8.0, bottom: 8.0),
                            child: Text(
                              // Kiểm tra nếu timestamp không phải null và không phải là timestamp chờ (seconds > 0)
                              message.timestamp.seconds > 0
                                  ? DateFormat('HH:mm').format(message.timestamp.toDate())
                                  : 'Đang gửi...', // Hiển thị trạng thái chờ nếu timestamp 0
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Phần nhập tin nhắn
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.md, vertical: Sizes.md),
            child: Row(
              children: [
                // Nút chọn ảnh (Hiển thị loading hoặc icon)
                _isUploadingImages
                    ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0), // Để cân bằng khoảng cách
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
                )
                    : IconButton(
                  onPressed: _sendImageMessage, // Vẫn gọi hàm gửi ảnh đã cập nhật
                  icon: const Icon(Iconsax.image, color: TColors.primary), // Dùng icon image
                ),

                // Trường nhập text tin nhắn
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    keyboardType: TextInputType.text,
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: Sizes.sm),

                // Nút gửi tin nhắn text
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43C6AC), Color(0xFF191654)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    onPressed: _sendTextMessage, // Gắn hàm gửi tin nhắn text
                    icon: const Icon(Iconsax.send_1, color: whiteColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}