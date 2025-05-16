import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show User; // Chỉ import User
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show QueryDocumentSnapshot, Timestamp; // Import cụ thể

// Import Services and Models
import '../../core/service/AuthService.dart';
import '../../core/service/ChatService.dart';
import '../../core/service/ConfigService.dart';
import '../../models/message.dart';
import '../../models/conversation_summary.dart';

// Import style utils (Giả định bạn có các file này)
import '../../utils/colors.dart';
import '../../utils/sizes.dart';
import '../../consts/colors.dart'; // Có vẻ TColors nằm ở đây
// import '../../widgets/appbar.dart'; // Nếu có TAppBar
import 'package:iconsax/iconsax.dart';

class CustomerSupportAdminScreen extends StatefulWidget {
  const CustomerSupportAdminScreen({super.key});

  @override
  State<CustomerSupportAdminScreen> createState() => _CustomerSupportAdminScreenState();
}

class _CustomerSupportAdminScreenState extends State<CustomerSupportAdminScreen> {
  // Khởi tạo trực tiếp các service
  final AuthService _authService = AuthService();
  final ConfigService _configService = ConfigService();
  late final ChatService _chatService; // Sẽ được khởi tạo trong initState

  final TextEditingController _adminMessageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  User? _currentAdminUser; // Người dùng admin hiện tại
  String? _adminUidForVerification; // UID của admin từ config, dùng để xác thực

  late Future<void> _initializePageFuture;

  // State để quản lý cuộc trò chuyện đang được chọn
  ConversationSummary? _selectedConversation;
  String? _selectedConversationUserId;

  bool _isSendingAdminMessage = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo ChatService với các service đã có
    _chatService = ChatService(configService: _configService);

