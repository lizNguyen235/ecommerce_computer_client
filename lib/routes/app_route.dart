import 'package:ecommerce_computer_client/views/home/home.dart';
import 'package:flutter/material.dart';
import '../views/login/login.dart';
import '../views/login/register.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const Home());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginDialog());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterDialog());
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
