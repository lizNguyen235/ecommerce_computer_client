class Address {
  final String name;
  final String address;
  final String phone;
  final bool isDefault;

  Address({
    required this.name,
    required this.address,
    required this.phone,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'phone': phone,
    'isDefault': isDefault,
  };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    name: json['name'],
    address: json['address'],
    phone: json['phone'],
    isDefault: json['isDefault'] ?? false,
  );
}