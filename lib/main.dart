import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/controller/address_controller.dart';
import 'package:ecommerce_computer_client/controller/product_controller.dart';
import 'package:ecommerce_computer_client/firebase_options.dart';
import 'package:ecommerce_computer_client/views/home/home.dart';
import 'package:ecommerce_computer_client/views/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
// import các màn hình khác nếu cần

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('vi_VN');
  // Khởi tạo các dịch vụ khác nếu cần
  Get.put(ProductController());
  // Khởi tạo các controller khác nếu cần
  Get.put(AddressController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Widget initialScreen =
      SplashScreen(); // ← Thay đổi tại đây để test screen khác

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
