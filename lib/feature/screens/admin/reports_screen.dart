import 'package:flutter/material.dart';
import 'package:project_pos/core/app_colors.dart';
import 'package:project_pos/core/app_fonts.dart';
import 'package:project_pos/data/local_data.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> _sales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final salesData = await DataLocal.instance.getAllSales();
      setState(() {
        _sales = salesData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading sales: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        title: Text(
          'របាយការណ៍',
          style: AppFonts.khHeading3.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSales),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sales.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 72,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'មិនទាន់មានរបាយការណ៍លក់នៅឡើយទេ',
                    style: AppFonts.khBody.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _sales.length,
              itemBuilder: (context, index) {
                final sale = _sales[index];
                final totalAmount =
                    double.tryParse(
                      sale['total_amount']?.toString() ?? '0.0',
                    ) ??
                    0.0;
                final totalCost =
                    double.tryParse(sale['total_cost']?.toString() ?? '0.0') ??
                    0.0;
                final profit =
                    double.tryParse(sale['profit']?.toString() ?? '0.0') ?? 0.0;
                final saleDate = sale['sale_date']?.toString() ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'វិក្កយបត្រ ID #${index + 1}',
                              style: AppFonts.khBody.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // ignore: unnecessary_string_interpolations
                            Text("$saleDate"),
                          ],
                        ),
                        const Divider(height: 24, color: Colors.black12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ចំណូលសរុប',
                              style: AppFonts.khBodySmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "ថ្លៃដើមសរុប",
                              style: AppFonts.khBodySmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "ប្រាក់ចំណេញ",
                              style: AppFonts.khBodySmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$${totalAmount.toStringAsFixed(2)}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "\$${totalCost.toStringAsFixed(2)}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "\$${profit.toStringAsFixed(2)}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
