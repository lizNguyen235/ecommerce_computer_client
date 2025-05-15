import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/views/login/login.dart';
import 'package:ecommerce_computer_client/widgets/applogo_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  changeScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.to(() => const LoginDialog());
    });
  }

  @override
  void initState() {
    changeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 248, 113, 2),
        child: Center(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset(icSplashBg, width: 300),
              ),
              20.heightBox,
              applogoWidget(),
              10.heightBox,
              appname.text.fontFamily(bold).size(22).white.make(),
              5.heightBox,
              appversion.text.white.make(),
            ],
          ),
        ),
      ),
    );
  }
}
