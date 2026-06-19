import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:project_pos/core/app_fonts.dart';
import 'package:project_pos/core/app_colors.dart';
import 'package:project_pos/data/local_data.dart';
import 'package:project_pos/data/session_manager.dart';
import 'package:project_pos/feature/screens/login/login_screen.dart';
import 'package:project_pos/feature/screens/seller/payment_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  final Map<int, int> _cart = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(() {
      _filterProducts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final products = await DataLocal.instance.getAllProducts();
      setState(() {
        _allProducts = products;
        _isLoading = false;
        _filterProducts(_searchController.text);
      });
    } catch (e) {
      debugPrint("Error loading products: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = List.from(_allProducts);
      });
    } else {
      setState(() {
        _filteredProducts = _allProducts.where((p) {
          final name = p['name']?.toString().toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  Future<void> _scanBarcode() async {
    try {
      final String scannedCode = await FlutterBarcodeScanner.scanBarcode(
        '#0000ff',
        'បោះបង់',
        true,
        ScanMode.BARCODE,
      );

      if (scannedCode == '-1' || !mounted) return;

      // Try to find product by ID
      final matched = _allProducts.firstWhere(
        (p) => p['id']?.toString() == scannedCode,
        orElse: () => {},
      );

      if (matched.isNotEmpty) {
        _addToCart(matched);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('បានបន្ថែម៖ ${matched['name']}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        // If not matching ID exactly, filter list by the barcode text
        _searchController.text = scannedCode;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ការស្កេនបរាជ័យ៖ $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    final productId = product['id'] as int;
    final maxStock = int.tryParse(product['quantity']?.toString() ?? '0') ?? 0;
    final currentQty = _cart[productId] ?? 0;

    if (maxStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ទំនិញនេះអស់ពីស្តុកហើយ!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (currentQty >= maxStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'មិនអាចជ្រើសរើសលើសពីចំនួនក្នុងស្តុក ($maxStock) បានទេ!',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _cart[productId] = currentQty + 1;
    });
  }

  void _removeFromCart(int productId) {
    final currentQty = _cart[productId] ?? 0;
    if (currentQty <= 0) return;

    setState(() {
      if (currentQty == 1) {
        _cart.remove(productId);
      } else {
        _cart[productId] = currentQty - 1;
      }
    });
  }

  double _calculateTotalAmount() {
    double total = 0.0;
    _cart.forEach((productId, qty) {
      final product = _allProducts.firstWhere(
        (p) => p['id'] == productId,
        orElse: () => {},
      );
      if (product.isNotEmpty) {
        final price =
            double.tryParse(product['price']?.toString() ?? '0.0') ?? 0.0;
        total += price * qty;
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotalAmount();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        title: Text(
          'ផ្ទាំងលក់ទំនិញ',
          style: AppFonts.khHeading3.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProducts),
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
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ស្វែងរកទំនិញ...',
                hintStyle: AppFonts.khCaption,
                prefixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanBarcode,
                ),
                suffixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.black12,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.black12,
                    width: 1.0,
                  ),
                ),
              ),
              style: AppFonts.khBody,
            ),
          ),

          // Product list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? Center(
                    child: Text(
                      'មិនមានទំនិញក្នុងស្តុកឡើយ',
                      style: AppFonts.khBody.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final id = product['id'] as int;
                      final name = product['name'] ?? '';
                      final price =
                          double.tryParse(
                            product['price']?.toString() ?? '0.0',
                          ) ??
                          0.0;
                      final stock =
                          int.tryParse(
                            product['quantity']?.toString() ?? '0',
                          ) ??
                          0;
                      final option = product['option'];
                      final qtyInCart = _cart[id] ?? 0;

                      return Card(
                        color: Colors.white,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(
                            color: Colors.black12,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: name product & Select button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: AppFonts.khBody.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  stock <= 0
                                      ? ElevatedButton(
                                          onPressed: null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.grey.shade300,
                                            foregroundColor:
                                                Colors.grey.shade600,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          child: Text(
                                            'អស់ស្តុក',
                                            style: AppFonts.khButton.copyWith(
                                              fontSize: 13,
                                            ),
                                          ),
                                        )
                                      : qtyInCart > 0
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .blue
                                                .shade50, // ពណ៌ផ្ទៃព្រាលៗ
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                constraints:
                                                    const BoxConstraints(),
                                                icon: const Icon(
                                                  Icons.remove,
                                                  color: Colors.blue,
                                                  size: 20,
                                                ),
                                                onPressed: () =>
                                                    _removeFromCart(id),
                                              ),
                                              Text(
                                                '$qtyInCart',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              IconButton(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                constraints:
                                                    const BoxConstraints(),
                                                icon: const Icon(
                                                  Icons.add,
                                                  color: Colors.blue,
                                                  size: 20,
                                                ),
                                                onPressed: () =>
                                                    _addToCart(product),
                                              ),
                                            ],
                                          ),
                                        )
                                      : ElevatedButton.icon(
                                          onPressed: () => _addToCart(product),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0,
                                              vertical: 8.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.add_shopping_cart,
                                            size: 18,
                                          ),
                                          label: Text(
                                            'រើសយក',
                                            style: AppFonts.khButton.copyWith(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'តម្លៃ: \$${price.toStringAsFixed(2)} | ស្តុក: $stock${option != null && option.toString().isNotEmpty ? " $option" : ""}',
                                style: AppFonts.khCaption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ទឹកប្រាក់សរុប',
                    style: AppFonts.khCaption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${totalAmount.toStringAsFixed(2)}',
                    style: AppFonts.enHeading2.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _cart.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              cart: _cart,
                              allProducts: _allProducts,
                              onPaymentSuccess: () {
                                setState(() {
                                  _cart.clear();
                                });
                                _loadProducts();
                              },
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text('ទៅកាន់ការទូទាត់', style: AppFonts.khButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
