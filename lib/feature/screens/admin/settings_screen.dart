import 'package:flutter/material.dart';
import 'package:project_pos/core/app_fonts.dart';
import 'package:project_pos/core/app_colors.dart';
import 'package:project_pos/data/local_data.dart';
import 'package:project_pos/feature/screens/login/login_screen.dart';
import 'package:project_pos/widgets/add_user_dialog.dart';
import 'package:project_pos/widgets/edit_user_dialogs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  List<Map<String, dynamic>> _userList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserList();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final list = await DataLocal.instance.getAllUsers();
      setState(() {
        _userList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changeAdminPassword() async {
    final newPass = _passwordController.text.trim();
    if (newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'សូមបញ្ចូលលេខសម្ងាត់ថ្មី!',
            style: AppFonts.khBody.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      final adminUser = _userList.firstWhere(
        (u) => u['username'] == 'admin',
        orElse: () => {},
      );
      if (adminUser.isNotEmpty) {
        final id = adminUser['id'] as int;
        await DataLocal.instance.updateUserAccount(
          id: id,
          newUsername: 'admin',
          newPassword: newPass,
        );
        _passwordController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'បានប្ដូរលេខសម្ងាត់ថ្មីដោយជោគជ័យ!',
                style: AppFonts.khBody.copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadUserList();
      }
    } catch (e) {
      // Handle error
    }
  }

  void _deleteUserAccount(Map<String, dynamic> user) {
    final id = user['id'] as int;
    final username = user['username'] ?? '';

    if (username == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'មិនអាចលុបគណនីអ្នកគ្រប់គ្រងចម្បង (admin) បានទេ!',
            style: AppFonts.khBody.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'បញ្ជាក់ការលុបគណនី',
            style: AppFonts.khHeading3.copyWith(color: Colors.red.shade700),
          ),
          content: Text(
            'តើអ្នកពិតជាចង់លុបគណនីបុគ្គលិក "$username" នេះមែនទេ?',
            style: AppFonts.khBody,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'បោះបង់',
                style: AppFonts.khLabel.copyWith(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await DataLocal.instance.deleteUser(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'បានលុបគណនីបុគ្គលិកជោគជ័យ!',
                        style: AppFonts.khBody.copyWith(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadUserList();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'លុប',
                style: AppFonts.khButton.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        title: Text(
          'ការកំណត់',
          style: AppFonts.khHeading2.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Info Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    'គណនី៖ Admin',
                    style: AppFonts.khHeading3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Change Password Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ការប្ដូរលេខសម្ងាត់ថ្មី',
                    style: AppFonts.khLabel.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'លេខសម្ងាត់ថ្មី (New Password)',
                      labelStyle: AppFonts.khBodySmall,
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
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    height: 44.0,
                    child: ElevatedButton(
                      onPressed: _changeAdminPassword,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text('ប្ដូរ', style: AppFonts.khButton),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28.0),

            // Staff Management Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'គ្រប់គ្រងបុគ្គលិក',
                  style: AppFonts.khHeading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showAddUserDialog(
                      context: context,
                      onSuccess: _loadUserList,
                    );
                  },
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: Text(
                    'បន្ថែមថ្មី',
                    style: AppFonts.khLabel.copyWith(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // User List
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _userList.length,
                    itemBuilder: (context, index) {
                      final user = _userList[index];
                      final username = user['username'] ?? '';
                      final role = user['role'] ?? '';
                      return Card(
                        color: Colors.white,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(color: Colors.black12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: role == 'admin'
                                ? Colors.blue.shade50
                                : Colors.green.shade50,
                            child: Icon(
                              role == 'admin'
                                  ? Icons.admin_panel_settings
                                  : Icons.person_outline,
                              color: role == 'admin'
                                  ? Colors.blue
                                  : Colors.green,
                            ),
                          ),
                          title: Text(
                            'User: $username',
                            style: AppFonts.khBody.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Role: ${role == 'admin' ? 'Admin' : 'Seller'}',
                            style: AppFonts.khCaption,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => showEditUserDialog(
                                  context: context,
                                  user: user,
                                  onSuccess: _loadUserList,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteUserAccount(user),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 32.0),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'ចាកចេញ',
                  style: AppFonts.khButton.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
