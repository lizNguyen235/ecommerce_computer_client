import 'package:ecommerce_computer_client/consts/colors.dart';
import 'package:ecommerce_computer_client/controller/address_controller.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_computer_client/models/address_model.dart';
import 'package:iconsax/iconsax.dart';

class AddAddressScreen extends StatelessWidget {
  final String userId;

  const AddAddressScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final isDefault = false.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add New Address', style: TextStyle(color: Colors.black, fontSize: 24)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.user),
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: textfieldGrey),
                ),
                labelStyle: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            const SizedBox(height: Sizes.spaceBtwInputFields),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.call),
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: textfieldGrey),
                ),
                labelStyle: TextStyle(color: Colors.black, fontSize: 16),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: Sizes.spaceBtwInputFields),
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.location),
                labelText: 'Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: textfieldGrey),
                ),
                labelStyle: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      addressController.text.isEmpty ||
                      phoneController.text.isEmpty) {
                    Get.snackbar('Error', 'Please fill in all fields');
                    return;
                  }
                  final newAddress = Address(
                    name: nameController.text,
                    address: addressController.text,
                    phone: phoneController.text,
                    isDefault: isDefault.value,
                  );
                  controller.addAddress(userId, newAddress);
                  Get.back();
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Address',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}