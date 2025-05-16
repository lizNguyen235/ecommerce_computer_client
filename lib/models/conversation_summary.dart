import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationSummary {
  final String id; // Document ID của chat trong collection 'chats', cũng là userId của khách hàng
  final String adminId;
  final String userId; // userId của khách hàng
  final String? userName;
  final String? userPhotoUrl;
  final String lastMessage;
  final Timestamp lastMessageTimestamp;
  final String? lastMessageBy; // UID của người gửi tin nhắn cuối
  final bool adminUnread; // Admin đã đọc tin nhắn cuối của user này chưa
  // final bool userUnread; // User đã đọc tin nhắn cuối của admin này chưa (ít quan trọng hơn cho admin view)

  ConversationSummary({
    required this.id,
    required this.adminId,
    required this.userId,
    this.userName,
    this.userPhotoUrl,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    this.lastMessageBy,
    this.adminUnread = false,
    // this.userUnread = false,
  });

  factory ConversationSummary.fromMap(String docId, Map<String, dynamic> data) {
    return ConversationSummary(
      id: docId,
      adminId: data['adminId'] ?? '',
      userId: data['userId'] ?? docId, // Nếu không có userId thì lấy docId
      userName: data['userName'] as String?,
      userPhotoUrl: data['userPhotoUrl'] as String?,
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] as Timestamp? ?? Timestamp.now(),
      lastMessageBy: data['lastMessageBy'] as String?,
      adminUnread: data['adminUnread'] as bool? ?? false,
      // userUnread: data['userUnread'] as bool? ?? false,
    );
  }
}