import 'package:flutter/material.dart';
import 'package:project_pos/core/app_fonts.dart';
import 'package:project_pos/data/local_data.dart';

void showAddUserDialog({
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String roleVal = 'seller';

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('បន្ថែមបុគ្គលិកថ្មី', style: AppFonts.khHeading3),
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
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'លេខសម្ងាត់ (Password)',
                      labelStyle: AppFonts.khBodySmall,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: roleVal,
                    decoration: InputDecoration(
                      labelText: 'តួនាទី (Role)',
                      labelStyle: AppFonts.khBodySmall,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'seller',
                        child: Text('អ្នកលក់ (Seller)', style: AppFonts.khBody),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text(
                          'អ្នកគ្រប់គ្រង (Admin)',
                          style: AppFonts.khBody,
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          roleVal = val;
                        });
                      }
                    },
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

                  final success = await DataLocal.instance.createNewUser(
                    username: u,
                    password: p,
                    role: roleVal,
                  );
                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'បានបន្ថែមបុគ្គលិកថ្មីជោគជ័យ!',
                            style: AppFonts.khBody.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      onSuccess();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'ឈ្មោះគណនីនេះមានរួចហើយ!',
                            style: AppFonts.khBody.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
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
    },
  );
}
