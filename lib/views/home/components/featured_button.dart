import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:flutter/material.dart';

Widget featuredButton({String? title, icon}) {
  return Row(
        children: [
          Image.asset(icon, width: 50, fit: BoxFit.fill),
          10.widthBox,
          title!.text.fontFamily(semibold).color(darkFontGrey).make(),
        ],
      ).box
      .width(190)
      .margin(const EdgeInsets.symmetric(horizontal: 4))
      .white
      .padding(const EdgeInsets.all(4))
      .roundedSM
      .outerShadowSm
      .make();
}
