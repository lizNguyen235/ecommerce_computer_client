import 'package:ecommerce_computer_client/admin/product_management_screen.dart';
import 'package:ecommerce_computer_client/admin/user_management_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/appbar.dart';
import 'admin_drawer.dart';
import 'coupon_management_screen.dart';
import 'customer_support_admin_screen.dart';
import 'dashboard_creen.dart';
import 'order_management_screen.dart';
// Đây sẽ là trang chat của admin

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  AdminSection _currentSection = AdminSection.dashboard; // Mặc định là Dashboard

  String _getTitleForSection(AdminSection section) {
    switch (section) {
      case AdminSection.dashboard:
        return 'Dashboard';
      case AdminSection.productManagement:
        return 'Product Management';
      case AdminSection.userManagement:
        return 'User Management';
      case AdminSection.orderManagement:
        return 'Order Management';
      case AdminSection.couponManagement:
        return 'Coupon Management';
      case AdminSection.customerSupport:
        return 'Customer Support Chat';
      default:
        return 'Admin Panel';
    }
  }

  Widget _getBodyForSection(AdminSection section) {
    switch (section) {
      case AdminSection.dashboard:
        return const DashboardScreen(); // Tạo widget này
      case AdminSection.productManagement:
        return const ProductManagementScreen(); // Tạo widget này
      case AdminSection.userManagement:
        return const UserManagementScreen(); // Tạo widget này
      case AdminSection.orderManagement:
        return const OrderManagementScreen(); // Tạo widget này
      case AdminSection.couponManagement:
        return const CouponManagementScreen(); // Tạo widget này
      case AdminSection.customerSupport:
        return const CustomerSupportAdminScreen(); // Tạo widget này (giao diện chat cho admin)
      default:
        return const DashboardScreen(); // Mặc định
    }
  }

  void _onDrawerSectionSelected(AdminSection section) {
    setState(() {
      _currentSection = section;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Thêm kiểm tra quyền admin ở đây. Nếu không phải admin, redirect về trang chủ hoặc login.
    // Ví dụ:
    // final authService = Provider.of<AuthService>(context, listen: false);
    // if (!authService.isAdminUser()) { // Giả sử có hàm này
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Navigator.of(context).pushReplacementNamed('/');
    //   });
    //   return const Scaffold(body: Center(child: CircularProgressIndicator())); // Màn hình loading tạm thời
    // }

    return Scaffold(
      appBar: TAppBar(
        title: Text(_getTitleForSection(_currentSection)),
        // Bạn có thể thêm actions cho AppBar nếu cần, ví dụ nút refresh
      ),
      drawer: AdminDrawer(
        currentSection: _currentSection,
        onSectionSelected: _onDrawerSectionSelected,
      ),
      body: _getBodyForSection(_currentSection),
    );
  }
}