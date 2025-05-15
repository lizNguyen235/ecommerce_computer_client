import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/views/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'views/home/home_page.dart';
// import các màn hình khác nếu cần

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Widget initialScreen =
      HomeScreen(); // ← Thay đổi tại đây để test screen khác

  @override
  Widget build(BuildContext context) {
    // Sử dụng GetMaterialApp thay vì MaterialApp để chuyển từ splash sang login or home
    return GetMaterialApp(
      title: appname,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: initialScreen,
    );
  }
}
