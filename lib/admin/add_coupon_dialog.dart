import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/service/CouponService.dart'; // Import NumberFormat để hiển thị USD
// import '../../models/coupon_model.dart'; // Không cần trực tiếp ở đây
// import '../../utils/colors.dart';
// import '../../utils/sizes.dart';

class AddCouponDialog extends StatefulWidget {
  final CouponService couponService;

  const AddCouponDialog({
    super.key,
    required this.couponService,
  });

  @override
  State<AddCouponDialog> createState() => _AddCouponDialogState();
}

class _AddCouponDialogState extends State<AddCouponDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  double? _selectedDiscountAmountUSD; // Giá trị USD
  int _selectedMaxUses = 1;

  final List<int> _maxUsesOptions = List.generate(10, (index) => index + 1);
  // Sử dụng NumberFormat để hiển thị giá trị USD
  final NumberFormat _usdFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDiscountAmountUSD == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a discount value.'), backgroundColor: Colors.orange /*TColors.warning*/),
        );
        return;
      }

      _formKey.currentState!.save();
      final String code = _codeController.text.trim().toUpperCase();

      try {
        await widget.couponService.addCoupon(
          code: code,
          discountAmount: _selectedDiscountAmountUSD!, // Truyền giá trị USD
          maxUses: _selectedMaxUses,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Coupon "$code" added successfully!'), backgroundColor: Colors.green /*TColors.success*/),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red /*TColors.error*/),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Coupon'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Coupon Code (5 characters)',
                  hintText: 'e.g., SAVE5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  LengthLimitingTextInputFormatter(5),
                ],
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a coupon code.';
                  }
                  if (value.trim().length != 5) {
                    return 'Coupon code must be exactly 5 characters.';
                  }
                  if (!RegExp(r'^[A-Z0-9]{5}$').hasMatch(value.trim().toUpperCase())) {
                    return 'Code can only contain uppercase letters and numbers.';
                  }
                  return null;
                },
                onChanged: (value) {
                  _codeController.value = TextEditingValue(
                    text: value.toUpperCase(),
                    selection: _codeController.selection,
                  );
                },
              ),
              const SizedBox(height: 16.0 /*Sizes.spaceBtwInputFields*/),
              DropdownButtonFormField<double>(
                value: _selectedDiscountAmountUSD,
                decoration: const InputDecoration(
                  labelText: 'Discount Value (USD)', // <<--- THAY ĐỔI LABEL
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                hint: const Text('Select value'),
                items: widget.couponService.allowedDiscountAmounts.map((double value) {
                  return DropdownMenuItem<double>(
                    value: value,
                    child: Text(_usdFormatter.format(value)), // Hiển thị giá trị USD đã định dạng
                  );
                }).toList(),
                onChanged: (double? newValue) {
                  setState(() {
                    _selectedDiscountAmountUSD = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a discount value.' : null,
              ),
              const SizedBox(height: 16.0 /*Sizes.spaceBtwInputFields*/),
              DropdownButtonFormField<int>(
                value: _selectedMaxUses,
                decoration: const InputDecoration(
                  labelText: 'Maximum Uses',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.repeat_one_outlined),
                ),
                items: _maxUsesOptions.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMaxUses = newValue;
                    });
                  }
                },
                validator: (value) => value == null ? 'Please select maximum uses.' : null,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Note: Coupon codes do not have an expiration date.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Create Coupon'),
          onPressed: _submitForm,
        ),
      ],
    );
  }
}