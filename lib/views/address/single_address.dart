import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SingleAddress extends StatelessWidget {
  const SingleAddress({super.key, required this.selectedAddress});

  final bool selectedAddress;

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      width: double.infinity,
      showBorder: true,
      padding: const EdgeInsets.all(Sizes.sm),
      backgroundColor:
          selectedAddress
              ? TColors.primary.withOpacity(0.5)
              : Colors.transparent,
      borderColor: selectedAddress ? Colors.transparent : textfieldGrey,
      margin: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 0,
            child: Icon(
              selectedAddress ? Iconsax.tick_circle5 : null,
              color: selectedAddress ? Colors.black : null,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'John Doe',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                '0344 567 890',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: Sizes.sm / 2),
              Text(
                '82356 Timmy Covers, South Liana, Main, 87665, USA',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: TextStyle(fontSize: 14, color: darkFontGrey),
              ),
              const SizedBox(height: Sizes.sm / 2),
            ],
          ),
        ],
      ),
    );
  }
}
