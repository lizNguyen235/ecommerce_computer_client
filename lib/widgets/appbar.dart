import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/helper_function.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TAppBar({
    super.key,
    this.title,
    this.showBackArrow = false,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.md),
      child: AppBar(
        automaticallyImplyLeading: false,
        leading:
            showBackArrow
                ? IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Iconsax.arrow_left,
                    color: dark ? whiteColor : TColors.dark,
                  ),
                )
                : leadingIcon != null
                ? IconButton(
                  onPressed: leadingOnPressed,
                  icon: Icon(
                    leadingIcon,
                    color: dark ? whiteColor : TColors.dark,
                  ),
                )
                : null,
        title: title,
        actions: actions,
        centerTitle: true,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
