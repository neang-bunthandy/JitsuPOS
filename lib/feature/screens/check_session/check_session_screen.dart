import 'package:flutter/material.dart';
import 'package:project_pos/data/session_manager.dart';
import 'package:project_pos/feature/screens/admin/admin_dashboard_screen.dart';
import 'package:project_pos/feature/screens/login/login_screen.dart';
import 'package:project_pos/feature/screens/seller/seller_dashboard_screen.dart';

class CheckSessionScreen extends StatefulWidget {
  const CheckSessionScreen({super.key});

  @override
  State<CheckSessionScreen> createState() => _CheckSessionScreenState();
}

class _CheckSessionScreenState extends State<CheckSessionScreen> {
  bool isLoading = true;
  Widget nextScreen = const LoginScreen();

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  void checkUserRole() async {
    try {
      bool isLoggedIn = await SessionManager.isLoggedIn();

      if (isLoggedIn == true) {
        String? role = await SessionManager.getUserRole();
        if (role == 'admin') {
          nextScreen = const AdminDashboardScreen();
        } else {
          nextScreen = const SellerDashboardScreen();
        }
      } else {
        nextScreen = const LoginScreen();
      }
    } catch (e) {
      nextScreen = const LoginScreen();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return nextScreen;
  }
}
