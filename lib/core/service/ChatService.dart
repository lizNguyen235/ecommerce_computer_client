import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/core/service/ConfigService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ConfigService _configService = ConfigService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // !!! QUAN TRỌNG: UID của Admin được chỉ định !!!
  // Thay thế bằng UID admin thật. Nên lấy từ config document trong Firestore trong ứng dụng thực tế.
  final String _adminUid; // UID của admin được chỉ định
  ChatService(this._adminUid); // Constructor để khởi tạo adminUid
  // --- Lấy Stream các tin nhắn cho cuộc trò chuyện của người dùng hiện tại ---
  Stream<List<Message>> getMessagesForCurrentUser() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('chats')
        .doc(currentUser.uid) // Document chat của người dùng hiện tại
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromDocument(doc)).toList();
    });
  }

  // --- Gửi tin nhắn (text hoặc image) từ User tới Admin ---
  Future<void> sendMessage({
    // recipientUid chỉ dùng để xác nhận là gửi cho admin trong logic này,
    // thực tế tin nhắn luôn được lưu dưới document chat của người gửi (user)
    required String recipientUid,
    String? text,
    File? imageFile,
  }) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in!");
    }

    // Kiểm tra recipientUid có phải là admin được chỉ định không (tùy chọn validation)
    if (recipientUid != _adminUid) {
      print("Warning: Attempting to send message to non-admin recipient: $recipientUid");
      // Có thể ném lỗi hoặc xử lý khác
      // throw Exception("Invalid recipient for support chat.");
    }


    if ((text == null || text.isEmpty) && imageFile == null) {
      throw Exception("Message text or image must be provided.");
    }

    String senderUid = currentUser.uid; // Người gửi là user hiện tại

    Map<String, dynamic> messageData = {
      'senderId': senderUid,
      'timestamp': FieldValue.serverTimestamp(), // Sử dụng thời gian của server
    };

    String messageType;
    String? imageUrl;

    if (imageFile != null) {
      // Tải ảnh lên Firebase Storage
      messageType = 'image';
      try {
        String filePath = 'chat_images/${currentUser.uid}/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        UploadTask uploadTask = _storage.ref().child(filePath).putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        imageUrl = await taskSnapshot.ref.getDownloadURL();

        messageData['type'] = messageType;
        messageData['imageUrl'] = imageUrl;

      } catch (e) {
        print("Error uploading image: ${e.toString()}");
        throw Exception("Failed to upload image: ${e.toString()}");
      }

    } else {
      // Gửi tin nhắn dạng văn bản
      messageType = 'text';
      messageData['type'] = messageType;
      messageData['text'] = text?.trim(); // Lưu text sau khi trim
    }

    // --- Lưu tin nhắn vào Firestore ---
    // Lưu tin nhắn vào subcollection 'messages' của document chat của người dùng.
    // ID của document chat là UID của người dùng hiện tại.
    try {
      DocumentReference chatDocRef = _firestore.collection('chats').doc(senderUid); // Lưu vào document chat CỦA NGƯỜI GỬI (USER)

      await chatDocRef.collection('messages').add(messageData);

      // Tùy chọn: Cập nhật thông tin cuối cùng của cuộc trò chuyện trong document cha
      // (Hữu ích cho admin view để hiển thị danh sách chat gần đây)
      chatDocRef.set({
        'adminId': _adminUid,
        'userId': senderUid,
        'lastMessage': text?.trim() ?? 'Image message', // Lưu text sau khi trim hoặc thông báo ảnh
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Sử dụng merge để không ghi đè hoàn toàn document

      print("Message sent successfully.");

    } catch (e) {
      print("Error sending message: ${e.toString()}");
      throw Exception("Failed to send message: ${e.toString()}");
    }
  }

  // --- Phương thức gửi tin nhắn TỪ ADMIN TỚI NGƯỜI DÙNG ---
  // Phương thức này sẽ được gọi từ phía Admin App.
  Future<void> sendAdminMessage({
    required String userUid, // UID của người dùng mà admin đang trả lời
    String? text,
    File? imageFile,
  }) async {
    User? currentUser = _auth.currentUser; // Lấy user hiện tại (phía admin app)
    // Đảm bảo người gửi là admin được chỉ định
    if (currentUser == null || currentUser.uid != _adminUid) {
      throw Exception("Permission denied. Must be the designated admin to send messages.");
    }

    if ((text == null || text.isEmpty) && imageFile == null) {
      throw Exception("Message text or image must be provided.");
    }

    String senderUid = currentUser.uid; // UID của Admin

    Map<String, dynamic> messageData = {
      'senderId': senderUid, // senderId là UID của Admin
      'timestamp': FieldValue.serverTimestamp(),
    };

    String messageType;
    String? imageUrl;

    if (imageFile != null) {
      messageType = 'image';
      try {
        String filePath = 'chat_images/$userUid/admin_${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        UploadTask uploadTask = _storage.ref().child(filePath).putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        imageUrl = await taskSnapshot.ref.getDownloadURL();

        messageData['type'] = messageType;
        messageData['imageUrl'] = imageUrl;

      } catch (e) {
        print("Error uploading admin image: ${e.toString()}");
        throw Exception("Failed to upload admin image: ${e.toString()}");
      }
    } else {
      messageType = 'text';
      messageData['type'] = messageType;
      messageData['text'] = text?.trim(); // Lưu text sau khi trim
    }

    // Lưu tin nhắn vào subcollection 'messages' của document chat của người dùng userUid
    try {
      DocumentReference chatDocRef = _firestore.collection('chats').doc(userUid); // Lưu vào chat của người dùng đích

      await chatDocRef.collection('messages').add(messageData);

      chatDocRef.set({
        'adminId': _adminUid,
        'userId': userUid,
        'lastMessage': text?.trim() ?? 'Image message',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        // Có thể thêm trường 'lastMessageBy': senderUid
      }, SetOptions(merge: true));

      print("Admin message sent successfully to user $userUid.");

    } catch (e) {
      print("Error sending admin message: ${e.toString()}");
      throw Exception("Failed to send admin message: ${e.toString()}");
    }

  }

  // --- Lấy Stream danh sách các cuộc trò chuyện cho Admin ---
  // Phương thức này sẽ được gọi từ phía Admin App để hiển thị danh sách users cần hỗ trợ
  Stream<List<Map<String, dynamic>>> getUserConversationsStreamForAdmin() {
    User? currentUser = _auth.currentUser; // Lấy user hiện tại (phía admin app)
    // Chỉ admin được chỉ định mới được xem danh sách chat
    if (currentUser == null || currentUser.uid != _adminUid) {
      return Stream.value([]); // Trả về stream rỗng
    }

    // Lấy tất cả documents trong collection 'chats'
    return _firestore
        .collection('chats')
        .orderBy('lastMessageTimestamp', descending: true) // Sắp xếp theo tin nhắn gần nhất
        .snapshots()
        .map((snapshot) {
      // Chuyển đổi QuerySnapshot thành List<Map>
      // Có thể thêm logic để lấy các trường cần thiết hoặc xử lý Map thành Model Conversation
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}