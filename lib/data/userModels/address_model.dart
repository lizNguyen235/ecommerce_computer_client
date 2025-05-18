// models/address_model.dart (Hoặc vị trí phù hợp)
class AddressModel {
  final String name;
  final String phone;
  final String address;
  final bool isDefault;
  // final String? id; // Tùy chọn: Nếu bạn muốn mỗi địa chỉ có ID riêng trong mảng

  AddressModel({
    required this.name,
    required this.phone,
    required this.address,
    this.isDefault = false,
    // this.id,
  });

  // Chuyển đổi từ Map (thường là từ Firestore)
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      isDefault: map['isDefault'] ?? false,
      // id: map['id'],
    );
  }

  // Chuyển đổi thành Map (để lưu vào Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'isDefault': isDefault,
      // if (id != null) 'id': id,
    };
  }

  // Để so sánh các đối tượng AddressModel (quan trọng cho việc tìm và xóa)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressModel &&
        other.name == name &&
        other.phone == phone &&
        other.address == address &&
        other.isDefault == isDefault;
    // && other.id == id;
  }

  @override
  int get hashCode {
    return name.hashCode ^
    phone.hashCode ^
    address.hashCode ^
    isDefault.hashCode;
    // ^ id.hashCode;
  }

  AddressModel copyWith({
    String? name,
    String? phone,
    String? address,
    bool? isDefault,
    // String? id, // Nếu bạn có id
  }) {
    return AddressModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
      // id: id ?? this.id, // Nếu bạn có id
    );
  }

  // Tiện lợi để hiển thị nhanh
  String get fullAddressDisplay => '$name - $phone\n$address';
}