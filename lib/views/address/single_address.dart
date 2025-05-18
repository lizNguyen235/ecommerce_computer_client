import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/models/address_model.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SingleAddress extends StatelessWidget {
  const SingleAddress({
    super.key,
    required this.selectedAddress,
    required this.address,
  });

  final bool selectedAddress;
  final Address address;

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      width: double.infinity,
      showBorder: true,
      padding: const EdgeInsets.all(Sizes.md),
      backgroundColor:
      selectedAddress ? TColors.primary.withOpacity(0.5) : Colors.transparent,
      borderColor: selectedAddress ? Colors.transparent : textfieldGrey,
      margin: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.name,
            style: TextStyle(
              fontSize: 16,
              fontFamily: bold,
              color: Colors.black,
            ),
          ),
          Text(
            address.phone,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: Sizes.sm / 2),
          Text(
            address.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: TextStyle(fontSize: 14, color: darkFontGrey),
          ),
          const SizedBox(height: Sizes.sm / 2),
        ],
      ),
    );
  }
}