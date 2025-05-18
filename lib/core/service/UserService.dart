import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/userModels/address_model.dart';
import 'AuthService.dart'; // Cần User để lấy UID
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService(); // Giữ lại nếu bạn dùng ở đâu đó
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String fullName,
    // shippingAddress ban đầu có thể là một AddressModel hoặc null/rỗng
    AddressModel? initialShippingAddress, // <<--- THAY ĐỔI
  }) async {
    try {
      List<Map<String, dynamic>> shippingAddressesList = [];
      if (initialShippingAddress != null) {
        // Nếu đây là địa chỉ đầu tiên, có thể đặt isDefault = true
        shippingAddressesList.add(initialShippingAddress.copyWith(isDefault: true).toMap());
      }

      await usersCollection.doc(uid).set({
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'role': 'customer',
        'shippingAddress': shippingAddressesList, // <<--- LÀ MỘT MẢNG MAP
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'avatarUrl': '',
        'phoneNumber': '', // SĐT chính của user, khác với SĐT trong địa chỉ
        'isBanned': false,
        'loyaltyPoints': 0,
        // 'chooseAddress' không còn cần thiết nếu dùng isDefault trong AddressModel
      });
      print("UserService: User profile created successfully for UID: $uid");
    } catch (e) {
      print("UserService Error (createUserProfile): $e");
      throw e;
    }
  }

  // --- Phương thức cập nhật điểm khách hàng thân thiết --- (Giữ nguyên)
  Future<void> updateUserLoyaltyPoints(String uid, int newPoints) async {
    // ... (code giữ nguyên) ...
    try {
      if (newPoints < 0) {
        throw Exception("Điểm khách hàng thân thiết không thể là số âm.");
      }
      await usersCollection.doc(uid).update({
        'loyaltyPoints': newPoints,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("UserService: User loyalty points updated to $newPoints for UID: $uid");
    } catch (e) {
      print("UserService Error (updateUserLoyaltyPoints): $e");
      throw e;
    }
  }


  // --- Phương thức đọc thông tin hồ sơ người dùng --- (Giữ nguyên)
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    // ... (code giữ nguyên) ...
    try {
      DocumentSnapshot doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        print("UserService: User profile loaded for UID: $uid");
        return doc.data() as Map<String, dynamic>?;
      } else {
        print("UserService: No user profile found for UID: $uid");
        return null;
      }
    } catch (e) {
      print("UserService Error (getUserProfile): $e");
      throw e;
    }
  }

  // --- Phương thức cập nhật thông tin hồ sơ người dùng --- (Giữ nguyên)
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    // ... (code giữ nguyên) ...
    try {
      await usersCollection.doc(uid).update(data);
      print("UserService: User profile updated for UID: $uid");
    } catch (e) {
      print("UserService Error (updateUserProfile): $e");
      throw e;
    }
  }

  // --- Phương thức trả về vai trò (role) của người dùng hiện tại --- (Giữ nguyên)
  Future<String> getCurrentUserRole() async {
    // ... (code giữ nguyên) ...
    User? user = _auth.getCurrentUser();
    if (user == null) {
      print("UserService: No user logged in. Cannot get role.");
      return 'guest';
    }
    String uid = user.uid;
    try {
      DocumentSnapshot doc = await usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String role = data['role']?.toString() ?? 'user';
        print("UserService: Fetched role '$role' for current user UID: $uid");
        return role;
      } else {
        print("UserService: No profile found or data is null for current user UID: $uid. Returning default role 'user'");
        return 'user';
      }
    } catch (e) {
      print("UserService Error (getCurrentUserRole): $e");
      return 'user';
    }
  }

  // Giúp UI cập nhật tự động khi có thay đổi trong Firestore (Giữ nguyên)
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    // ... (code giữ nguyên) ...
    try {
      return usersCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['uid'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print("UserService Error (getAllUsers): $e");
      return Stream.error(e);
    }
  }


  // --- Phương thức thay đổi trạng thái cấm của người dùng --- (Giữ nguyên)
  Future<void> toggleUserBanStatus(String uid, bool currentIsBanned) async {
    // ... (code giữ nguyên) ...
    try {
      await usersCollection.doc(uid).update({
        'isBanned': !currentIsBanned,
        'updatedAt': Timestamp.now(),
      });
      print("UserService: User ban status toggled for UID: $uid to ${!currentIsBanned}");
    } catch (e) {
      print("UserService Error (toggleUserBanStatus): $e");
      throw e;
    }
  }

  // --- Phương thức cập nhật vai trò người dùng --- (Giữ nguyên)
  Future<void> updateUserRole(String uid, String newRole) async {
    // ... (code giữ nguyên) ...
    try {
      await usersCollection.doc(uid).update({
        'role': newRole,
        'updatedAt': Timestamp.now(),
      });
      print("UserService: User role updated to '$newRole' for UID: $uid");
    } catch (e) {
      print("UserService Error (updateUserRole): $e");
      throw e;
    }
  }

  // --- Phương thức cập nhật số điện thoại người dùng (SĐT chính) --- (Giữ nguyên)
  Future<void> updateUserPhoneNumber(String uid, String phoneNumber) async {
    // ... (code giữ nguyên) ...
    try {
      await usersCollection.doc(uid).update({
        'phoneNumber': phoneNumber,
        'updatedAt': Timestamp.now(),
      });
      print("UserService: User phone number updated to '$phoneNumber' for UID: $uid");
    } catch (e) {
      print("UserService Error (updateUserPhoneNumber): $e");
      throw e;
    }
  }

  // --- Phương thức thêm một địa chỉ giao hàng mới ---
  Future<void> addShippingAddress(String uid, AddressModel newAddress) async { // <<--- THAY ĐỔI
    try {
      // Nếu đây là địa chỉ duy nhất hoặc người dùng muốn đặt làm mặc định
      // bạn có thể cần logic để cập nhật isDefault cho các địa chỉ khác.
      // Ví dụ đơn giản: nếu chưa có địa chỉ nào, đặt cái này làm mặc định.
      DocumentSnapshot userDoc = await usersCollection.doc(uid).get();
      AddressModel addressToAdd = newAddress;
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> currentAddressesDynamic = userData['shippingAddress'] ?? [];
        if (currentAddressesDynamic.isEmpty && !newAddress.isDefault) {
          addressToAdd = newAddress.copyWith(isDefault: true);
        } else if (newAddress.isDefault) {
          // Nếu địa chỉ mới được đặt làm mặc định, bỏ mặc định ở các địa chỉ cũ
          List<Map<String, dynamic>> updatedAddresses = currentAddressesDynamic.map((addrMap) {
            return AddressModel.fromMap(addrMap as Map<String,dynamic>).copyWith(isDefault: false).toMap();
          }).toList();
          await usersCollection.doc(uid).update({'shippingAddress': updatedAddresses});
        }
      }


      await usersCollection.doc(uid).update({
        'shippingAddress': FieldValue.arrayUnion([addressToAdd.toMap()]), // Thêm map của AddressModel
        'updatedAt': Timestamp.now(),
      });
      print("UserService: Added new shipping address for UID: $uid");
    } catch (e) {
      print("UserService Error (addShippingAddress): $e");
      throw e;
    }
  }

  // --- Phương thức xóa một địa chỉ giao hàng ---
  Future<void> removeShippingAddress(String uid, AddressModel addressToRemove) async { // <<--- THAY ĐỔI
    try {
      await usersCollection.doc(uid).update({
        'shippingAddress': FieldValue.arrayRemove([addressToRemove.toMap()]), // Xóa map của AddressModel
        'updatedAt': Timestamp.now(),
      });
      print("UserService: Removed shipping address for UID: $uid");
      // Kiểm tra nếu địa chỉ bị xóa là mặc định và còn địa chỉ khác, đặt địa chỉ đầu tiên làm mặc định
      DocumentSnapshot userDoc = await usersCollection.doc(uid).get();
      if (userDoc.exists && addressToRemove.isDefault) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> currentAddressesDynamic = userData['shippingAddress'] ?? [];
        if (currentAddressesDynamic.isNotEmpty) {
          List<Map<String, dynamic>> addresses = currentAddressesDynamic.map((e) => e as Map<String,dynamic>).toList();
          // Kiểm tra xem có địa chỉ mặc định nào khác không
          bool hasDefault = addresses.any((addrMap) => AddressModel.fromMap(addrMap).isDefault);
          if(!hasDefault) {
            // Nếu không, đặt địa chỉ đầu tiên làm mặc định
            addresses[0] = AddressModel.fromMap(addresses[0]).copyWith(isDefault: true).toMap();
            await usersCollection.doc(uid).update({'shippingAddress': addresses});
          }
        }
      }
    } catch (e) {
      print("UserService Error (removeShippingAddress): $e");
      throw e;
    }
  }

  // --- Phương thức sửa một địa chỉ giao hàng ---
  Future<void> editShippingAddress(String uid, AddressModel oldAddress, AddressModel newAddressData) async { // <<--- THAY ĐỔI
    try {
      DocumentSnapshot userDoc = await usersCollection.doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> currentAddressesDynamic = userData['shippingAddress'] ?? [];
        List<Map<String, dynamic>> updatedAddresses = [];
        bool found = false;

        for (var addrMap in currentAddressesDynamic) {
          AddressModel currentAddr = AddressModel.fromMap(addrMap as Map<String, dynamic>);
          if (currentAddr == oldAddress) { // So sánh bằng AddressModel.operator==
            // Nếu địa chỉ mới được đặt làm mặc định, đảm bảo các địa chỉ khác không phải mặc định
            if (newAddressData.isDefault) {
              updatedAddresses = currentAddressesDynamic.map((addr) {
                return AddressModel.fromMap(addr as Map<String,dynamic>).copyWith(isDefault: false).toMap();
              }).toList();
              // Tìm lại vị trí của oldAddress trong list mới này để cập nhật
              int editIndex = -1;
              for(int i=0; i < updatedAddresses.length; i++){
                if(AddressModel.fromMap(updatedAddresses[i]) == oldAddress) {
                  editIndex = i;
                  break;
                }
              }
              if(editIndex != -1){
                updatedAddresses[editIndex] = newAddressData.toMap();
              } else {
                // Should not happen if logic is correct
                updatedAddresses.add(newAddressData.toMap());
              }

            } else {
              updatedAddresses.add(newAddressData.toMap());
            }
            found = true;
          } else {
            // Nếu địa chỉ đang xét không phải là cái đang sửa,
            // và địa chỉ mới được đặt làm mặc định, thì bỏ isDefault của địa chỉ này.
            if (newAddressData.isDefault) {
              updatedAddresses.add(currentAddr.copyWith(isDefault: false).toMap());
            } else {
              updatedAddresses.add(currentAddr.toMap());
            }
          }
        }
        // Xử lý trường hợp nếu oldAddress không tìm thấy nhưng newAddressData.isDefault là true
        // (cần đảm bảo các địa chỉ khác không phải là mặc định)
        // Trường hợp này ít xảy ra nếu oldAddress luôn được đảm bảo có trong list.
        // Nếu oldAddress không tìm thấy, có thể bạn muốn add newAddressData như một địa chỉ mới
        // Hoặc báo lỗi.
        if(!found && newAddressData.isDefault) {
          updatedAddresses = currentAddressesDynamic.map((addrMap) {
            return AddressModel.fromMap(addrMap as Map<String,dynamic>).copyWith(isDefault: false).toMap();
          }).toList();
          updatedAddresses.add(newAddressData.toMap()); // Coi như thêm mới nếu không tìm thấy old
        } else if (!found) {
          // Nếu không tìm thấy oldAddress và newAddress không phải default, không làm gì hoặc báo lỗi
          print("UserService Error: Old address not found for editing and new address is not default. UID: $uid");
          // throw Exception("Old address not found for editing");
          return; // Không cập nhật
        }


        // Đảm bảo luôn có ít nhất một địa chỉ mặc định nếu có địa chỉ
        if (updatedAddresses.isNotEmpty) {
          bool hasDefault = updatedAddresses.any((addrMap) => AddressModel.fromMap(addrMap).isDefault);
          if (!hasDefault) {
            updatedAddresses[0] = AddressModel.fromMap(updatedAddresses[0]).copyWith(isDefault: true).toMap();
          }
        }


        await usersCollection.doc(uid).update({
          'shippingAddress': updatedAddresses,
          'updatedAt': Timestamp.now(),
        });
        print("UserService: Edited shipping address for UID: $uid");

      } else {
        print("UserService Error: User document not found for UID: $uid");
      }
    } catch (e) {
      print("UserService Error (editShippingAddress): $e");
      throw e;
    }
  }

  // --- Phương thức đặt địa chỉ làm mặc định ---
  Future<void>setDefaultShippingAddress(String uid, AddressModel addressToSetAsDefault) async {
    try {
      DocumentSnapshot userDoc = await usersCollection.doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic> currentAddressesDynamic = userData['shippingAddress'] ?? [];

        List<Map<String, dynamic>> updatedAddresses = currentAddressesDynamic.map((addrMap) {
          AddressModel currentAddr = AddressModel.fromMap(addrMap as Map<String, dynamic>);
          // So sánh dựa trên nội dung, hoặc nếu AddressModel có ID thì so sánh ID
          return currentAddr.copyWith(isDefault: (currentAddr == addressToSetAsDefault)).toMap();
        }).toList();

        await usersCollection.doc(uid).update({
          'shippingAddress': updatedAddresses,
          'updatedAt': Timestamp.now(),
        });
        print("UserService: Set default shipping address for UID: $uid");
      }
    } catch (e) {
      print("UserService Error (setDefaultShippingAddress): $e");
      throw e;
    }
  }


  // --- Phương thức cập nhật họ và tên người dùng --- (Giữ nguyên)
  Future<void> updateUserFullName(String uid, String newFullName) async {
    // ... (code giữ nguyên) ...
    try {
      if (newFullName.trim().isEmpty) {
        throw Exception("Họ và tên không được để trống.");
      }
      await usersCollection.doc(uid).update({
        'fullName': newFullName.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("UserService: User full name updated to '$newFullName' for UID: $uid");
    } catch (e) {
      print("UserService Error (updateUserFullName): $e");
      throw e;
    }
  }
}