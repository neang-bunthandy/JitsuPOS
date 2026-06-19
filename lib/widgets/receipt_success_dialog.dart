import 'package:flutter/material.dart';
import 'package:project_pos/core/app_fonts.dart';
import 'package:project_pos/core/app_colors.dart';

class ReceiptSuccessDialog extends StatelessWidget {
  final String dateStr;
  final double totalSales;
  final VoidCallback onPrint;
  final VoidCallback onShare;
  final VoidCallback onConfirm;

  const ReceiptSuccessDialog({
    super.key,
    required this.dateStr,
    required this.totalSales,
    required this.onPrint,
    required this.onShare,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      contentPadding: const EdgeInsets.all(24.0),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                'ការទូទាត់បានជោគជ័យ!',
                style: AppFonts.khHeading3.copyWith(
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'វិក្កយបត្រត្រូវបានរក្សាទុក',
                style: AppFonts.khBodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Divider(height: 32, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('កាលបរិច្ឆេទ៖', style: AppFonts.khCaption),
                  Text(dateStr, style: AppFonts.enCaption),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('វិធីទូទាត់៖', style: AppFonts.khCaption),
                  Text(
                    'ស្កេន KHQR',
                    style: AppFonts.khCaption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ទឹកប្រាក់សរុប៖',
                    style: AppFonts.khBody.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${totalSales.toStringAsFixed(2)}',
                    style: AppFonts.enBody.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPrint,
                      icon: const Icon(Icons.print, size: 18),
                      label: Text('បោះពុម្ព', style: AppFonts.khLabel),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share, size: 18),
                      label: Text('ចែករំលែក', style: AppFonts.khLabel),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('យល់ព្រម', style: AppFonts.khButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
