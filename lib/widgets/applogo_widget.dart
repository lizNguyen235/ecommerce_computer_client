import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:flutter/material.dart';

Widget applogoWidget() {
  return Image.asset(
    icAppLogo,
  ).box.white.size(77, 77).padding(const EdgeInsets.all(8)).rounded.make();
}
