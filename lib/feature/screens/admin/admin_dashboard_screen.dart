import 'package:flutter/material.dart';
import 'package:project_pos/core/app_fonts.dart';
import 'package:project_pos/core/app_colors.dart';
import 'package:project_pos/data/local_data.dart';
import 'package:project_pos/data/session_manager.dart';
import 'package:project_pos/feature/screens/login/login_screen.dart';
import 'package:project_pos/feature/screens/admin/reports_screen.dart';
import 'package:project_pos/feature/screens/admin/manage_stock.dart';
import 'package:project_pos/feature/screens/admin/settings_screen.dart';
import 'package:project_pos/widgets/reset_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  double _totalSales = 0.0;
  double _totalProfit = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final report = await DataLocal.instance.getAdminReport();
      setState(() {
        _totalSales = report['sales'] ?? 0.0;
        _totalProfit = report['profit'] ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displaySales = _totalSales > 0
        ? _totalSales.toStringAsFixed(2)
        : '0.00';

    final displayProfit = _totalProfit > 0
        ? _totalProfit.toStringAsFixed(2)
        : '0.00';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ).then((_) {
              _loadReportData();
            });
          },
        ),
        title: Text(
          'Admin Dashboard',
          style: AppFonts.enHeading3.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SessionManager.clearSession();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Report Title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      "របាយការណ៍ប្រចាំថ្ងៃ",
                      style: AppFonts.khHeading3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Sales and Profit Cards
                  Row(
                    children: [
                      // Total Sales Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 16.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: Colors.black12,
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue.shade50,
                                child: Icon(
                                  Icons.monetization_on_outlined,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ចំណូលសរុប",
                                      style: AppFonts.khCaption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      '\$$displaySales',
                                      style: AppFonts.enHeading3.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),

                      // Net Profit Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 16.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: Colors.black12,
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.green.shade50,
                                child: Icon(
                                  Icons.trending_up,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ប្រាក់ចំណូល",
                                      style: AppFonts.khCaption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      '\$$displayProfit',
                                      style: AppFonts.enHeading3.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      "តារាងគ្រប់គ្រង",
                      style: AppFonts.khHeading3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: Colors.black12, width: 1.0),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: const Icon(
                              Icons.assessment_outlined,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text("មើលរបាយការណ៍", style: AppFonts.khBody),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.black38,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade50,
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.orange,
                            ),
                          ),
                          title: Text("គ្រប់គ្រងស្តុក", style: AppFonts.khBody),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.black38,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ManageStockScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, color: Colors.black12),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade50,
                            child: const Icon(
                              Icons.restore_outlined,
                              color: Colors.red,
                            ),
                          ),
                          title: Text(
                            "កំណត់របាយការណ៍ឡើងវិញ",
                            style: AppFonts.khBody.copyWith(
                              color: Colors.red.shade700,
                            ),
                          ),
                          onTap: () {
                            showResetConfirmationDialog(
                              context: context,
                              onSuccess: _loadReportData,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
