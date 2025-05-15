import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:flutter/material.dart';

Widget quickButton({required icon, required String? label}) {
  return Column(
    children: [
      CircleAvatar(
        radius: 24,
        backgroundColor: Colors.orange.shade50,
        child: Icon(icon, color: Colors.orange, size: 28),
      ),
      4.heightBox,
      label!.text.color(darkFontGrey).size(9).make(),
    ],
  );
}
