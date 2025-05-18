class ShippingAddressModel {
  final String address;
  final bool isDefault; // Mặc dù có vẻ không cần thiết cho order, nhưng giữ lại nếu có
  final String name;
  final String phone;

  ShippingAddressModel({
    required this.address,
    required this.isDefault,
    required this.name,
    required this.phone,
  });

  factory ShippingAddressModel.fromMap(Map<String, dynamic> map) {
    return ShippingAddressModel(
      address: map['address'] ?? '',
      isDefault: map['isDefault'] ?? false,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'isDefault': isDefault,
      'name': name,
      'phone': phone,
    };
  }
}