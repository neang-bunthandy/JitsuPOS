import 'package:flutter/material.dart';
import 'package:project_pos/core/app_fonts.dart';
import 'package:project_pos/core/app_colors.dart';
import 'package:project_pos/data/local_data.dart';
import 'package:project_pos/widgets/add_product_dialog.dart';
import 'package:project_pos/widgets/edit_product_dialog.dart';

class ManageStockScreen extends StatefulWidget {
  const ManageStockScreen({super.key});

  @override
  State<ManageStockScreen> createState() => _ManageStockScreenState();
}

class _ManageStockScreenState extends State<ManageStockScreen> {
  List<Map<String, dynamic>> _productsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final list = await DataLocal.instance.getAllProducts();
      setState(() {
        _productsList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteProduct(Map<String, dynamic> product) {
    final id = product['id'] as int;
    final name = product['name'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'បញ្ជាក់ការលុបផលិតផល',
            style: AppFonts.khHeading3.copyWith(color: Colors.red.shade700),
          ),
          content: Text(
            'តើអ្នកពិតជាចង់លុបផលិតផល "$name" នេះមែនទេ?',
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
                await DataLocal.instance.deleteProduct(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'បានលុបផលិតផលជោគជ័យ!',
                        style: AppFonts.khBody.copyWith(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadProducts();
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
          'គ្រប់គ្រងស្តុក',
          style: AppFonts.khHeading2.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _productsList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 72,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'មិនទាន់មានផលិតផលនៅឡើយទេ',
                    style: AppFonts.khHeading3.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'សូមចុចប៊ូតុង + ខាងក្រោមដើម្បីបន្ថែមថ្មី',
                    style: AppFonts.khBodySmall.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _productsList.length,
              itemBuilder: (context, index) {
                final product = _productsList[index];
                final name = product['name'] ?? '';
                final costPriceVal =
                    double.tryParse(product['cost_price']?.toString() ?? '0') ??
                    0.0;
                final sellPriceVal =
                    double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;
                final stockVal =
                    int.tryParse(product['quantity']?.toString() ?? '0') ?? 0;
                final optionVal = product['option']?.toString() ?? '';
                final optionSuffix = optionVal.isNotEmpty
                    ? ' | $optionVal'
                    : '';

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: const BorderSide(color: Colors.black12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    title: Text(
                      name,
                      style: AppFonts.khHeading3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'costPrice : \$${costPriceVal.toStringAsFixed(2)} | sell : \$${sellPriceVal.toStringAsFixed(2)} | stock : $stockVal$optionSuffix',
                        style: AppFonts.enCaption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showEditProductDialog(
                              context: context,
                              product: product,
                              onSuccess: _loadProducts,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteProduct(product),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddProductDialog(context: context, onSuccess: _loadProducts);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
