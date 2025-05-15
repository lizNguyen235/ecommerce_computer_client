import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          'Add New Address',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.defaultSpace),
          child: Form(
            child: Column(
              children: [
                TextFormField(
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
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.mobile),
                    labelText: 'Phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: textfieldGrey),
                    ),
                    labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                const SizedBox(height: Sizes.spaceBtwInputFields),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.location),
                          labelText: 'Street',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: textfieldGrey),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Sizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.code),
                          labelText: 'Postal code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: textfieldGrey),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Sizes.spaceBtwInputFields),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.building),
                          labelText: 'City',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: textfieldGrey),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Sizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Iconsax.activity),
                          labelText: 'State',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: textfieldGrey),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Sizes.spaceBtwInputFields),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.global),
                    labelText: 'Country',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: textfieldGrey),
                    ),
                    labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                const SizedBox(height: Sizes.defaultSpace),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle save address action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
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
        ),
      ),
    );
  }
}
