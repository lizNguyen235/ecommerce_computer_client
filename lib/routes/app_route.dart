import 'package:ecommerce_computer_client/admin/admin_main_page.dart';
import 'package:ecommerce_computer_client/views/home/home.dart';
import 'package:flutter/material.dart';
import '../views/login/login.dart';
import '../views/login/register.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String admin = '/admin';
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const Home());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginDialog());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterDialog());
      case admin:
        return MaterialPageRoute(
          builder: (_) => const AdminMainPage());

      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Không tìm thấy trang')),
              ),
        );
    }
  }
}
