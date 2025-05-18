import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ecommerce_computer_client/models/address_model.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find<AddressController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Address> shippingAddresses = <Address>[].obs;
  final RxInt chooseAddress = 0.obs;

  Future<void> loadAddresses(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final addresses = (data['shippingAddress'] as List<dynamic>? ?? [])
            .map((e) => Address.fromJson(e as Map<String, dynamic>))
            .toList();
        shippingAddresses.assignAll(addresses);
        chooseAddress.value = data['chooseAddress'] ?? 0;
      }
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> addAddress(String userId, Address newAddress) async {
    try {
      if (newAddress.isDefault) {
        // Set all other addresses to non-default
        for (var addr in shippingAddresses) {
          addr = Address(
            name: addr.name,
            address: addr.address,
            phone: addr.phone,
            isDefault: false,
          );
        }
      }
      shippingAddresses.add(newAddress);
      await _firestore.collection('users').doc(userId).set({
        'shippingAddress': shippingAddresses.map((e) => e.toJson()).toList(),
        'chooseAddress': chooseAddress.value,
      }, SetOptions(merge: true));
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> selectAddress(String userId, int index) async {
    try {
      chooseAddress.value = index;
      await _firestore.collection('users').doc(userId).update({
        'chooseAddress': chooseAddress.value,
      });
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> deleteAddress(String userId, int index) async {
    try {
      shippingAddresses.removeAt(index);
      if (chooseAddress.value >= shippingAddresses.length) {
        chooseAddress.value = shippingAddresses.isNotEmpty ? shippingAddresses.length - 1 : 0;
      }
      await _firestore.collection('users').doc(userId).set({
        'shippingAddress': shippingAddresses.map((e) => e.toJson()).toList(),
        'chooseAddress': chooseAddress.value,
      }, SetOptions(merge: true));
    } catch (e) {
      // Silent error handling
    }
  }

  Future<void> setDefaultAddress(String userId, int index) async {
    try {
      final updatedAddresses = shippingAddresses.asMap().entries.map((entry) {
        final i = entry.key;
        final addr = entry.value;
        return Address(
          name: addr.name,
          address: addr.address,
          phone: addr.phone,
          isDefault: i == index,
        );
      }).toList();
      shippingAddresses.assignAll(updatedAddresses);
      chooseAddress.value = index; // Update chooseAddress to the new default index
      await _firestore.collection('users').doc(userId).set({
        'shippingAddress': shippingAddresses.map((e) => e.toJson()).toList(),
        'chooseAddress': chooseAddress.value,
      }, SetOptions(merge: true));
    } catch (e) {
      // Silent error handling
    }
  }
}