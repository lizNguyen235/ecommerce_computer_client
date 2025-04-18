import 'package:flutter/material.dart';
import 'views/home/home_page.dart';
// import các màn hình khác nếu cần

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Widget initialScreen = HomeScreen(); // ← Thay đổi tại đây để test screen khác

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: initialScreen,
    );
  }
}
