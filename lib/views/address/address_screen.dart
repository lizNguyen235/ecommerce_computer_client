import 'package:ecommerce_computer_client/controller/address_controller.dart';
import 'package:ecommerce_computer_client/core/service/AuthService.dart';
import 'package:ecommerce_computer_client/views/address/add_address_screen.dart';
import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/address/single_address.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_computer_client/models/address_model.dart';
import 'package:iconsax/iconsax.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().getCurrentUser()?.uid ?? '';
    final controller = Get.put(AddressController());
    controller.loadAddresses(userId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manage Addresses', style: TextStyle(color: Colors.black, fontSize: 24, fontFamily: bold)),
        backgroundColor: Colors.transparent,
      ),
      body: Obx(
            () => controller.shippingAddresses.isEmpty
            ? const Center(child: Text('No addresses found. Add one!'))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.shippingAddresses.length,
          itemBuilder: (context, index) {
            final address = controller.shippingAddresses[index];
            return GestureDetector(
              onTap: () => controller.selectAddress(userId, index),
              onLongPress: () => controller.setDefaultAddress(userId, index),
              child: Stack(
                children: [
                  SingleAddress(
                    selectedAddress: controller.chooseAddress.value == index,
                    address: address,
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (address.isDefault)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.deleteAddress(userId, index),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddAddressScreen(userId: userId)),
        backgroundColor: TColors.primary,
        child: const Icon(Iconsax.add, color: Colors.white,),
      ),
    );
  }
}

