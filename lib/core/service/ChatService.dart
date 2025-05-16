import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/core/service/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/message.dart'; // Điều chỉnh đường dẫn nếu cần
import './ConfigService.dart'; // Điều chỉnh đường dẫn nếu cần
// import '../models/conversation_summary.dart'; // Nếu bạn có model này cho admin

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = new AuthService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ConfigService _configService;

  ChatService({required ConfigService configService}) : _configService = configService;

  // Helper để lấy adminUid một cách an toàn, ném lỗi nếu không có
  Future<String> _getRequiredAdminUid() async {
    String? adminUid = await _configService.getAdminUid();
    if (adminUid == null || adminUid.isEmpty) {
      throw Exception("Admin UID is not configured or could not be fetched.");
    }
    return adminUid;
  }

  // --- Lấy Stream các tin nhắn cho cuộc trò chuyện của người dùng hiện tại ---
  Stream<List<Message>> getMessagesForCurrentUser() {
    User? currentUser = _auth.getCurrentUser();
    if (currentUser == null) {
      // Hoặc ném lỗi, hoặc trả về stream rỗng tùy theo cách bạn muốn UI xử lý
      print("ChatService: Current user is null, returning empty message stream.");
      return Stream.value([]);
    }

    // Tin nhắn của cuộc trò chuyện giữa user hiện tại và admin
    // được lưu trong document có ID là UID của user hiện tại
    return _firestore
        .collection('chats')
        .doc(currentUser.uid) // Document chat của người dùng hiện tại
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Message.fromDocument(doc)).toList();
      } catch (e) {
        print("Error parsing messages: $e");
        // Có thể trả về danh sách rỗng hoặc ném lỗi để StreamBuilder xử lý
        return [];
      }
    });
  }

  // --- Gửi tin nhắn (text hoặc image) từ User tới Admin ---
  Future<void> sendMessage({
    String? text,
    File? imageFile,
  }) async {
    User? currentUser = _auth.getCurrentUser();
    if (currentUser == null) {
      throw Exception("User not logged in! Cannot send message.");
    }

    final String adminUid = await _getRequiredAdminUid(); // Lấy admin UID

    if ((text == null || text.trim().isEmpty) && imageFile == null) {
      throw Exception("Message text or image must be provided.");
    }

    String senderUid = currentUser.uid;
    String senderDisplayName = currentUser.displayName ?? currentUser.email ?? 'Anonymous User';
    String? senderPhotoUrl = currentUser.photoURL;

    Map<String, dynamic> messageData = {
      'senderId': senderUid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    String messageType;
    String lastMessageContentForChatDoc;

    if (imageFile != null) {
      messageType = 'image';
      lastMessageContentForChatDoc = 'Sent an image'; // Nội dung cho lastMessage
      try {
        String filePath = 'chat_images/${currentUser.uid}/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        UploadTask uploadTask = _storage.ref().child(filePath).putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        messageData['type'] = messageType;
        messageData['imageUrl'] = imageUrl;
      } catch (e) {
        print("ChatService: Error uploading image: ${e.toString()}");
        throw Exception("Failed to upload image: ${e.toString()}");
      }
    } else {
      messageType = 'text';
      messageData['type'] = messageType;
      messageData['text'] = text!.trim(); // Đã kiểm tra text != null ở trên
      lastMessageContentForChatDoc = text.trim();
    }

    try {
      DocumentReference chatDocRef = _firestore.collection('chats').doc(senderUid);

      // Thêm tin nhắn vào subcollection
      await chatDocRef.collection('messages').add(messageData);

      // Cập nhật thông tin cuộc trò chuyện chính (document cha)
      await chatDocRef.set(
        {
          'adminId': adminUid,
          'userId': senderUid, // UID của khách hàng
          'userName': senderDisplayName,
          'userPhotoUrl': senderPhotoUrl,
          'lastMessage': lastMessageContentForChatDoc,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'lastMessageBy': senderUid, // Ai gửi tin nhắn cuối
          'adminUnread': true, // Đánh dấu admin chưa đọc khi user gửi
          'userUnread': false, // User vừa gửi nên không unread cho user
          // 'adminUnreadCount': FieldValue.increment(1), // Tùy chọn dùng counter
        },
        SetOptions(merge: true), // Dùng merge để tạo mới nếu chưa có, hoặc cập nhật
      );

      print("ChatService: Message sent successfully by user ${currentUser.uid}.");
    } catch (e) {
      print("ChatService: Error sending message to Firestore: ${e.toString()}");
      throw Exception("Failed to send message: ${e.toString()}");
    }
  }

  // --- Phương thức gửi tin nhắn TỪ ADMIN TỚI NGƯỜI DÙNG ---
  // Phương thức này sẽ được gọi từ phía Admin App.
  Future<void> sendAdminMessage({
    required String targetUserUid, // UID của người dùng mà admin đang trả lời
    String? text,
    File? imageFile,
  }) async {
    User? adminUser = _auth.getCurrentUser(); // Lấy user hiện tại (phía admin app)
    final String currentAdminUidFromConfig = await _getRequiredAdminUid();

    // Đảm bảo người gửi là admin được chỉ định
    if (adminUser == null || adminUser.uid != currentAdminUidFromConfig) {
      throw Exception("Permission denied. Must be the designated admin to send messages.");
    }

    if ((text == null || text.trim().isEmpty) && imageFile == null) {
      throw Exception("Message text or image must be provided for admin message.");
    }

    String senderUid = adminUser.uid; // UID của Admin

    Map<String, dynamic> messageData = {
      'senderId': senderUid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    String messageType;
    String lastMessageContentForChatDoc;

    if (imageFile != null) {
      messageType = 'image';
      lastMessageContentForChatDoc = 'Admin sent an image';
      try {
        // Lưu ảnh vào thư mục của user, có thể có tiền tố admin để phân biệt
        String filePath = 'chat_images/$targetUserUid/admin_${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        UploadTask uploadTask = _storage.ref().child(filePath).putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        messageData['type'] = messageType;
        messageData['imageUrl'] = imageUrl;
      } catch (e) {
        print("ChatService: Error uploading admin image: ${e.toString()}");
        throw Exception("Failed to upload admin image: ${e.toString()}");
      }
    } else {
      messageType = 'text';
      messageData['type'] = messageType;
      messageData['text'] = text!.trim();
      lastMessageContentForChatDoc = text.trim();
    }

    // Lưu tin nhắn vào subcollection 'messages' của document chat của người dùng targetUserUid
    try {
      DocumentReference chatDocRef = _firestore.collection('chats').doc(targetUserUid);

      await chatDocRef.collection('messages').add(messageData);

      // Cập nhật thông tin cuộc trò chuyện chính
      // Sử dụng merge:true để không ghi đè các trường như userName, userPhotoUrl
      // mà có thể user đã tạo trước đó.
      await chatDocRef.set(
        {
          'adminId': senderUid, // adminId là người gửi (admin)
          'userId': targetUserUid, // userId là người nhận (customer)
          'lastMessage': lastMessageContentForChatDoc,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'lastMessageBy': senderUid, // Admin gửi
          'adminUnread': false, // Admin vừa gửi, không unread cho admin
          'userUnread': true, // Đánh dấu user chưa đọc
          // 'userUnreadCount': FieldValue.increment(1), // Tùy chọn
        },
        SetOptions(merge: true),
      );

      print("ChatService: Admin message sent successfully to user $targetUserUid.");
    } catch (e) {
      print("ChatService: Error sending admin message to Firestore: ${e.toString()}");
      throw Exception("Failed to send admin message: ${e.toString()}");
    }
  }

  // --- Lấy Stream danh sách các cuộc trò chuyện cho Admin ---
  // (Cần model ConversationSummary nếu muốn trả về List<ConversationSummary>)
  Stream<List<QueryDocumentSnapshot>> getUserConversationsStreamForAdmin() {
    // Quyền admin nên được kiểm tra ở nơi gọi hàm này hoặc thông qua Security Rules
    // Ở đây chỉ trả về stream, việc kiểm tra adminUid có thể thực hiện trước khi gọi
    return _firestore
        .collection('chats')
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs); // Trả về List<QueryDocumentSnapshot>
    // Admin UI sẽ map sang ConversationSummary nếu cần
  }

  // --- Lấy Stream tin nhắn cho một user cụ thể (dùng cho Admin view) ---
  Stream<List<Message>> getMessagesForSpecificUser(String userId) {
    // Quyền admin nên được kiểm tra ở nơi gọi
    return _firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Message.fromDocument(doc)).toList();
      } catch (e) {
        print("Error parsing messages for specific user $userId: $e");
        return [];
      }
    });
  }

  // --- Đánh dấu tin nhắn đã đọc bởi user hiện tại ---
  Future<void> markMessagesAsReadByUser() async {
    User? currentUser = _auth.getCurrentUser();
    if (currentUser == null) return;

    DocumentReference chatDocRef = _firestore.collection('chats').doc(currentUser.uid);
    try {
      await chatDocRef.update({'userUnread': false /*, 'userUnreadCount': 0 */});
      print("ChatService: Messages marked as read by user ${currentUser.uid}");
    } catch (e) {
      print("ChatService: Error marking messages as read by user: $e");
      // Không ném lỗi ra ngoài để không làm gián đoạn UI, chỉ log lại
    }
  }

  // --- Đánh dấu tin nhắn đã đọc bởi admin cho một user cụ thể ---
  Future<void> markMessagesAsReadByAdmin(String targetUserUid) async {
    User? adminUser = _auth.getCurrentUser();
    final String currentAdminUidFromConfig = await _getRequiredAdminUid();

    if (adminUser == null || adminUser.uid != currentAdminUidFromConfig) {
      print("ChatService: Attempt to mark messages as read by non-admin or config error.");
      return; // Không thực hiện nếu không phải admin
    }

    DocumentReference chatDocRef = _firestore.collection('chats').doc(targetUserUid);
    try {
      await chatDocRef.update({'adminUnread': false /*, 'adminUnreadCount': 0 */});
      print("ChatService: Messages for user $targetUserUid marked as read by admin ${adminUser.uid}");
    } catch (e) {
      print("ChatService: Error marking messages as read by admin for user $targetUserUid: $e");
    }
  }
}