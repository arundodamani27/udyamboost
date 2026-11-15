import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/ai_service.dart';

class MarketingStudioScreen extends StatefulWidget {
  const MarketingStudioScreen({super.key});

  @override
  State<MarketingStudioScreen> createState() => _MarketingStudioScreenState();
}

class _MarketingStudioScreenState extends State<MarketingStudioScreen> {
  static const Color primary = Color(0xFF2457E6);
  static const Color dark = Color(0xFF14213D);
  static const Color background = Color(0xFFF7F9FC);
  static const Color muted = Color(0xFF64748B);

  static const List<String> _categories = [
    'General',
    'Clothing',
    'Food & Beverages',
    'Electronics',
    'Beauty',
    'Home & Lifestyle',
    'Handicrafts',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  String _category = _categories.first;
  bool _isGenerating = false;
  String? _result;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_isGenerating || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isGenerating = true);

    try {
      final text = await AiService.productDescription(
        _nameController.text.trim(),
        _category,
        double.parse(_priceController.text.trim()),
      );
      if (!mounted) return;
      setState(() => _result = text);
    } catch (error, stackTrace) {
      debugPrint('MarketingStudio: generation failed: $error');
      debugPrint('$stackTrace');
      if (!mounted) return;
      _showMessage('Could not generate right now. Please try again.');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _copyResult() async {
    final text = _result;
    if (text == null) return;

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _showMessage('Copied!');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: muted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFDCE3ED)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFDCE3ED)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: dark,
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Product name'),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: _decoration('e.g. Handmade cotton saree', Icons.sell_outlined),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter the product name'
                : null,
          ),
          const SizedBox(height: 18),
          _label('Category'),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: _decoration('Choose a category', Icons.category_outlined),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: _isGenerating
                ? null
                : (value) {
                    if (value != null) setState(() => _category = value);
                  },
          ),
          const SizedBox(height: 18),
          _label('Price (₹)'),
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _generate(),
            decoration: _decoration('e.g. 499', Icons.currency_rupee_rounded),
            validator: (value) {
              final price = double.tryParse(value?.trim() ?? '');
              if (price == null || price < 0 || !price.isFinite) {
                return 'Enter a valid price, like 499 or 49.50';
              }
              return null;
            },
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primary.withValues(alpha: 0.6),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isGenerating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Generate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEFF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: primary, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Your description',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: dark,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _copyResult,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy'),
                style: TextButton.styleFrom(foregroundColor: primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            text,
            style: const TextStyle(fontSize: 15, height: 1.5, color: dark),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: dark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'AI Marketing Studio',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Describe your product and let AI write the description for you.',
                style: TextStyle(fontSize: 14, height: 1.4, color: muted),
              ),
              const SizedBox(height: 22),
              _buildForm(),
              if (result != null) ...[
                const SizedBox(height: 26),
                _buildResultCard(result),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
