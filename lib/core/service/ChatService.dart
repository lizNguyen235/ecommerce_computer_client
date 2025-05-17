import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/core/service/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/message.dart'; // Điều chỉnh đường dẫn nếu cần
import './ConfigService.dart'; // Điều chỉnh đường dẫn nếu cần
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb; // For kIsWeb check
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
    dynamic imageData,     // THAY ĐỔI: Có thể là File (mobile) hoặc Uint8List (web)
    String? imageFileName, // THAY ĐỔI: Tên file gốc, quan trọng cho web và contentType
  }) async {
    User? currentUser = _auth.getCurrentUser();
    if (currentUser == null) {
      throw Exception("User not logged in! Cannot send message.");
    }

    final String adminUid = await _getRequiredAdminUid(); // Lấy admin UID

    if ((text == null || text.trim().isEmpty) && imageData == null) {
      throw Exception("Message text or image must be provided.");
    }

    String senderUid = currentUser.uid;
    // Lấy thông tin từ profile Firestore để có tên và avatar chính xác nhất
    // Nếu không có, mới dùng từ Firebase Auth
    String senderDisplayName = currentUser.displayName ?? currentUser.email ?? 'Người dùng ẩn danh';
    String? senderPhotoUrl = currentUser.photoURL;

    // Cố gắng lấy thông tin profile từ Firestore để cập nhật displayName và photoUrl
    try {
      DocumentSnapshot userProfileDoc = await _firestore.collection('users').doc(senderUid).get();
      if (userProfileDoc.exists && userProfileDoc.data() != null) {
        final profileData = userProfileDoc.data() as Map<String, dynamic>;
        senderDisplayName = profileData['fullName'] ?? senderDisplayName;
        senderPhotoUrl = profileData['avatarUrl'] ?? senderPhotoUrl;
      }
    } catch(e) {
      print("ChatService: Could not fetch user profile for display name/photo, using Auth info. Error: $e");
    }


    Map<String, dynamic> messageData = {
      'senderId': senderUid,
      'timestamp': FieldValue.serverTimestamp(),
      // 'readByAdmin': false, // Admin chưa đọc
      // 'readByUser': true,   // User vừa gửi nên đã đọc
    };

    String messageType;
    String lastMessageContentForChatDoc;

    if (imageData != null && imageFileName != null) {
      messageType = 'image';
      lastMessageContentForChatDoc = '[Hình ảnh]'; // Nội dung cho lastMessage
      try {
        // Tạo đường dẫn file trên Firebase Storage
        // Sử dụng imageFileName để có phần mở rộng file gốc
        String storageFileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFileName.replaceAll(RegExp(r'[^\w\.]'), '_')}'; // Sanitize filename
        String filePath = 'chat_images/$senderUid/user_uploads/$storageFileName'; // Phân biệt thư mục user và admin uploads
        Reference ref = _storage.ref().child(filePath);

        UploadTask uploadTask;
        String contentType = 'image/jpeg'; // Mặc định
        if (imageFileName.toLowerCase().endsWith('.png')) {
          contentType = 'image/png';
        } else if (imageFileName.toLowerCase().endsWith('.gif')) {
          contentType = 'image/gif';
        }
        // Thêm các loại khác nếu cần

        final metadata = SettableMetadata(contentType: contentType);

        if (kIsWeb && imageData is Uint8List) {
          uploadTask = ref.putData(imageData, metadata);
        } else if (!kIsWeb && imageData is File) {
          uploadTask = ref.putFile(imageData, metadata);
        } else {
          throw Exception("Invalid image data type or platform mismatch for user message.");
        }

        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        messageData['type'] = messageType;
        messageData['imageUrl'] = imageUrl;
        // Không cần messageData['text'] nếu là tin nhắn ảnh
      } catch (e) {
        print("ChatService: Error uploading user image: ${e.toString()}");
        throw Exception("Failed to upload user image: ${e.toString()}");
      }
    } else {
      messageType = 'text';
      messageData['type'] = messageType;
      messageData['text'] = text!.trim();
      lastMessageContentForChatDoc = text.trim();
      if (lastMessageContentForChatDoc.length > 100) {
        lastMessageContentForChatDoc = '${lastMessageContentForChatDoc.substring(0, 97)}...';
      }
    }

    try {
      // Document chat vẫn dùng senderUid (UID của khách hàng) làm ID
      DocumentReference chatDocRef = _firestore.collection('chats').doc(senderUid);

      // Thêm tin nhắn vào subcollection
      await chatDocRef.collection('messages').add(messageData);

      // Cập nhật thông tin cuộc trò chuyện chính (document cha)
      await chatDocRef.set(
        {
          'adminId': adminUid,             // UID của admin (người nhận tiềm năng)
          'userId': senderUid,             // UID của khách hàng (người gửi)
          'userName': senderDisplayName,   // Tên của khách hàng
          'userPhotoUrl': senderPhotoUrl,  // Ảnh đại diện của khách hàng (nếu có)
          'lastMessage': lastMessageContentForChatDoc,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'lastMessageBy': senderUid,      // Ai gửi tin nhắn cuối (customer uid)
          'adminUnread': true,             // Đánh dấu admin chưa đọc khi user gửi
          'userUnread': false,             // User vừa gửi nên không unread cho user
          // 'adminUnreadCount': FieldValue.increment(1),
          // 'userUnreadCount': 0, // Reset unread count của user
        },
        SetOptions(merge: true), // Dùng merge để tạo mới nếu chưa có, hoặc cập nhật các trường đã có
      );

      print("ChatService: Message sent successfully by user ${currentUser.uid}.");
    } catch (e) {
      print("ChatService: Error sending message to Firestore: ${e.toString()}");
      throw Exception("Failed to send message to Firestore: ${e.toString()}");
    }
  }


  // --- Phương thức gửi tin nhắn TỪ ADMIN TỚI NGƯỜI DÙNG ---
  // Phương thức này sẽ được gọi từ phía Admin App.
  Future<void> sendAdminMessage({
    required String targetUserUid, // UID của người dùng mà admin đang trả lời
    String? text,
    dynamic imageData,     // THAY ĐỔI: Có thể là File (mobile) hoặc Uint8List (web)
    String? imageFileName, // THAY ĐỔI: Tên file gốc, quan trọng cho web và contentType
  }) async {
    User? adminUser = _auth.getCurrentUser();
    final String currentAdminUidFromConfig = await _getRequiredAdminUid();

    if (adminUser == null || adminUser.uid != currentAdminUidFromConfig) {
      throw Exception("Permission denied. Must be the designated admin to send messages.");
    }

    if ((text == null || text.trim().isEmpty) && imageData == null) {
      throw Exception("Message text or image must be provided for admin message.");
    }

    String senderUid = adminUser.uid; // UID của Admin

    Map<String, dynamic> messageData = {
      'senderId': senderUid,
      'timestamp': FieldValue.serverTimestamp(), // Nên dùng serverTimestamp
      // 'readByAdmin': true, // Admin vừa gửi nên đã đọc
      // 'readByUser': false, // User chưa đọc
    };

    String messageType;
    String lastMessageContentForChatDoc;

    if (imageData != null && imageFileName != null) {
      messageType = 'image';
      // Nội dung cho lastMessage nên ngắn gọn khi là ảnh
      lastMessageContentForChatDoc = '[Hình ảnh]'; // Hoặc "Admin đã gửi một hình ảnh"

      try {
        // Đường dẫn file trên Firebase Storage
        // Sử dụng imageFileName để có phần mở rộng file gốc
        String storageFileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFileName.replaceAll(RegExp(r'[^\w\.]'), '_')}'; // Sanitize filename
        String filePath = 'chat_images/$targetUserUid/admin_uploads/$storageFileName';
        Reference ref = _storage.ref().child(filePath);

        UploadTask uploadTask;
        // Xác định ContentType dựa trên phần mở rộng của imageFileName
        String contentType = 'image/jpeg'; // Mặc định
        if (imageFileName.toLowerCase().endsWith('.png')) {
          contentType = 'image/png';
        } else if (imageFileName.toLowerCase().endsWith('.gif')) {
          contentType = 'image/gif';
        }
        // Bạn có thể thêm các loại khác nếu cần

        final metadata = SettableMetadata(contentType: contentType);

        if (kIsWeb && imageData is Uint8List) {
          uploadTask = ref.putData(imageData, metadata);
        } else if (!kIsWeb && imageData is File) {
          uploadTask = ref.putFile(imageData, metadata);
        } else {
          throw Exception("Invalid image data type or platform mismatch.");
        }

        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        messageData['type'] = messageType;
        messageData['imageUrl'] = imageUrl;
        // Không cần messageData['text'] nếu là tin nhắn ảnh, trừ khi bạn muốn có caption
      } catch (e) {
        print("ChatService: Error uploading admin image: ${e.toString()}");
        throw Exception("Failed to upload admin image: ${e.toString()}");
      }
    } else {
      messageType = 'text';
      messageData['type'] = messageType;
      messageData['text'] = text!.trim();
      lastMessageContentForChatDoc = text.trim();
      // Cắt bớt lastMessageContentForChatDoc nếu quá dài
      if (lastMessageContentForChatDoc.length > 100) {
        lastMessageContentForChatDoc = '${lastMessageContentForChatDoc.substring(0, 97)}...';
      }
    }

    // Lưu tin nhắn vào subcollection 'messages' của document chat của người dùng targetUserUid
    try {
      // Tạo DocumentReference cho cuộc trò chuyện
      // ID của document chat chính là UID của người dùng (customer)
      DocumentReference chatDocRef = _firestore.collection('chats').doc(targetUserUid);

      // Thêm tin nhắn mới vào subcollection 'messages'
      await chatDocRef.collection('messages').add(messageData);

      // Cập nhật thông tin cuộc trò chuyện chính (conversation summary)
      // Sử dụng merge:true để không ghi đè các trường như userName, userPhotoUrl
      // mà người dùng có thể đã tạo/cập nhật.
      await chatDocRef.set(
        {
          'adminId': senderUid,          // UID của admin tham gia cuộc trò chuyện
          'userId': targetUserUid,       // UID của người dùng (customer)
          'lastMessage': lastMessageContentForChatDoc,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'lastMessageBy': senderUid,    // Ai là người gửi tin nhắn cuối cùng (admin uid)
          'adminUnread': false,          // Admin vừa gửi, nên không có tin nhắn chưa đọc cho admin
          'userUnread': true,            // Đánh dấu là người dùng (customer) chưa đọc tin nhắn này
          // 'userName': ... // Nên được set khi user bắt đầu chat lần đầu hoặc cập nhật từ profile user
          // 'userPhotoUrl': ... // Tương tự
          // 'adminUnreadCount': 0, // Reset unread count của admin
          // 'userUnreadCount': FieldValue.increment(1), // Tăng unread count của user
        },
        SetOptions(merge: true), // Quan trọng: merge để không ghi đè dữ liệu hiện có
      );

      print("ChatService: Admin message sent successfully to user $targetUserUid.");
    } catch (e) {
      print("ChatService: Error sending admin message to Firestore: ${e.toString()}");
      throw Exception("Failed to send admin message to Firestore: ${e.toString()}");
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