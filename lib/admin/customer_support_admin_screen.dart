import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show QueryDocumentSnapshot, Timestamp;

// Import Services and Models
import '../../core/service/AuthService.dart';
import '../../core/service/ChatService.dart';
import '../../core/service/ConfigService.dart';
import '../../models/message.dart';
import '../../models/conversation_summary.dart';

// Import style utils
import '../../utils/colors.dart';
import '../../utils/sizes.dart';
import 'package:iconsax/iconsax.dart';

class CustomerSupportAdminScreen extends StatefulWidget {
  const CustomerSupportAdminScreen({super.key});

  @override
  State<CustomerSupportAdminScreen> createState() =>
      _CustomerSupportAdminScreenState();
}

class _CustomerSupportAdminScreenState
    extends State<CustomerSupportAdminScreen> {
  // ... (các biến state giữ nguyên) ...
  final AuthService _authService = AuthService();
  final ConfigService _configService = ConfigService();
  late final ChatService _chatService;

  final TextEditingController _adminMessageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  User? _currentAdminUser;
  String? _adminUidForVerification;

  late Future<void> _initializePageFuture;

  ConversationSummary? _selectedConversation;
  String? _selectedConversationUserId;

  bool _isSendingAdminMessage = false;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(configService: _configService);
    _initializePageFuture = _initializePageDependencies();
  }

  Future<void> _initializePageDependencies() async {
    try {
      _currentAdminUser = _authService.getCurrentUser();
      if (_currentAdminUser == null) {
        throw Exception(
          "Access Denied: You must be logged in.",
        );
      }
      _adminUidForVerification = await _configService.getAdminUid();
      if (_adminUidForVerification == null ||
          _adminUidForVerification!.isEmpty) {
        throw Exception(
          "Admin UID configuration error.",
        );
      }
      if (_currentAdminUser!.uid != _adminUidForVerification) {
        throw Exception(
          "Access Denied: Not authorized.",
        );
      }
    } catch (e) {
      print(
        "CustomerSupportAdminScreen: Error initializing: $e",
      );
      rethrow;
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
        _selectedConversationUserId == null ||
        _currentAdminUser == null) {
      return;
    }
    if (mounted) setState(() => _isSendingAdminMessage = true);
    try {
      await _chatService.sendAdminMessage(
        targetUserUid: _selectedConversationUserId!,
        text: _adminMessageController.text.trim(),
      );
      _adminMessageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gửi tin nhắn thất bại: ${e.toString()}"),
            backgroundColor: TColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingAdminMessage = false);
    }
  }

  Future<void> _sendAdminImageMessage() async {
    if (_isSendingAdminMessage ||
        _selectedConversationUserId == null ||
        _currentAdminUser == null) {
      return;
    }
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery, imageQuality: 70, maxWidth: 1080, maxHeight: 1920,
    );
    if (pickedFile == null) return;
    if (mounted) setState(() => _isSendingAdminMessage = true);
    try {
      File imageFile = File(pickedFile.path);
      if (await imageFile.length() > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ảnh quá lớn (tối đa 5MB)."), backgroundColor: TColors.warning),
          );
        }
      } else {
        await _chatService.sendAdminMessage(
          targetUserUid: _selectedConversationUserId!, imageFile: imageFile,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gửi ảnh thất bại: ${e.toString()}"), backgroundColor: TColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingAdminMessage = false);
    }
  }

  void _scrollToChatBottom({int delayMilliseconds = 100, bool animate = true}) {
    if (_selectedConversationUserId != null &&
        mounted &&
        _chatScrollController.hasClients) {
      Future.delayed(Duration(milliseconds: delayMilliseconds), () {
        if (mounted &&
            _chatScrollController.hasClients &&
            _chatScrollController.position.maxScrollExtent > 0.0) {
          if (animate) {
            _chatScrollController.animateTo(
              _chatScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            _chatScrollController.jumpTo(
              _chatScrollController.position.maxScrollExtent,
            );
          }
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Sử dụng màu nền trắng kem
    return Scaffold(
      backgroundColor: TColors.creamyWhite,
      body: FutureBuilder<void>(
        future: _initializePageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: TColors.primary));
          }

          if (snapshot.hasError || _currentAdminUser == null) {
            return Scaffold(
              backgroundColor: TColors.creamyWhite,
              appBar: AppBar(
                title: const Text('Lỗi Truy Cập', style: TextStyle(color: TColors.textPrimary)),
                backgroundColor: TColors.creamyWhite,
                elevation: 0,
                iconTheme: const IconThemeData(color: TColors.textPrimary),
                automaticallyImplyLeading: false, // Tùy chỉnh nếu cần nút back
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.warning_2, color: TColors.error, size: Sizes.iconLg * 2),
                      const SizedBox(height: Sizes.md),
                      Text(
                        snapshot.error?.toString().replaceFirst("Exception: ", "") ??
                            "Lỗi không xác định hoặc người dùng không hợp lệ.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: TColors.error, fontSize: Sizes.fontSizeMd),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (_selectedConversation == null || _selectedConversationUserId == null) {
            return _buildConversationsListScaffold(); // Tách ra Scaffold riêng
          } else {
            return _buildChatDetailView(
              _selectedConversation!,
              _selectedConversationUserId!,
            );
          }
        },
      ),
    );
  }

  Widget _buildConversationsListScaffold() {
    return Scaffold(
      backgroundColor: TColors.creamyWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Hỗ Trợ Khách Hàng', style: TextStyle(color: TColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: TColors.creamyWhite,
        elevation: 0.5, // Thêm một chút shadow nhẹ cho appbar
        centerTitle: true,
      ),
      body: _buildConversationsList(),
    );
  }

  Widget _buildConversationsList() {
    final textTheme = Theme.of(context).textTheme;
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _chatService.getUserConversationsStreamForAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: TColors.primary));
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.md),
              child: Text('Lỗi tải danh sách trò chuyện: ${snapshot.error}', style: const TextStyle(color: TColors.error)),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có cuộc trò chuyện nào.', style: TextStyle(color: TColors.textSecondary, fontSize: Sizes.fontSizeMd)));
        }

        final conversations = snapshot.data!
            .map((doc) => ConversationSummary.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList()
          ..sort((a, b) {
            if (a.adminUnread && !b.adminUnread) return -1;
            if (!a.adminUnread && b.adminUnread) return 1;
            return b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp);
          });

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: Sizes.sm),
          itemCount: conversations.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 0.5, // Làm mỏng divider
            indent: Sizes.md + 56 + Sizes.sm, // (padding ngang + avatar radius*2 + padding sau avatar)
            endIndent: Sizes.md,
            color: TColors.border.withOpacity(0.5),
          ),
          itemBuilder: (context, index) {
            final convo = conversations[index];
            return Material( // Thêm Material để có hiệu ứng ripple khi nhấn
              color: TColors.creamyWhite, // Hoặc TColors.lightSurface nếu muốn card riêng biệt
              child: InkWell(
                onTap: () => _selectConversation(convo),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.md, vertical: Sizes.sm + 2),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: convo.adminUnread ? TColors.primary.withOpacity(0.15) : TColors.accent.withOpacity(0.5),
                        child: Text(
                          convo.userName != null && convo.userName!.isNotEmpty
                              ? convo.userName![0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: convo.adminUnread ? TColors.primary : TColors.textPrimary.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                            fontSize: Sizes.fontSizeLg,
                          ),
                        ),
                      ),
                      const SizedBox(width: Sizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              convo.userName ?? 'Khách hàng ẩn danh',
                              style: (textTheme.titleMedium ?? const TextStyle(fontSize: Sizes.fontSizeMd, color: TColors.textPrimary))
                                  .copyWith(
                                fontWeight: convo.adminUnread ? FontWeight.bold : FontWeight.w600, // W600 cho tên
                                color: convo.adminUnread ? TColors.primary : TColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: Sizes.xs / 2),
                            Text(
                              convo.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: (textTheme.bodyMedium ?? const TextStyle(fontSize: Sizes.fontSizeSm, color: TColors.textSecondary))
                                  .copyWith(
                                color: convo.adminUnread ? TColors.primary.withOpacity(0.9) : TColors.textSecondary,
                                fontWeight: convo.adminUnread ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Sizes.sm),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            convo.lastMessageTimestamp.seconds > 0
                                ? DateFormat('HH:mm', 'vi_VN').format(convo.lastMessageTimestamp.toDate())
                                : '--:--',
                            style: (textTheme.bodySmall ?? const TextStyle(fontSize: Sizes.fontSizeXl, color: TColors.textSecondary))
                                .copyWith(color: TColors.textSecondary.withOpacity(0.8)),
                          ),
                          const SizedBox(height: Sizes.xs),
                          if (convo.adminUnread)
                            Container(
                              padding: const EdgeInsets.all(Sizes.xs + 1), // Điều chỉnh kích thước chấm đỏ
                              decoration: const BoxDecoration(
                                color: TColors.unreadIndicator,
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const SizedBox(height: Sizes.sm + 1), // Giữ cân bằng chiều cao
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatDetailView(ConversationSummary conversation, String targetUserId) {
    final textTheme = Theme.of(context).textTheme;
    // Nền của chat detail vẫn là creamyWhite
    return Column(
      children: [
        // AppBar tùy chỉnh cho chat detail
        Material(
          elevation: 0.5, // Shadow nhẹ cho appbar
          color: TColors.creamyWhite, // Giữ màu nền đồng nhất
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + Sizes.xs,
              bottom: Sizes.sm,
              left: Sizes.sm,
              right: Sizes.md,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.arrow_left_2, color: TColors.textPrimary, size: Sizes.iconMd),
                  onPressed: _closeChatDetail,
                  tooltip: 'Quay lại',
                ),
                CircleAvatar(
                  radius: 20, // Kích thước avatar nhỏ hơn trên appbar
                  backgroundColor: TColors.primary.withOpacity(0.15),
                  child: Text(
                    conversation.userName != null && conversation.userName!.isNotEmpty
                        ? conversation.userName![0].toUpperCase()
                        : 'C',
                    style: const TextStyle(color: TColors.primary, fontWeight: FontWeight.bold, fontSize: Sizes.fontSizeMd),
                  ),
                ),
                const SizedBox(width: Sizes.sm),
                Expanded(
                  child: Text(
                    conversation.userName ?? 'Khách hàng',
                    style: (textTheme.titleMedium ?? const TextStyle(fontSize: Sizes.fontSizeLg))
                        .copyWith(color: TColors.textPrimary, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Có thể thêm các action khác ở đây nếu cần (VD: thông tin user)
              ],
            ),
          ),
        ),
        Expanded(
          child: Container( // Thêm Container để có thể trang trí nếu muốn (VD: background khác cho vùng chat)
            color: TColors.creamyWhite, // Hoặc TColors.accent.withOpacity(0.2) để có nền hơi khác
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessagesForSpecificUser(targetUserId),
              builder: (context, streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting &&
                    (!streamSnapshot.hasData || streamSnapshot.data!.isEmpty)) {
                  return const Center(child: CircularProgressIndicator(color: TColors.primary));
                }
                if (streamSnapshot.hasError) {
                  return Center(
                    child: Text('Lỗi tải tin nhắn: ${streamSnapshot.error}', style: const TextStyle(color: TColors.error)),
                  );
                }
                if (!streamSnapshot.hasData || streamSnapshot.data!.isEmpty) {
                  return const Center(child: Text('Bắt đầu cuộc trò chuyện!', style: TextStyle(color: TColors.textSecondary, fontSize: Sizes.fontSizeMd)));
                }

                final messages = streamSnapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToChatBottom());

                return ListView.builder(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.all(Sizes.md),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isAdminMessage = message.senderId == _currentAdminUser!.uid;
                    return _buildAdminChatMessageItem(message, isAdminMessage, textTheme);
                  },
                );
              },
            ),
          ),
        ),
        _buildAdminMessageInputArea(textTheme),
      ],
    );
  }

  Widget _buildAdminChatMessageItem(Message message, bool isAdminMessage, TextTheme textTheme) {
    // Màu sắc tin nhắn
    final messageBgColor = isAdminMessage ? TColors.primary : TColors.lightSurface; // Hoặc TColors.accent
    final messageTextColor = isAdminMessage ? TColors.textWhite : TColors.textPrimary;
    final timeStampColor = TColors.textSecondary.withOpacity(0.8);

    return Align(
      alignment: isAdminMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isAdminMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.symmetric(vertical: Sizes.xs),
            padding: const EdgeInsets.symmetric(vertical: Sizes.sm + 2, horizontal: Sizes.md - 2),
            decoration: BoxDecoration(
              color: messageBgColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(Sizes.borderRadiusMd), // Bo góc đều hơn
                topRight: const Radius.circular(Sizes.borderRadiusMd),
                bottomLeft: Radius.circular(isAdminMessage ? Sizes.borderRadiusMd : Sizes.borderRadiusSm),
                bottomRight: Radius.circular(isAdminMessage ? Sizes.borderRadiusSm : Sizes.borderRadiusMd),
              ),
              boxShadow: [
                BoxShadow(
                  color: TColors.textPrimary.withOpacity(0.03), // Shadow nhẹ hơn
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: message.type == 'image' && message.imageUrl != null && message.imageUrl!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.borderRadiusMd - 4), // Bo góc ảnh bên trong
              child: Image.network(
                message.imageUrl!,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width * 0.65, // Điều chỉnh kích thước ảnh
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: 180, // Chiều cao cố định cho placeholder
                    color: TColors.accent.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2.5,
                        color: TColors.primary.withOpacity(0.7),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: 180,
                    padding: const EdgeInsets.all(Sizes.md),
                    decoration: BoxDecoration(
                        color: TColors.accent.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(Sizes.borderRadiusMd -4)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Iconsax.gallery_slash, color: TColors.error, size: Sizes.iconLg),
                        SizedBox(height: Sizes.sm),
                        Text('Không tải được ảnh', textAlign: TextAlign.center, style: TextStyle(fontSize: Sizes.fontSizeSm, color: TColors.textSecondary)),
                      ],
                    ),
                  );
                },
              ),
            )
                : Text(
              message.text ?? '',
              style: TextStyle(color: messageTextColor, fontSize: Sizes.fontSizeMd -1), // Kích thước chữ tin nhắn
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: isAdminMessage ? 0 : (Sizes.sm - 2),
              right: isAdminMessage ? (Sizes.sm - 2) : 0,
              bottom: Sizes.sm + 2, // Thêm khoảng cách dưới timestamp
            ),
            child: Text(
              message.timestamp.seconds > 0
                  ? DateFormat('HH:mm', 'vi_VN').format(message.timestamp.toDate())
                  : 'Đang gửi...',
              style: (textTheme.bodySmall ?? const TextStyle(fontSize: Sizes.fontSizeXl)).copyWith(color: timeStampColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMessageInputArea(TextTheme textTheme) {
    return Container(
      padding: EdgeInsets.only(
        left: Sizes.md,
        right: Sizes.md,
        top: Sizes.sm,
      ),
      decoration: BoxDecoration(
        color: TColors.creamyWhite,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: TColors.textPrimary.withOpacity(0.04),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: Sizes.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _isSendingAdminMessage ? null : _sendAdminImageMessage,
                icon: Icon(
                  Iconsax.gallery_add,
                  color: _isSendingAdminMessage
                      ? TColors.textSecondary.withOpacity(0.5)
                      : TColors.primary,
                  size: Sizes.iconLg - 2,
                ),
                padding: const EdgeInsets.all(Sizes.sm),
                tooltip: 'Gửi ảnh',
              ),
              const SizedBox(width: Sizes.xs),
              Expanded(
                child: TextField(
                  controller: _adminMessageController,
                  enabled: !_isSendingAdminMessage,
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    hintStyle: TextStyle(
                      color: TColors.textSecondary.withOpacity(0.6),
                      fontSize: Sizes.fontSizeMd - 1,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.borderRadiusLg),
                      borderSide: BorderSide(
                        color: TColors.border.withOpacity(0.7),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.borderRadiusLg),
                      borderSide: BorderSide(
                        color: TColors.border.withOpacity(0.7),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.borderRadiusLg),
                      borderSide: const BorderSide(
                        color: TColors.primary,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: TColors.lightSurface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Sizes.md,
                      vertical: Sizes.sm + 4,
                    ),
                  ),
                  style: const TextStyle(
                    color: TColors.textPrimary,
                    fontSize: Sizes.fontSizeMd - 1,
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (_adminMessageController.text.trim().isNotEmpty) {
                      _sendAdminTextMessage();
                    }
                  },
                ),
              ),
              const SizedBox(width: Sizes.iconXs),
              IconButton(
                onPressed: _isSendingAdminMessage ? null : _sendAdminTextMessage,
                icon: Icon(
                  Iconsax.send_1,
                  color: _isSendingAdminMessage
                      ? TColors.textSecondary.withOpacity(0.5)
                      : TColors.primary,
                  size: Sizes.iconLg - 2,
                ),
                padding: const EdgeInsets.all(Sizes.sm),
                tooltip: 'Gửi tin nhắn',
              ),
            ],
          ),
        ),
      ),
    );
  }

}