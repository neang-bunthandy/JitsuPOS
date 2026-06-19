import 'package:flutter/material.dart';
import 'package:project_pos/core/app_fonts.dart';
import 'package:project_pos/data/local_data.dart';

void showResetConfirmationDialog({
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(
          'បញ្ជាក់ការលុប',
          style: AppFonts.khHeading3.copyWith(color: Colors.red.shade700),
        ),
        content: Text(
          'តើអ្នកពិតជាចង់កំណត់របាយការណ៍ឡើងវិញមែនទេ? ទិន្នន័យលក់ទាំងអស់នឹងត្រូវលុបចោល។\n\nចំណាំ៖ ស្តុកទំនិញ និងគណនីបុគ្គលិករបស់អ្នកនឹងមិនមានការប៉ះពាល់ឡើយ។',
          style: AppFonts.khBody,
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
              Navigator.of(dialogContext).pop();
              await DataLocal.instance.resetSalesDataOnly();
              onSuccess();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'បានកំណត់របាយការណ៍ឡើងវិញជោគជ័យ!',
                      style: AppFonts.khBody.copyWith(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'យល់ព្រម',
              style: AppFonts.khButton.copyWith(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}
