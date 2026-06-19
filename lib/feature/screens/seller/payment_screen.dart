import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_pos/core/app_fonts.dart';
import 'package:project_pos/core/app_colors.dart';
import 'package:project_pos/data/local_data.dart';
import 'package:project_pos/widgets/receipt_success_dialog.dart';
import 'package:project_pos/widgets/receipt_screenshot_generator.dart';

class PaymentScreen extends StatefulWidget {
  final Map<int, int> cart;
  final List<Map<String, dynamic>> allProducts;
  final VoidCallback onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.cart,
    required this.allProducts,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  double _totalSales = 0.0;
  double _totalCost = 0.0;
  double _profit = 0.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _calculateTotals() {
    double sales = 0.0;
    double cost = 0.0;

    widget.cart.forEach((productId, qty) {
      final product = widget.allProducts.firstWhere(
        (p) => p['id'] == productId,
        orElse: () => {},
      );
      if (product.isNotEmpty) {
        final price =
            double.tryParse(product['price']?.toString() ?? '0.0') ?? 0.0;
        final costPrice =
            double.tryParse(product['cost_price']?.toString() ?? '0.0') ?? 0.0;
        sales += price * qty;
        cost += costPrice * qty;
      }
    });

    setState(() {
      _totalSales = sales;
      _totalCost = cost;
      _profit = sales - cost;
    });
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      final now = DateTime.now();
      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      await DataLocal.instance.completeSaleTransaction(
        totalAmount: _totalSales,
        totalCost: _totalCost,
        profit: _profit,
        saleDate: formattedDate,
        soldProducts: widget.cart,
      );

      if (!mounted) return;
      _showReceiptDialog(formattedDate);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ការទូទាត់បរាជ័យ៖ $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<pw.Document> _generateInvoicePdf(String dateStr) async {
    final List<Map<String, dynamic>> cartProducts = [];
    widget.cart.forEach((productId, qty) {
      final product = widget.allProducts.firstWhere(
        (p) => p['id'] == productId,
        orElse: () => {},
      );
      if (product.isNotEmpty) {
        cartProducts.add({
          'name': product['name'],
          'price':
              double.tryParse(product['price']?.toString() ?? '0.0') ?? 0.0,
          'qty': qty,
        });
      }
    });

    return await ReceiptScreenshotGenerator.generate(
      dateStr,
      cartProducts,
      _totalSales,
    );
  }

  Future<void> _printInvoice(String dateStr) async {
    try {
      final pdf = await _generateInvoicePdf(dateStr);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ការបោះពុម្ភបរាជ័យ៖ $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareInvoice(String dateStr) async {
    try {
      final pdf = await _generateInvoicePdf(dateStr);
      final pdfBytes = await pdf.save();

      final directory = await getTemporaryDirectory();
      final formattedDateTime = dateStr.replaceAll(' ', '_').replaceAll(':', '-');
      final file = File(
        '${directory.path}/receipt_jitsupos-$formattedDateTime.pdf',
      );
      await file.writeAsBytes(pdfBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'វិក្កយបត្រ POS - $dateStr',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ការចែករំលែកបរាជ័យ៖ $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReceiptDialog(String dateStr) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ReceiptSuccessDialog(
          dateStr: dateStr,
          totalSales: _totalSales,
          onPrint: () => _printInvoice(dateStr),
          onShare: () => _shareInvoice(dateStr),
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pop();
            widget.onPaymentSuccess();
          },
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
          'ការទូទាត់ប្រាក់',
          style: AppFonts.khHeading3.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.black12, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'បញ្ជីទំនិញដែលបានជ្រើសរើស',
                      style: AppFonts.khBody.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24, color: Colors.black12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.cart.length,
                      itemBuilder: (context, index) {
                        final productId = widget.cart.keys.elementAt(index);
                        final qty = widget.cart[productId]!;
                        final product = widget.allProducts.firstWhere(
                          (p) => p['id'] == productId,
                          orElse: () => {},
                        );

                        if (product.isEmpty) return const SizedBox.shrink();

                        final name = product['name'] ?? '';
                        final price =
                            double.tryParse(
                              product['price']?.toString() ?? '0.0',
                            ) ??
                            0.0;
                        final subtotal = price * qty;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '$name (x$qty)',
                                  style: AppFonts.khBodySmall,
                                ),
                              ),
                              Text(
                                '\$${subtotal.toStringAsFixed(2)}',
                                style: AppFonts.enBody.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(height: 24, color: Colors.black12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ទឹកប្រាក់សរុប',
                          style: AppFonts.khBody.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${_totalSales.toStringAsFixed(2)}',
                          style: AppFonts.enHeading3.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.black12, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'ស្កេនដើម្បីទូទាត់ KHQR',
                        style: AppFonts.khBody.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/KHQR.jpg',
                                width: 180,
                                height: 180,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${_totalSales.toStringAsFixed(2)}',
                              style: AppFonts.enHeading3.copyWith(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'បន្ទាប់ពីអតិថិជនស្កេនរួច សូមចុចប៊ូតុងបញ្ជាក់ខាងក្រោម',
                        style: AppFonts.khCaption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'បញ្ជាក់ការទូទាត់',
                        style: AppFonts.khButton.copyWith(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
