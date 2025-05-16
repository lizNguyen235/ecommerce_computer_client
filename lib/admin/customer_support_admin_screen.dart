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
// Đảm bảo các file này tồn tại và TColors, Sizes được định nghĩa đúng
import '../../utils/colors.dart'; // Nơi TColors được định nghĩa
import '../../utils/sizes.dart'; // Nơi Sizes được định nghĩa (VD: Sizes.md, Sizes.xs)
import 'package:iconsax/iconsax.dart';

class CustomerSupportAdminScreen extends StatefulWidget {
  const CustomerSupportAdminScreen({super.key});

  @override
  State<CustomerSupportAdminScreen> createState() =>
      _CustomerSupportAdminScreenState();
}

class _CustomerSupportAdminScreenState
    extends State<CustomerSupportAdminScreen> {
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
    // _currentAdminUser sẽ được kiểm tra và gán lại trong _initializePageDependencies
    // để đảm bảo tính nhất quán với logic kiểm tra quyền
    _initializePageFuture = _initializePageDependencies();

    // Không cần addPostFrameCallback ở đây nữa, sẽ xử lý trong StreamBuilder của chat
  }

  Future<void> _initializePageDependencies() async {
    try {
      // Gán _currentAdminUser ở đây để đảm bảo nó được cập nhật trước khi kiểm tra
      _currentAdminUser = _authService.getCurrentUser();

      if (_currentAdminUser == null) {
        print("CustomerSupportAdminScreen: No authenticated user found.");
        throw Exception(
          "Access Denied: You must be logged in to view this page.",
        );
      }

      _adminUidForVerification = await _configService.getAdminUid();

      if (_adminUidForVerification == null ||
          _adminUidForVerification!.isEmpty) {
        print("CustomerSupportAdminScreen: Admin UID not configured.");
        throw Exception(
          "Admin UID configuration error. Cannot load admin chat support.",
        );
      }

      if (_currentAdminUser!.uid != _adminUidForVerification) {
        print(
          "CustomerSupportAdminScreen: Access Denied. User UID: ${_currentAdminUser?.uid}, Required Admin UID: $_adminUidForVerification",
        );
        throw Exception(
          "Access Denied: You are not authorized to view this page.",
        );
      }
      print(
        "CustomerSupportAdminScreen: Admin verified. UID: ${_currentAdminUser!.uid}",
      );
    } catch (e) {
      print(
        "CustomerSupportAdminScreen: Error initializing page dependencies: $e",
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
    // Cuộn xuống cuối khi chọn cuộc trò chuyện, sẽ được xử lý bởi StreamBuilder
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
      // Thêm kiểm tra _currentAdminUser
      return;
    }

    if (mounted) setState(() => _isSendingAdminMessage = true);
    try {
      await _chatService.sendAdminMessage(
        targetUserUid: _selectedConversationUserId!,
        text: _adminMessageController.text.trim(),
      );
      _adminMessageController.clear();
      // Cuộn sẽ được xử lý tự động bởi StreamBuilder khi có tin nhắn mới
    } catch (e) {
      print(
        "CustomerSupportAdminScreen: Error sending admin text message: ${e.toString()}",
      );
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
    if (_isSendingAdminMessage ||
        _selectedConversationUserId == null ||
        _currentAdminUser == null) {
      // Thêm kiểm tra _currentAdminUser
      return;
    }

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1080, // Giới hạn kích thước ảnh để giảm dung lượng
      maxHeight: 1920,
    );

    if (pickedFile == null) return;

    if (mounted) setState(() => _isSendingAdminMessage = true);

    try {
      File imageFile = File(pickedFile.path);
      if (await imageFile.length() > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ảnh quá lớn (tối đa 5MB).")),
          );
        }
      } else {
        await _chatService.sendAdminMessage(
          targetUserUid: _selectedConversationUserId!,
          imageFile: imageFile,
        );
        // Cuộn sẽ được xử lý tự động bởi StreamBuilder
      }
    } catch (e) {
      print(
        "CustomerSupportAdminScreen: Error sending admin image message: ${e.toString()}",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gửi ảnh thất bại: ${e.toString()}")),
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
    return FutureBuilder<void>(
      future: _initializePageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || _currentAdminUser == null) {
          // Kiểm tra _currentAdminUser ở đây nữa
          return Scaffold(
            appBar: AppBar(
              title: const Text('Lỗi Truy Cập'),
              automaticallyImplyLeading: false,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  snapshot.error?.toString() ??
                      "Lỗi không xác định hoặc người dùng không hợp lệ.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
          );
        }

        if (_selectedConversation == null ||
            _selectedConversationUserId == null) {
          return Scaffold(body: _buildConversationsList());
        } else {
          return _buildChatDetailView(
            _selectedConversation!,
            _selectedConversationUserId!,
          );
        }
      },
    );
  }

  Widget _buildConversationsList() {
    final textTheme = Theme.of(context).textTheme;
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _chatService.getUserConversationsStreamForAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi tải danh sách trò chuyện: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có cuộc trò chuyện nào.'));
        }

        final conversations =
            snapshot.data!
                .map(
                  (doc) => ConversationSummary.fromMap(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList()
              // Sắp xếp: chưa đọc lên đầu, sau đó theo thời gian mới nhất
              ..sort((a, b) {
                if (a.adminUnread && !b.adminUnread) return -1;
                if (!a.adminUnread && b.adminUnread) return 1;
                return b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp);
              });

        return ListView.separated(
          itemCount: conversations.length,
          separatorBuilder:
              (context, index) =>
                  const Divider(height: 1, indent: 72, endIndent: 16),
          itemBuilder: (context, index) {
            final convo = conversations[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Sizes.md, // Giả sử Sizes.md là double không null
                vertical: Sizes.xs, // Giả sử Sizes.xs là double không null
              ),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: TColors.primary.withOpacity(0.1),
                child: Text(
                  convo.userName != null && convo.userName!.isNotEmpty
                      ? convo.userName![0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: TColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              title: Text(
                convo.userName ?? 'Khách hàng ẩn danh',
                style: (textTheme.titleMedium ??
                        const TextStyle(fontSize: 16, color: TColors.dark))
                    .copyWith(
                      fontWeight:
                          convo.adminUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color: convo.adminUnread ? TColors.primary : TColors.dark,
                    ),
              ),
              subtitle: Text(
                convo.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (textTheme.bodySmall ??
                        const TextStyle(fontSize: 12, color: Colors.grey))
                    .copyWith(
                      color:
                          convo.adminUnread
                              ? TColors.primary.withOpacity(0.8)
                              : Colors.grey[600],
                    ),
              ),
              trailing: IntrinsicWidth(
                // Bọc Column bằng IntrinsicWidth
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min, // Vẫn giữ lại
                  children: [
                    Text(
                      convo.lastMessageTimestamp.seconds > 0
                          ? DateFormat(
                            'HH:mm',
                          ).format(convo.lastMessageTimestamp.toDate())
                          : '--:--',
                      style:
                          textTheme.labelSmall ??
                          const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    if (convo.adminUnread)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      const SizedBox(height: 16), // Tương tự như trên
                  ],
                ),
              ),
              onTap: () => _selectConversation(convo),
            );
          },
        );
      },
    );
  }

  Widget _buildChatDetailView(
    ConversationSummary conversation,
    String targetUserId,
  ) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final textTheme = theme.textTheme;

    // _currentAdminUser đã được kiểm tra là không null ở FutureBuilder
    // nhưng nếu muốn an toàn hơn, có thể thêm `if (_currentAdminUser == null) return SizedBox.shrink();` ở đầu
    // Tuy nhiên, nó sẽ không bao giờ xảy ra nếu FutureBuilder hoạt động đúng.

    return Column(
      children: [
        Material(
          elevation: 1.0,
          color: appBarTheme.backgroundColor ?? theme.colorScheme.surface,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + (Sizes.xs),
              bottom: Sizes.xs,
              left: Sizes.xs,
              right: Sizes.sm,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Iconsax.arrow_left_2,
                    color: appBarTheme.iconTheme?.color ?? TColors.dark,
                  ),
                  onPressed: _closeChatDetail,
                  tooltip: 'Quay lại danh sách',
                ),
                CircleAvatar(
                  backgroundColor: TColors.primary.withOpacity(0.1),
                  child: Text(
                    conversation.userName != null &&
                            conversation.userName!.isNotEmpty
                        ? conversation.userName![0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: TColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: Sizes.sm),
                Expanded(
                  child: Text(
                    conversation.userName ?? 'Khách hàng',
                    style: (textTheme.titleMedium ??
                            const TextStyle(fontSize: 16))
                        .copyWith(
                          color:
                              appBarTheme.titleTextStyle?.color ?? TColors.dark,
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Message>>(
            stream: _chatService.getMessagesForSpecificUser(targetUserId),
            builder: (context, streamSnapshot) {
              if (streamSnapshot.connectionState == ConnectionState.waiting &&
                  (!streamSnapshot.hasData || streamSnapshot.data!.isEmpty)) {
                return const Center(child: CircularProgressIndicator());
              }
              if (streamSnapshot.hasError) {
                return Center(
                  child: Text('Lỗi tải tin nhắn: ${streamSnapshot.error}'),
                );
              }
              if (!streamSnapshot.hasData || streamSnapshot.data!.isEmpty) {
                return const Center(child: Text('Chưa có tin nhắn nào.'));
              }

              final messages = streamSnapshot.data!;
              // Cuộn xuống cuối mỗi khi có tin nhắn mới hoặc danh sách được build lại
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToChatBottom(),
              );

              return ListView.builder(
                controller: _chatScrollController,
                padding: const EdgeInsets.all(Sizes.md),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  // _currentAdminUser chắc chắn không null ở đây
                  final bool isAdminMessage =
                      message.senderId == _currentAdminUser!.uid;
                  return _buildAdminChatMessageItem(
                    message,
                    isAdminMessage,
                    textTheme,
                  );
                },
              );
            },
          ),
        ),
        _buildAdminMessageInputArea(textTheme),
      ],
    );
  }

  Widget _buildAdminChatMessageItem(
    Message message,
    bool isAdminMessage,
    TextTheme textTheme,
  ) {
    return Align(
      alignment: isAdminMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isAdminMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 14.0,
            ),
            decoration: BoxDecoration(
              color: isAdminMessage ? TColors.primary : TColors.light,
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
                ),
              ],
            ),
            child:
                message.type == 'image' &&
                        message.imageUrl != null &&
                        message.imageUrl!.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        message.imageUrl!,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.6,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            // Sử dụng SizedBox để có kích thước cố định cho placeholder
                            width:
                                MediaQuery.of(context).size.width *
                                0.6, // Giữ chiều rộng
                            height: 150, // Chiều cao tạm thời cho placeholder
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                strokeWidth: 3,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.all(Sizes.md),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.gallery_slash,
                                  color: Colors.redAccent,
                                  size: 40,
                                ),
                                SizedBox(height: Sizes.xs),
                                Text(
                                  'Không tải được ảnh',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: TColors.dark,
                                  ),
                                ),
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
                            isAdminMessage
                                ? TColors.textWhite
                                : TColors
                                    .textPrimary, // Sử dụng TColors.textPrimary
                        fontSize: 15,
                      ),
                    ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: isAdminMessage ? 0 : (Sizes.xs),
              right: isAdminMessage ? (Sizes.xs) : 0,
              bottom: Sizes.sm,
            ),
            child: Text(
              message.timestamp.seconds > 0
                  ? DateFormat('HH:mm').format(message.timestamp.toDate())
                  : 'Đang gửi...',
              style: (textTheme.labelSmall ?? const TextStyle(fontSize: 10))
                  .copyWith(
                    color: TColors.textSecondary,
                  ), // Sử dụng TColors.textSecondary
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMessageInputArea(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.only(
        left: Sizes.md,
        right: Sizes.md,
        bottom: Sizes.md,
        top: Sizes.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 5,
            color: TColors.dark.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: _isSendingAdminMessage ? null : _sendAdminImageMessage,
              icon: Icon(
                Iconsax.gallery_add,
                color:
                    _isSendingAdminMessage
                        ? TColors.textSecondary.withOpacity(0.5)
                        : TColors.primary,
                size: 28,
              ),
              tooltip: 'Gửi ảnh',
            ),
            Expanded(
              child: TextField(
                controller: _adminMessageController,
                enabled: !_isSendingAdminMessage,
                decoration: InputDecoration(
                  hintText: 'Trả lời khách hàng...',
                  hintStyle: TextStyle(
                    color: TColors.textSecondary.withOpacity(0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Sizes.buttonRadius * 1.5,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: TColors.light,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Sizes.md,
                    vertical: Sizes.sm + 2, // Đảm bảo Sizes.sm được định nghĩa
                  ),
                ),
                style: const TextStyle(color: TColors.textPrimary),
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
            const SizedBox(width: Sizes.xs),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(
                Sizes.buttonRadius * 2,
              ), // Đảm bảo Sizes.buttonRadius được định nghĩa
              child: InkWell(
                onTap: _isSendingAdminMessage ? null : _sendAdminTextMessage,
                borderRadius: BorderRadius.circular(Sizes.buttonRadius * 2),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient:
                        _isSendingAdminMessage
                            ? null
                            : LinearGradient(
                              colors: [
                                TColors.primary,
                                TColors.primary.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                    color:
                        _isSendingAdminMessage
                            ? TColors.dark.withOpacity(0.5)
                            : null,
                    borderRadius: BorderRadius.circular(Sizes.buttonRadius * 2),
                  ),
                  padding: const EdgeInsets.all(Sizes.sm + 2),
                  child:
                      _isSendingAdminMessage
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color:
                                  TColors
                                      .textWhite, // Đổi màu cho dễ nhìn trên nền tối
                              strokeWidth: 2.5,
                            ),
                          )
                          : const Icon(
                            Iconsax.send_1,
                            color: TColors.textWhite,
                            size: 24,
                          ), // Đổi màu icon gửi thành trắng
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
