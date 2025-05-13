import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:flutter/material.dart';

Widget homeButtons({
  double? width,
  double? height,
  String? icon,
  String? title,
  VoidCallback? onPress,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CircleAvatar(
        radius: 24, // Matches the size of quick buttons
        backgroundColor: whiteColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(icon!, width: 26, height: 26, fit: BoxFit.contain),
        ),
      ).box.make().onTap(onPress),
      4.heightBox,
      title!.text.fontFamily(semibold).color(darkFontGrey).size(9).make(),
    ],
  );
}