    _currentAdminUser = _authService.getCurrentUser();
    _initializePageFuture = _initializePageDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Đảm bảo scroll controller được gắn trước khi cuộn
      if (_chatScrollController.hasClients) {
        _scrollToChatBottomIfNeeded();
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_chatScrollController.hasClients) _scrollToChatBottomIfNeeded();
        });
      }
    });
  }

  Future<void> _initializePageDependencies() async {
    try {
      _adminUidForVerification = await _configService.getAdminUid();

      if (_adminUidForVerification == null || _adminUidForVerification!.isEmpty) {
        throw Exception("Admin UID configuration error. Cannot load admin chat support.");
      }

      if (_currentAdminUser == null || _currentAdminUser!.uid != _adminUidForVerification) {
        // Ghi log và ném lỗi để FutureBuilder xử lý
        print("CustomerSupportAdminScreen: Access Denied. User UID: ${_currentAdminUser?.uid}, Required Admin UID: $_adminUidForVerification");
        throw Exception("Access Denied: You are not authorized to view this page.");
      }
      // Khởi tạo thành công, không cần làm gì thêm ở đây
      print("CustomerSupportAdminScreen: Admin verified. UID: ${_currentAdminUser!.uid}");
    } catch (e) {
      print("CustomerSupportAdminScreen: Error initializing page dependencies: $e");
      rethrow; // Ném lại lỗi để FutureBuilder bắt
    }
  }

  @override
  void dispose() {
    _adminMessageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _selectConversation(ConversationSummary conversation) {
    if (!mounted) return;
    setState(() {
      _selectedConversation = conversation;
      _selectedConversationUserId = conversation.userId;
      if (_selectedConversationUserId != null) {
        _chatService.markMessagesAsReadByAdmin(_selectedConversationUserId!);
      }
    });
    _scrollToChatBottomIfNeeded(delayMilliseconds: 150);
  }

  void _closeChatDetail() {
    if (!mounted) return;
    setState(() {
      _selectedConversation = null;
      _selectedConversationUserId = null;
    });
  }

  void _sendAdminTextMessage() async {
    if (_adminMessageController.text.trim().isEmpty ||
        _isSendingAdminMessage ||
        _selectedConversationUserId == null) return;

    if (mounted) setState(() => _isSendingAdminMessage = true);
    try {
      await _chatService.sendAdminMessage(
        targetUserUid: _selectedConversationUserId!,
        text: _adminMessageController.text.trim(),
      );
      _adminMessageController.clear();
      _scrollToChatBottomIfNeeded(delayMilliseconds: 100);
    } catch (e) {
      print("CustomerSupportAdminScreen: Error sending admin text message: ${e.toString()}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gửi tin nhắn thất bại: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingAdminMessage = false);
    }
  }

  Future<void> _sendAdminImageMessage() async {
    if (_isSendingAdminMessage || _selectedConversationUserId == null) return;

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile == null) return;

    if (mounted) setState(() => _isSendingAdminMessage = true);

    try {
      File imageFile = File(pickedFile.path);
      if (await imageFile.length() > 5 * 1024 * 1024) { // 5MB limit
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ảnh quá lớn (tối đa 5MB).")),
          );
        }
        if (mounted) setState(() => _isSendingAdminMessage = false);
        return;
      }

      await _chatService.sendAdminMessage(
        targetUserUid: _selectedConversationUserId!,
        imageFile: imageFile,
      );
      _scrollToChatBottomIfNeeded(delayMilliseconds: 100);
    } catch (e) {
      print("CustomerSupportAdminScreen: Error sending admin image message: ${e.toString()}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gửi ảnh thất bại: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingAdminMessage = false);
    }
  }

  void _scrollToChatBottomIfNeeded({int delayMilliseconds = 200}) {
    // Chỉ cuộn nếu đang xem chi tiết cuộc trò chuyện
    if (_selectedConversationUserId != null) {
      Future.delayed(Duration(milliseconds: delayMilliseconds), () {
        if (mounted && _chatScrollController.hasClients && _chatScrollController.position.maxScrollExtent > 0) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // _currentAdminUser đã được lấy trong initState
    // FutureBuilder sẽ xử lý việc chờ _initializePageFuture
    return FutureBuilder<void>(
      future: _initializePageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          // Lỗi trong quá trình khởi tạo (ví dụ: không phải admin, không lấy được config)
          return Scaffold(
            // appBar: TAppBar(title: Text('Lỗi Truy Cập'), showBackArrow: false), // Tùy chỉnh AppBar lỗi
            appBar: AppBar(title: const Text('Lỗi Truy Cập'), automaticallyImplyLeading: false),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${snapshot.error}', // Hiển thị thông báo lỗi
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
          );
        }

        // Khởi tạo thành công, _currentAdminUser là admin hợp lệ
        // Quyết định hiển thị danh sách hay chi tiết chat
        if (_selectedConversation == null || _selectedConversationUserId == null) {
          return Scaffold(
            // appBar: TAppBar(title: Text('Hỗ trợ khách hàng')), // Không cần AppBar ở đây nếu là một phần của AdminMainPage
            body: _buildConversationsList(),
          );
        } else {
          // Không dùng Scaffold ở đây vì _buildChatDetailView đã là một UI hoàn chỉnh
          // với AppBar tùy chỉnh bên trong nó.
          return _buildChatDetailView(_selectedConversation!, _selectedConversationUserId!);
        }
      },
    );
  }

  Widget _buildConversationsList() {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _chatService.getUserConversationsStreamForAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải danh sách trò chuyện: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có cuộc trò chuyện nào.'));
        }

        final conversations = snapshot.data!
            .map((doc) => ConversationSummary.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();

        return ListView.separated(
          itemCount: conversations.length,
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 72, endIndent: 16), // Tăng indent
          itemBuilder: (context, index) {
            final convo = conversations[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.md, vertical: Sizes.xs),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: TColors.primary.withOpacity(0.1),
                child: Text(
                  convo.userName != null && convo.userName!.isNotEmpty ? convo.userName![0].toUpperCase() : 'U',
                  style: const TextStyle(color: TColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              title: Text(
                convo.userName ?? 'Khách hàng ẩn danh',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: convo.adminUnread ? FontWeight.bold : FontWeight.normal,
                  color: convo.adminUnread ? TColors.primary : TColors.dark,
                ),
              ),
              subtitle: Text(
                convo.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: convo.adminUnread ? TColors.primary.withOpacity(0.8) : Colors.grey[600]
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('HH:mm').format(convo.lastMessageTimestamp.toDate()),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  if (convo.adminUnread)
                    Container(
                      padding: const EdgeInsets.all(6), // Kích thước chấm đỏ
                      decoration: const BoxDecoration(
                        color: Colors.red, // Hoặc TColors.primary
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              onTap: () => _selectConversation(convo),
            );
          },
        );
      },
    );
  }

  Widget _buildChatDetailView(ConversationSummary conversation, String targetUserId) {
    // _currentAdminUser chắc chắn không null ở đây vì đã qua FutureBuilder
    return Column(
      children: [
        Material(
          elevation: 1.0, // Giảm elevation
          color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface, // Lấy màu từ theme
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + Sizes.xs, // Thêm padding với status bar
              bottom: Sizes.xs,
              left: Sizes.xs,
              right: Sizes.sm,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Iconsax.arrow_left_2, color: Theme.of(context).appBarTheme.iconTheme?.color ?? TColors.dark),
                  onPressed: _closeChatDetail,
                  tooltip: 'Quay lại danh sách',
                ),
                CircleAvatar(
                  backgroundColor: TColors.primary.withOpacity(0.1),
                  child: Text(
                    conversation.userName != null && conversation.userName!.isNotEmpty ? conversation.userName![0].toUpperCase() : 'C',
                    style: const TextStyle(color: TColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: Sizes.sm),
                Expanded(
                  child: Text(
                    conversation.userName ?? 'Khách hàng',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? TColors.dark,
                        fontWeight: FontWeight.bold
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Có thể thêm actions ở đây (ví dụ: thông tin user)
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Message>>(
            stream: _chatService.getMessagesForSpecificUser(targetUserId),
            builder: (context, streamSnapshot) {
              // ... (logic StreamBuilder cho tin nhắn giữ nguyên như file trước)
              // Chỉ cần đảm bảo _currentAdminUser.uid được dùng để xác định tin nhắn của admin
              if (streamSnapshot.connectionState == ConnectionState.waiting &&
                  (!streamSnapshot.hasData || streamSnapshot.data!.isEmpty)) {
                return const Center(child: CircularProgressIndicator());
              }
              if (streamSnapshot.hasError) {
                return Center(child: Text('Lỗi tải tin nhắn: ${streamSnapshot.error}'));
              }
              if (!streamSnapshot.hasData || streamSnapshot.data!.isEmpty) {
                return const Center(child: Text('Chưa có tin nhắn nào.'));
              }

              final messages = streamSnapshot.data!;
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToChatBottomIfNeeded());

              return ListView.builder(
                controller: _chatScrollController,
                padding: const EdgeInsets.all(Sizes.md), // Tăng padding
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final bool isAdminMessage = message.senderId == _currentAdminUser!.uid;
                  return _buildAdminChatMessageItem(message, isAdminMessage);
                },
              );
            },
          ),
        ),
        _buildAdminMessageInputArea(),
      ],
    );
  }

  Widget _buildAdminChatMessageItem(Message message, bool isAdminMessage) {
    // ... (Giữ nguyên như file trước, đảm bảo màu sắc và alignment đúng)
    return Align(
      alignment: isAdminMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isAdminMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
            decoration: BoxDecoration(
                color: isAdminMessage
                    ? TColors.primary // Tin nhắn của Admin
                    : TColors.light, // Tin nhắn của Khách hàng
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isAdminMessage ? 16 : 4),
                  bottomRight: Radius.circular(isAdminMessage ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: TColors.dark.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ]
            ),
            child: message.type == 'image' && message.imageUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12.0), // Bo tròn ảnh hơn
              child: Image.network(
                message.imageUrl!,
                fit: BoxFit.cover, // Đảm bảo ảnh vừa vặn
                // Chiều rộng tối đa để ảnh không quá lớn
                width: MediaQuery.of(context).size.width * 0.6,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 150, height: 150,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 3,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                      padding: const EdgeInsets.all(Sizes.md),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [ Icon(Iconsax.gallery_slash, color: Colors.redAccent, size: 40), SizedBox(height: Sizes.xs), Text('Không tải được ảnh', style: TextStyle(fontSize: 12, color: TColors.dark))],
                      )
                  );
                },
              ),
            )
                : Text(
              message.text ?? '',
              style: TextStyle(
                color: isAdminMessage ? TColors.textWhite : Colors.black45,
                fontSize: 15,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: isAdminMessage ? 0 : Sizes.xs,
              right: isAdminMessage ? Sizes.xs : 0,
              bottom: Sizes.sm, // Tăng padding dưới
            ),
            child: Text(
              message.timestamp.seconds > 0
                  ? DateFormat('HH:mm').format(message.timestamp.toDate())
                  : 'Đang gửi...',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: TColors.dark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMessageInputArea() {
    // ... (Giữ nguyên như file trước, đảm bảo các TColors và Sizes được định nghĩa)
    return Container(
      padding: const EdgeInsets.only(left: Sizes.md, right: Sizes.md, bottom: Sizes.md, top: Sizes.xs),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [ BoxShadow( offset: const Offset(0, -2), blurRadius: 5, color: TColors.dark.withOpacity(0.05),),],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: _isSendingAdminMessage ? null : _sendAdminImageMessage,
              icon: Icon(Iconsax.gallery_add, color: _isSendingAdminMessage ? TColors.light : TColors.primary, size: 28),
              tooltip: 'Gửi ảnh',
            ),
            Expanded(
              child: TextField(
                controller: _adminMessageController,
                enabled: !_isSendingAdminMessage,
                decoration: InputDecoration(
                  hintText: 'Trả lời khách hàng...',
                  border: OutlineInputBorder( borderRadius: BorderRadius.circular(Sizes.buttonRadius * 1.5), borderSide: BorderSide.none, ),
                  filled: true,
                  fillColor: TColors.light,
                  contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.md, vertical: Sizes.sm + 2),
                ),
                keyboardType: TextInputType.multiline, minLines: 1, maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (_adminMessageController.text.trim().isNotEmpty) {
                    _sendAdminTextMessage();
                  }
                },
              ),
            ),
            const SizedBox(width: Sizes.xs),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(Sizes.buttonRadius * 2),
              child: InkWell(
                onTap: _isSendingAdminMessage ? null : _sendAdminTextMessage,
                borderRadius: BorderRadius.circular(Sizes.buttonRadius * 2),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: _isSendingAdminMessage ? null : LinearGradient( colors: [TColors.primary, TColors.primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight, ),
                    color: _isSendingAdminMessage ? TColors.dark : null,
                    borderRadius: BorderRadius.circular(Sizes.buttonRadius * 2),
                  ),
                  padding: const EdgeInsets.all(Sizes.sm + 2),
                  child: _isSendingAdminMessage
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: TColors.textSecondary, strokeWidth: 2.5))
                      : const Icon(Iconsax.send_1, color: TColors.primary, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}