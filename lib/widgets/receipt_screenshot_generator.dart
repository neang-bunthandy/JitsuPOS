import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:project_pos/core/app_fonts.dart';

class ReceiptScreenshotGenerator {
  static Future<pw.Document> generate(
    String dateStr,
    List<Map<String, dynamic>> cartProducts,
    double totalSales,
  ) async {
    final screenshotController = ScreenshotController();
    final receiptWidget = Container(
      width: 400,
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Jitsu POS',
              style: AppFonts.enHeading3.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'វិក្កយបត្រទូទាត់ប្រាក់',
              style: AppFonts.khHeading3.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.black, thickness: 1),
          Text(
            'កាលបរិច្ឆេទ៖ $dateStr',
            style: AppFonts.khBodySmall.copyWith(color: Colors.black),
          ),
          Text(
            'វិធីទូទាត់៖ ស្កេន KHQR',
            style: AppFonts.khBodySmall.copyWith(color: Colors.black),
          ),
          const Divider(color: Colors.black, thickness: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'ឈ្មោះទំនិញ',
                  style: AppFonts.khBodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    'ចំនួន',
                    style: AppFonts.khBodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'សរុប',
                    style: AppFonts.khBodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.black, thickness: 0.5),
          ...cartProducts.map((item) {
            final name = item['name'] ?? '';
            final qty = item['qty'];
            final subtotal = item['price'] * qty;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      name,
                      style: AppFonts.khBodySmall.copyWith(color: Colors.black),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'x$qty',
                        style: AppFonts.enBodySmall.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '\$${subtotal.toStringAsFixed(2)}',
                        style: AppFonts.enBodySmall.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(color: Colors.black, thickness: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ទឹកប្រាក់សរុប៖',
                style: AppFonts.khBody.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '\$${totalSales.toStringAsFixed(2)}',
                style: AppFonts.enHeading3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'សូមអរគុណ! / Thank you!',
              style: AppFonts.khBodySmall.copyWith(color: Colors.black),
            ),
          ),
        ],
      ),
    );

    final capturedImage = await screenshotController.captureFromWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Material(color: Colors.transparent, child: receiptWidget),
      ),
      delay: const Duration(milliseconds: 100),
      context: null,
    );
    final pdf = pw.Document();
    final imageProvider = pw.MemoryImage(capturedImage);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(imageProvider));
        },
      ),
    );
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    return pdf;
  }
}
