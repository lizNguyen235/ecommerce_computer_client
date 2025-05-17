import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Import Services and Models
import '../../core/service/AuthService.dart'; // Điều chỉnh đường dẫn
import '../../core/service/ChatService.dart'; // Điều chỉnh đường dẫn
import '../../core/service/ConfigService.dart'; // Điều chỉnh đường dẫn
import '../../models/message.dart'; // Điều chỉnh đường dẫn

// Import style utils
import '../../utils/colors.dart'; // Điều chỉnh đường dẫn
import '../../utils/sizes.dart'; // Điều chỉnh đường dẫn// Điều chỉnh đường dẫn
import '../../widgets/appbar.dart'; // Điều chỉnh đường dẫn
import 'package:iconsax/iconsax.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late ChatService _chatService; // Sẽ được khởi tạo trong FutureBuilder
  final AuthService _authService = AuthService();
  final ConfigService _configService =
      ConfigService(); // Khởi tạo ConfigService
  final ScrollController _scrollController = ScrollController();

  User? _currentUser;
  String?
  _adminUidForStyling; // Chỉ dùng để style tin nhắn của admin, lấy 1 lần

  late Future<void> _initializePageFuture;
  bool _isSendingMessage = false;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.getCurrentUser();
    _initializePageFuture = _initializePageDependencies();

    // Tự động cuộn xuống cuối
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Đảm bảo _scrollController đã được gắn vào ListView
      if (_scrollController.hasClients) {
        _scrollToBottom();
      } else {
        // Nếu chưa, đợi một chút rồi thử lại (thường không cần thiết với FutureBuilder)
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) _scrollToBottom();
        });
      }
    });
  }

  Future<void> _initializePageDependencies() async {
    try {
      // Khởi tạo ChatService với ConfigService
      _chatService = ChatService(configService: _configService);

      // Lấy adminUid một lần để style tin nhắn nếu cần
      _adminUidForStyling = await _configService.getAdminUid();

      if (_adminUidForStyling == null || _adminUidForStyling!.isEmpty) {
        print(
          "SupportChatPage: Admin UID configuration error during initialization.",
        );
        throw Exception("Admin configuration is missing or invalid.");
      }

      // Đánh dấu tin nhắn đã đọc khi user vào trang
      if (_currentUser != null) {
        await _chatService.markMessagesAsReadByUser();
      }
    } catch (e) {
      print("SupportChatPage: Error initializing page dependencies: $e");
      // Ném lại lỗi để FutureBuilder có thể bắt và hiển thị thông báo lỗi
      rethrow;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendTextMessage() async {
    if (_messageController.text.trim().isEmpty || _isSendingMessage) return;

    if (mounted) setState(() => _isSendingMessage = true);
    try {
      await _chatService.sendMessage(text: _messageController.text.trim());
      _messageController.clear();
    } catch (e) {
      print("SupportChatPage: Error sending text message: ${e.toString()}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gửi tin nhắn thất bại: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingMessage = false);
    }
  }

  // Giả sử bạn có một hàm _pickAndSendImage() trong widget chat của người dùng

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery /* hoặc camera */);

    if (pickedFile == null) return;

    // setState(() => _isSending = true); // Cập nhật UI nếu cần

    try {
      dynamic imageDataToSend;
      String fileName = pickedFile.name;

      if (kIsWeb) {
        imageDataToSend = await pickedFile.readAsBytes();
        // Kiểm tra kích thước bytes nếu cần
      } else {
        File imageFile = File(pickedFile.path);
        // Kiểm tra kích thước file nếu cần
        imageDataToSend = imageFile;
      }

      // Gọi hàm sendMessage của ChatService
      await _chatService.sendMessage( // Giả sử _chatService là instance của ChatService
        imageData: imageDataToSend,
        imageFileName: fileName,
      );
    } catch (e) {
      // Hiển thị lỗi cho người dùng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi gửi ảnh: ${e.toString()}")),
      );
    } finally {
      // setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    // Đợi một chút để đảm bảo ListView đã cập nhật các item
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
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
      // Người dùng chưa đăng nhập
      return Scaffold(
        backgroundColor: TColors.light,
        appBar: TAppBar(
          title: Text(
            'Chat Support',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          showBackArrow: true,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Vui lòng đăng nhập để sử dụng chức năng chat hỗ trợ.'),
          ),
        ),
      );
    }

    return FutureBuilder<void>(
      future: _initializePageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: TAppBar(
              title: Text(
                'Chat Support',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              showBackArrow: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: TAppBar(
              title: Text(
                'Chat Support',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              showBackArrow: true,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Không thể tải trang chat.\nLỗi: ${snapshot.error}\nVui lòng thử lại sau.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // Khởi tạo thành công, hiển thị UI chat
        return Scaffold(
          backgroundColor: TColors.textWhite, // Sử dụng TColors nếu có
          appBar: TAppBar(
            showBackArrow: true,
            title: Text(
              'Chat Support',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: TColors.dark),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: _chatService.getMessagesForCurrentUser(),
                  builder: (context, streamSnapshot) {
                    if (streamSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        (!streamSnapshot.hasData ||
                            streamSnapshot.data!.isEmpty)) {
                      // Chỉ hiển thị loading nếu chưa có dữ liệu ban đầu
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (streamSnapshot.hasError) {
                      print(
                        "SupportChatPage: Chat Stream Error: ${streamSnapshot.error}",
                      );
                      return Center(
                        child: Text(
                          'Lỗi tải tin nhắn: ${streamSnapshot.error}',
                        ),
                      );
                    }
                    if (!streamSnapshot.hasData ||
                        streamSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chưa có tin nhắn nào. Hãy bắt đầu cuộc trò chuyện!',
                        ),
                      );
                    }

                    final messages = streamSnapshot.data!;
                    // Gọi _scrollToBottom sau khi frame được build nếu có tin nhắn mới
                    // Điều này giúp cuộn xuống khi có tin nhắn mới từ stream
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scrollToBottom(),
                    );

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(
                        Sizes.sm,
                      ), // Thêm padding cho ListView
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final bool isCurrentUserMessage =
                            message.senderId == _currentUser!.uid;
                        final bool isAdminMessage =
                            _adminUidForStyling != null &&
                            message.senderId == _adminUidForStyling;

                        return _buildMessageItem(
                          message,
                          isCurrentUserMessage,
                          isAdminMessage,
                        );
                      },
                    );
                  },
                ),
              ),
              _buildMessageInputArea(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(
    Message message,
    bool isCurrentUserMessage,
    bool isAdminMessage,
  ) {
    return Align(
      alignment:
          isCurrentUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isCurrentUserMessage
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ), // Giới hạn chiều rộng bubble
            margin: const EdgeInsets.symmetric(
              vertical: 4.0,
            ), // Bỏ horizontal margin ở đây, dùng padding của ListView
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 14.0,
            ),
            decoration: BoxDecoration(
              color:
                  isCurrentUserMessage
                      ? TColors.primary.withOpacity(0.9)
                      : (isAdminMessage
                          ? TColors.secondary.withOpacity(0.2)
                          : Colors.grey[300]), // Màu riêng cho admin
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isCurrentUserMessage ? 16 : 4),
                bottomRight: Radius.circular(isCurrentUserMessage ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child:
                message.type == 'image' && message.imageUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        message.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 150,
                            height: 150, // Kích thước cố định khi loading
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 150,
                            height: 100,
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.warning_2,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                SizedBox(height: 4),
                                Text('Lỗi ảnh', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                    : Text(
                      message.text ?? '',
                      style: TextStyle(
                        color:
                            isCurrentUserMessage
                                ? TColors.textWhite
                                : TColors.dark,
                        fontSize: 15,
                      ),
                    ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: isCurrentUserMessage ? 0 : 4.0,
              right: isCurrentUserMessage ? 4.0 : 0,
              bottom: Sizes.xs,
            ),
            child: Text(
              message.timestamp.seconds > 0
                  ? DateFormat('HH:mm').format(message.timestamp.toDate())
                  : 'Đang gửi...',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputArea() {
    return Container(
      padding: const EdgeInsets.only(
        left: Sizes.md,
        right: Sizes.md,
        bottom: Sizes.md,
        top: Sizes.xs,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context).scaffoldBackgroundColor, // Hoặc màu nền bạn muốn
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 5,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        // Để input không bị che bởi notch/system UI ở dưới
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment
                  .end, // Căn các item theo cuối nếu TextField nhiều dòng
          children: [
            IconButton(
              onPressed: _isSendingMessage ? null : _pickAndSendImage,
              icon: Icon(
                Iconsax.gallery_add,
                color: _isSendingMessage ? Colors.grey : TColors.primary,
                size: 28,
              ),
              tooltip: 'Gửi ảnh',
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !_isSendingMessage,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Sizes.cardRadiusLg * 1.5,
                    ), // Bo tròn hơn
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Sizes.md,
                    vertical: Sizes.sm + 2,
                  ), // Điều chỉnh padding
                ),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5, // Cho phép nhập nhiều dòng
                textInputAction:
                    TextInputAction
                        .newline, // Hoặc .send nếu muốn custom action
                onSubmitted:
                    (_) =>
                        _sendTextMessage(), // Gửi khi nhấn enter trên bàn phím cứng
              ),
            ),
            const SizedBox(width: Sizes.xs),
            Material(
              // Bọc IconButton trong Material để có hiệu ứng ripple trên gradient
              color: Colors.transparent, // Quan trọng
              borderRadius: BorderRadius.circular(Sizes.buttonRadius * 2),
              child: InkWell(
                // Dùng InkWell cho hiệu ứng ripple
                onTap: _isSendingMessage ? null : _sendTextMessage,
                borderRadius: BorderRadius.circular(Sizes.buttonRadius * 2),
                child: Ink(
                  // Dùng Ink để vẽ gradient
                  decoration: BoxDecoration(
                    gradient:
                        _isSendingMessage
                            ? null
                            : LinearGradient(
                              // Bỏ gradient khi đang gửi
                              colors: [
                                TColors.light,
                                TColors.primary.withOpacity(0.7),
                              ], // Màu gradient
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                    color:
                        _isSendingMessage
                            ? Colors.grey[400]
                            : null, // Màu nền khi disable
                    borderRadius: BorderRadius.circular(Sizes.buttonRadius * 2),
                  ),
                  padding: const EdgeInsets.all(Sizes.sm + 2), // Kích thước nút
                  child:
                      _isSendingMessage
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: TColors.textWhite,
                              strokeWidth: 2.5,
                            ),
                          )
                          : const Icon(
                            Iconsax.send_1,
                            color: TColors.primary,
                            size: 24,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
