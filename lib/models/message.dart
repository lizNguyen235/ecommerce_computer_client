import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String? text;
  final String? imageUrl;
  final Timestamp timestamp; // Sử dụng Timestamp cho thời gian
  final String type; // 'text' or 'image'

  Message({
    required this.senderId,
    this.text,
    this.imageUrl,
    required this.timestamp,
    required this.type,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Xử lý trường hợp timestamp có thể là null hoặc FieldValue (trước khi server xử lý)
    // Firestore sẽ tự động điền FieldValue.serverTimestamp()
    // Khi đọc, nó sẽ là Timestamp.seconds: 0 nếu đang pending
    Timestamp messageTimestamp = data['timestamp'] is Timestamp
        ? data['timestamp'] as Timestamp
        : Timestamp(0, 0); // Default to 0 if not Timestamp yet

    return Message(
      senderId: data['senderId'] as String,
      text: data['text'] as String?,
      imageUrl: data['imageUrl'] as String?,
      timestamp: messageTimestamp,
      type: data['type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp, // Khi gửi, đây sẽ là FieldValue.serverTimestamp()
      'type': type,
    };
  }
}