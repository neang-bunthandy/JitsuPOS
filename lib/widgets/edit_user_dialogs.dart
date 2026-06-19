import 'package:flutter/material.dart';
import 'package:project_pos/core/app_fonts.dart';
import 'package:project_pos/data/local_data.dart';

void showEditUserDialog({
  required BuildContext context,
  required Map<String, dynamic> user,
  required VoidCallback onSuccess,
}) {
  final id = user['id'] as int;
  final usernameCtrl = TextEditingController(text: user['username']);
  final passwordCtrl = TextEditingController(text: user['password']);

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('កែប្រែគណនី', style: AppFonts.khHeading3),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameCtrl,
                decoration: InputDecoration(
                  labelText: 'ឈ្មោះគណនី (Username)',
                  labelStyle: AppFonts.khBodySmall,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: false,
                decoration: InputDecoration(
                  labelText: 'លេខសម្ងាត់ (Password)',
                  labelStyle: AppFonts.khBodySmall,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'បោះបង់',
              style: AppFonts.khLabel.copyWith(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final u = usernameCtrl.text.trim();
              final p = passwordCtrl.text.trim();
              if (u.isEmpty || p.isEmpty) return;

              await DataLocal.instance.updateUserAccount(
                id: id,
                newUsername: u,
                newPassword: p,
              );
              if (context.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'បានកែប្រែគណនីបុគ្គលិកជោគជ័យ!',
                      style: AppFonts.khBody.copyWith(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                onSuccess();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text(
              'រក្សាទុក',
              style: AppFonts.khLabel.copyWith(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}
