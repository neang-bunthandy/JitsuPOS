import 'package:flutter/material.dart';
import 'package:project_pos/core/app_colors.dart';
import 'package:project_pos/core/app_fonts.dart';
import 'package:project_pos/data/local_data.dart';
import 'package:project_pos/data/session_manager.dart';
import 'package:project_pos/feature/screens/admin/admin_dashboard_screen.dart';
import 'package:project_pos/feature/screens/seller/seller_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isAdminSelected = true;

  Future<void> _handleLogin() async {
    String usernameInput = _usernameController.text.trim();
    String passwordInput = _passwordController.text.trim();
    String selectedRole = _isAdminSelected ? 'admin' : 'seller';

    if (usernameInput.isEmpty || passwordInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'សូមបំពេញព័ត៌មានឱ្យបានគ្រប់គ្រាន់!',
            style: AppFonts.khBody.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    bool isSuccess = await DataLocal.instance.loginUser(
      usernameInput,
      passwordInput,
      selectedRole,
    );

    if (mounted) {
      if (isSuccess) {
        await SessionManager.saveSession(
          username: usernameInput,
          role: selectedRole,
        );
        if (!mounted) return;
        if (selectedRole == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SellerDashboardScreen(),
            ),
          );
        }
      } else {
        // Failed login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ឈ្មោះ ឬ លេខសម្ងាត់មិនត្រឹមត្រូវតាមតួនាទីឡើយ!',
              style: AppFonts.khBody.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFAFAFC,
      ), // Off-white/lavender background matching Figma
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Text(
                'ចូលប្រើប្រាស់',
                style: AppFonts.khHeading2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: Colors.black12, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 12.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8.0),
                    // Email Field
                    TextField(
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'អ៊ីមែល (Email)',
                        labelStyle: AppFonts.khBody.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.black45,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: AppFonts.khBody,
                    ),
                    const SizedBox(height: 24.0),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'លេខសម្ងាត់ (Password)',
                        labelStyle: AppFonts.khBody.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outlined,
                          color: Colors.black45,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: AppFonts.khBody,
                    ),
                    const SizedBox(height: 24.0),

                    // Login As Label
                    Center(
                      child: Text(
                        "ចូលជា",
                        style: AppFonts.khBody.copyWith(
                          fontSize: 16.0,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // Role Switcher
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      height: 60.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: Colors.blue, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isAdminSelected = true;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isAdminSelected
                                      ? Colors.blue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "អ្នកគ្រប់គ្រង",
                                  style: AppFonts.khLabel.copyWith(
                                    color: _isAdminSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isAdminSelected = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !_isAdminSelected
                                      ? Colors.blue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "អ្នកលក់",
                                  style: AppFonts.khLabel.copyWith(
                                    color: !_isAdminSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    // Login Button
                    SizedBox(
                      height: 52.0,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26.0),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "ចូលប្រើប្រាស់",
                          style: AppFonts.khButton.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
