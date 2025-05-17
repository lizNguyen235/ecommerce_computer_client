import 'dart:io';
import 'dart:typed_data'; // Cho Uint8List
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show QueryDocumentSnapshot;

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

// Giả sử bạn định nghĩa semibold ở đâu đó, ví dụ:
// const String semibold = 'YourFontFamily-SemiBold'; // Thay thế bằng tên font thực tế của bạn

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
    _initializePageFuture = _initializePageDependencies();
  }

  Future<void> _initializePageDependencies() async {
    try {
      _currentAdminUser = _authService.getCurrentUser();
      if (_currentAdminUser == null) {
        throw Exception("Truy cập bị từ chối: Bạn phải đăng nhập.");
      }
      _adminUidForVerification = await _configService.getAdminUid();
      if (_adminUidForVerification == null || _adminUidForVerification!.isEmpty) {
        throw Exception("Lỗi cấu hình Admin UID.");
      }
      if (_currentAdminUser!.uid != _adminUidForVerification) {
        throw Exception("Truy cập bị từ chối: Không có quyền.");
      }
    } catch (e) {
      print("CustomerSupportAdminScreen: Lỗi khởi tạo: $e");
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
    _scrollToChatBottom(delayMilliseconds: 200, animate: false);
  }

  void _closeChatDetail() {
    if (!mounted) return;
    setState(() {
      _selectedConversation = null;
      _selectedConversationUserId = null;
    });
  }

  Future<void> _sendAdminTextMessage() async {
    final text = _adminMessageController.text.trim();
    if (text.isEmpty || _isSendingAdminMessage || _selectedConversationUserId == null || _currentAdminUser == null) {
      return;
    }
    if (mounted) setState(() => _isSendingAdminMessage = true);
    try {
      await _chatService.sendAdminMessage(
        targetUserUid: _selectedConversationUserId!,
        text: text,
      );
      _adminMessageController.clear();
      _scrollToChatBottom();
    } catch (e) {
      _showErrorSnackBar("Gửi tin nhắn thất bại: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isSendingAdminMessage = false);
    }
  }

  Future<void> _sendAdminImageMessage() async {
    if (_isSendingAdminMessage || _selectedConversationUserId == null || _currentAdminUser == null) {
      return;
    }
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery, imageQuality: 70, maxWidth: 1080, maxHeight: 1920,
    );
    if (pickedFile == null) return;
    if (mounted) setState(() => _isSendingAdminMessage = true);

    try {
      dynamic imageData;
      String imageFileName = pickedFile.name;

      if (kIsWeb) {
        imageData = await pickedFile.readAsBytes();
        if (imageData.length > 5 * 1024 * 1024) {
          _showWarningSnackBar("Ảnh quá lớn (tối đa 5MB).");
          if (mounted) setState(() => _isSendingAdminMessage = false);
          return;
        }
      } else {
        File imageFile = File(pickedFile.path);
        if (await imageFile.length() > 5 * 1024 * 1024) {
          _showWarningSnackBar("Ảnh quá lớn (tối đa 5MB).");
          if (mounted) setState(() => _isSendingAdminMessage = false);
          return;
        }
        imageData = imageFile;
      }

      await _chatService.sendAdminMessage(
        targetUserUid: _selectedConversationUserId!,
        imageData: imageData,
        imageFileName: imageFileName,
      );
      _scrollToChatBottom();
    } catch (e) {
      _showErrorSnackBar("Gửi ảnh thất bại: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isSendingAdminMessage = false);
    }
  }

  void _scrollToChatBottom({int delayMilliseconds = 100, bool animate = true}) {
    if (_selectedConversationUserId != null && mounted && _chatScrollController.hasClients) {
      Future.delayed(Duration(milliseconds: delayMilliseconds), () {
        if (mounted && _chatScrollController.hasClients && _chatScrollController.position.maxScrollExtent > 0.0) {
          if (animate) {
            _chatScrollController.animateTo(
              _chatScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300), curve: Curves.easeOut,
            );
          } else {
            _chatScrollController.jumpTo(_chatScrollController.position.maxScrollExtent);
          }
        }
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: TColors.error, behavior: SnackBarBehavior.floating),
    );
  }

  void _showWarningSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: TColors.warning, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                backgroundColor: TColors.creamyWhite, elevation: 0,
                iconTheme: const IconThemeData(color: TColors.textPrimary), automaticallyImplyLeading: false,
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.warning_2, color: TColors.error, size: Sizes.iconLg * 2.5),
                      const SizedBox(height: Sizes.md),
                      Text(
                        snapshot.error?.toString().replaceFirst("Exception: ", "") ?? "Lỗi hoặc người dùng không hợp lệ.",
                        textAlign: TextAlign.center, style: const TextStyle(color: TColors.error, fontSize: Sizes.fontSizeMd),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          if (_selectedConversation == null || _selectedConversationUserId == null) {
            return _buildConversationsListScaffold();
          } else {
            return _buildChatDetailView(_selectedConversation!, _selectedConversationUserId!);
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
        backgroundColor: TColors.creamyWhite, elevation: 0.5, centerTitle: true,
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
          return Center(child: Padding(padding: const EdgeInsets.all(Sizes.md), child: Text('Lỗi tải DS: ${snapshot.error}', style: const TextStyle(color: TColors.error))));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Chưa có cuộc trò chuyện nào.', style: TextStyle(color: TColors.textSecondary, fontSize: Sizes.fontSizeMd)));
        }
        final conversations = snapshot.data!.map((doc) => ConversationSummary.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList()
          ..sort((a, b) {
            if (a.adminUnread && !b.adminUnread) return -1;
            if (!a.adminUnread && b.adminUnread) return 1;
            return b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp);
          });
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: Sizes.sm),
          itemCount: conversations.length,
          separatorBuilder: (context, index) => Divider(height: 1, thickness: 0.5, indent: Sizes.md + 56 + Sizes.sm, endIndent: Sizes.md, color: TColors.border.withOpacity(0.5)),
          itemBuilder: (context, index) {
            final convo = conversations[index];
            return Material(
              color: TColors.creamyWhite,
              child: InkWell(
                onTap: () => _selectConversation(convo),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.md, vertical: Sizes.sm + 2),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28, backgroundColor: convo.adminUnread ? TColors.primary.withOpacity(0.15) : TColors.accent.withOpacity(0.5),
                        child: Text(
                          convo.userName != null && convo.userName!.isNotEmpty ? convo.userName![0].toUpperCase() : 'U',
                          style: TextStyle(color: convo.adminUnread ? TColors.primary : TColors.textPrimary.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: Sizes.fontSizeLg),
                        ),
                      ),
                      const SizedBox(width: Sizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(convo.userName ?? 'Khách hàng', style: textTheme.titleMedium?.copyWith(fontWeight: convo.adminUnread ? FontWeight.bold : FontWeight.w600, color: convo.adminUnread ? TColors.primary : TColors.textPrimary)),
                            const SizedBox(height: Sizes.xs / 2),
                            Text(convo.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.bodyMedium?.copyWith(color: convo.adminUnread ? TColors.primary.withOpacity(0.9) : TColors.textSecondary, fontWeight: convo.adminUnread ? FontWeight.w500 : FontWeight.normal)),
                          ],
                        ),
                      ),
                      const SizedBox(width: Sizes.sm),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(convo.lastMessageTimestamp.seconds > 0 ? DateFormat('HH:mm', 'vi_VN').format(convo.lastMessageTimestamp.toDate()) : '--:--', style: textTheme.bodySmall?.copyWith(color: TColors.textSecondary.withOpacity(0.8))),
                          const SizedBox(height: Sizes.xs),
                          if (convo.adminUnread) Container(width: Sizes.sm, height: Sizes.sm, decoration: const BoxDecoration(color: TColors.unreadIndicator, shape: BoxShape.circle))
                          else const SizedBox(width: Sizes.sm, height: Sizes.sm),
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
    return Column(
      children: [
        Material(
          elevation: 0.5, color: TColors.creamyWhite,
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + Sizes.xs, bottom: Sizes.sm, left: Sizes.sm, right: Sizes.md),
            child: Row(
              children: [
                IconButton(icon: const Icon(Iconsax.arrow_left_2, color: TColors.textPrimary, size: Sizes.iconMd), onPressed: _closeChatDetail, tooltip: 'Quay lại'),
                CircleAvatar(radius: 20, backgroundColor: TColors.primary.withOpacity(0.15), child: Text(conversation.userName != null && conversation.userName!.isNotEmpty ? conversation.userName![0].toUpperCase() : 'C', style: const TextStyle(color: TColors.primary, fontWeight: FontWeight.bold, fontSize: Sizes.fontSizeMd))),
                const SizedBox(width: Sizes.sm),
                Expanded(child: Text(conversation.userName ?? 'Khách hàng', style: textTheme.titleMedium?.copyWith(color: TColors.textPrimary, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: TColors.creamyWhite,
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getMessagesForSpecificUser(targetUserId),
              builder: (context, streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting && (!streamSnapshot.hasData || streamSnapshot.data!.isEmpty)) {
                  return const Center(child: CircularProgressIndicator(color: TColors.primary));
                }
                if (streamSnapshot.hasError) {
                  return Center(child: Text('Lỗi tải tin nhắn: ${streamSnapshot.error}', style: const TextStyle(color: TColors.error)));
                }
                if (!streamSnapshot.hasData || streamSnapshot.data!.isEmpty) {
                  return const Center(child: Text('Bắt đầu cuộc trò chuyện!', style: TextStyle(color: TColors.textSecondary, fontSize: Sizes.fontSizeMd)));
                }
                final messages = streamSnapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToChatBottom(delayMilliseconds: 50, animate: messages.length > 10));
                return ListView.builder(
                  controller: _chatScrollController, padding: const EdgeInsets.all(Sizes.md), itemCount: messages.length,
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
    final messageBgColor = isAdminMessage ? TColors.primary : TColors.lightSurface;
    final messageTextColor = isAdminMessage ? TColors.textWhite : TColors.textPrimary;
    final timeStampColor = TColors.textSecondary.withOpacity(0.8);

    return Align(
      alignment: isAdminMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isAdminMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.symmetric(vertical: Sizes.xs + 1),
            padding: const EdgeInsets.symmetric(vertical: Sizes.sm + 2, horizontal: Sizes.md - 2),
            decoration: BoxDecoration(
              color: messageBgColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(Sizes.borderRadiusMd), topRight: const Radius.circular(Sizes.borderRadiusMd),
                bottomLeft: Radius.circular(isAdminMessage ? Sizes.borderRadiusMd : Sizes.borderRadiusMd),
                bottomRight: Radius.circular(isAdminMessage ? Sizes.borderRadiusMd : Sizes.borderRadiusMd),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 2, offset: const Offset(0, 1))],
            ),
            child: message.type == 'image' && message.imageUrl != null && message.imageUrl!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.borderRadiusMd - 4), // Bo góc cho ảnh
              child: ConstrainedBox( // SỬA Ở ĐÂY: Bọc Image.network bằng ConstrainedBox
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Image.network(
                  message.imageUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: TColors.lightContainer,
                      child: Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null, strokeWidth: 2, color: TColors.primary)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(Sizes.md),
                      decoration: BoxDecoration(color: TColors.lightContainer, borderRadius: BorderRadius.circular(Sizes.borderRadiusMd - 4)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Iconsax.gallery_slash, color: TColors.dark, size: Sizes.iconLg),
                          SizedBox(height: Sizes.sm),
                          Text('Lỗi ảnh', textAlign: TextAlign.center, style: TextStyle(fontSize: Sizes.fontSizeSm, color: TColors.textSecondary)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
                : Text(message.text ?? '', style: TextStyle(color: messageTextColor, fontSize: Sizes.fontSizeMd - 1)),
          ),
          Padding(
            padding: EdgeInsets.only(left: isAdminMessage ? 0 : (Sizes.sm - 2), right: isAdminMessage ? (Sizes.sm - 2) : 0, bottom: Sizes.sm),
            child: Text(
              message.timestamp.seconds > 0 ? DateFormat('HH:mm', 'vi_VN').format(message.timestamp.toDate()) : 'Đang gửi...',
              style: textTheme.bodySmall?.copyWith(color: timeStampColor, fontSize: Sizes.fontSizeSm - 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMessageInputArea(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.only(left: Sizes.md, right: Sizes.sm, top: Sizes.sm, bottom: Sizes.sm),
      decoration: BoxDecoration(color: TColors.creamyWhite, boxShadow: [BoxShadow(offset: const Offset(0, -1), blurRadius: 4, color: Colors.black.withOpacity(0.03))]),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: _isSendingAdminMessage ? null : _sendAdminImageMessage,
              icon: Icon(Iconsax.gallery_add, color: _isSendingAdminMessage ? TColors.dark : TColors.primary, size: Sizes.iconLg -1),
              padding: const EdgeInsets.all(Sizes.sm -2), tooltip: 'Gửi ảnh',
            ),
            Expanded(
              child: TextField(
                controller: _adminMessageController, enabled: !_isSendingAdminMessage,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn của bạn...',
                  hintStyle: TextStyle(color: TColors.textSecondary.withOpacity(0.7), fontSize: Sizes.fontSizeMd -1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(Sizes.inputFieldRadius), borderSide: BorderSide(color: TColors.border.withOpacity(0.5))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Sizes.inputFieldRadius), borderSide: BorderSide(color: TColors.border.withOpacity(0.5))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Sizes.inputFieldRadius), borderSide: const BorderSide(color: TColors.primary, width: 1.2)),
                  filled: true, fillColor: TColors.lightSurface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.md -2, vertical: Sizes.sm + 2),
                  isDense: true,
                ),
                style: const TextStyle(color: TColors.textPrimary, fontSize: Sizes.fontSizeMd -1),
                keyboardType: TextInputType.multiline, minLines: 1, maxLines: 4, textInputAction: TextInputAction.newline,
              ),
            ),
            IconButton(
              onPressed: _sendAdminTextMessage,
              color: TColors.primary,
              icon: Icon(Iconsax.send_1, color: (_isSendingAdminMessage || _adminMessageController.text.trim().isEmpty) ? TColors.dark : TColors.primary, size: Sizes.iconLg -1),
              padding: const EdgeInsets.all(Sizes.sm -2), tooltip: 'Gửi tin nhắn',
            ),
          ],
        ),
      ),
    );
  }
}