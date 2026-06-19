import 'package:flutter/material.dart';
import 'package:project_pos/core/app_fonts.dart';
import 'package:project_pos/data/local_data.dart';

void showEditProductDialog({
  required BuildContext context,
  required Map<String, dynamic> product,
  required VoidCallback onSuccess,
}) {
  final id = product['id'] as int;
  final nameCtrl = TextEditingController(text: product['name']);
  final costPriceCtrl = TextEditingController(text: product['cost_price']?.toString() ?? '');
  final priceCtrl = TextEditingController(text: product['price']?.toString() ?? '');
  final quantityCtrl = TextEditingController(text: product['quantity']?.toString() ?? '');
  final optionCtrl = TextEditingController(text: product['option'] ?? '');

  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(
          'កែប្រែផលិតផល',
          style: AppFonts.khHeading3.copyWith(color: Colors.blue),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'ឈ្មោះផលិតផល (Product Name)',
                    labelStyle: AppFonts.khBodySmall,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'សូមបញ្ចូលឈ្មោះផលិតផល';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: costPriceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'ថ្លៃដើម (Cost Price)',
                    labelStyle: AppFonts.khBodySmall,
                    prefixText: '\$ ',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'សូមបញ្ចូលថ្លៃដើម';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null) {
                      return 'សូមបញ្ចូលចំនួនលេខឲ្យត្រឹមត្រូវ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'ថ្លៃលក់ (Sell Price)',
                    labelStyle: AppFonts.khBodySmall,
                    prefixText: '\$ ',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'សូមបញ្ចូលថ្លៃលក់';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null) {
                      return 'សូមបញ្ចូលចំនួនលេខឲ្យត្រឹមត្រូវ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: quantityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ចំនួនក្នុងស្តុក (Stock Quantity)',
                    labelStyle: AppFonts.khBodySmall,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'សូមបញ្ចូលចំនួនក្នុងស្តុក';
                    }
                    final parsed = int.tryParse(value);
                    if (parsed == null) {
                      return 'សូមបញ្ចូលចំនួនគត់ឲ្យត្រឹមត្រូវ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: optionCtrl,
                  decoration: InputDecoration(
                    labelText: 'ជម្រើសបន្ថែម (Option - optional)',
                    labelStyle: AppFonts.khBodySmall,
                  ),
                ),
              ],
            ),
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
              if (formKey.currentState!.validate()) {
                final name = nameCtrl.text.trim();
                final costPrice = costPriceCtrl.text.trim();
                final price = priceCtrl.text.trim();
                final quantity = quantityCtrl.text.trim();
                final option = optionCtrl.text.trim().isEmpty ? null : optionCtrl.text.trim();

                await DataLocal.instance.updateProduct(
                  id: id,
                  name: name,
                  costPrice: double.parse(costPrice),
                  price: double.parse(price),
                  quantity: int.parse(quantity),
                  option: option,
                );

                if (context.mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'បានកែប្រែផលិតផលជោគជ័យ!',
                        style: AppFonts.khBody.copyWith(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  onSuccess();
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
}
