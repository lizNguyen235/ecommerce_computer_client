import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/views/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // final Widget initialScreen = Home(); // ← Thay đổi tại đây để test screen khác
  final Widget initialScreen = SplashScreen();

  @override
  Widget build(BuildContext context) {
    // Sử dụng GetMaterialApp thay vì MaterialApp để chuyển từ splash sang login or home
    return GetMaterialApp(
      title: appname,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: darkFontGrey),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        fontFamily: regular,
      ),
      home: initialScreen,
    );
  }
}
