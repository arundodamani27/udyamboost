
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/ai_service.dart';

class _Brand {
  static const Color cream = Color(0xFFFAF3E1);
  static const Color beige = Color(0xFFF5E7C6);
  static const Color orange = Color(0xFFFF6D1F);
  static const Color charcoal = Color(0xFF222222);
  static const Color muted = Color(0xFF77716A);
  static const Color line = Color(0xFFE8DDC9);
  static const Color white = Colors.white;
}

enum _ContentType {
  description('Description', 'Your description', Icons.description_outlined,
      'Write a detailed product description'),
  caption('Instagram Caption', 'Your caption', Icons.camera_alt_outlined,
      'Create an engaging social media caption'),
  hashtags('Hashtags', 'Your hashtags', Icons.tag_rounded,
      'Find relevant hashtags for your product'),
  whatsapp('WhatsApp Message', 'Your WhatsApp message',
      Icons.chat_outlined, 'Create a message to share with customers');

  const _ContentType(
    this.label,
    this.resultTitle,
    this.icon,
    this.subtitle,
  );

  final String label;
  final String resultTitle;
  final IconData icon;
  final String subtitle;
}

class MarketingStudioScreen extends StatefulWidget {
  const MarketingStudioScreen({super.key});

  @override
  State<MarketingStudioScreen> createState() =>
      _MarketingStudioScreenState();
}

class _MarketingStudioScreenState extends State<MarketingStudioScreen> {
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
  _ContentType _type = _ContentType.description;
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

    final type = _type;
    final name = _nameController.text.trim();
    final category = _category;
    final price = double.parse(_priceController.text.trim());

    try {
      final text = await switch (type) {
        _ContentType.description =>
          AiService.productDescription(name, category, price),
        _ContentType.caption =>
          AiService.instagramCaption(name, category, price),
        _ContentType.hashtags => AiService.hashtags(name, category),
        _ContentType.whatsapp =>
          AiService.whatsappMessage(name, category, price),
      };

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
    _showMessage('Copied to clipboard!');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _Brand.charcoal,
        ),
      );
  }

  void _selectType(_ContentType type) {
    if (type == _type) return;

    setState(() {
      _type = type;
      _result = null;
    });
  }

  InputDecoration _decoration(
    String label,
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _Brand.muted, size: 20),
      labelStyle: const TextStyle(color: _Brand.muted),
      hintStyle: const TextStyle(color: Color(0xFFAAA39A), fontSize: 13),
      filled: true,
      fillColor: _Brand.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Brand.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Brand.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Brand.orange, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _sectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _Brand.charcoal,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: _Brand.muted,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _Brand.orange,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: _Brand.charcoal,
                size: 25,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Marketing Studio',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: _Brand.charcoal,
                      letterSpacing: -0.7,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Create content that helps your business grow.',
                    style: TextStyle(
                      fontSize: 13,
                      color: _Brand.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _Brand.charcoal,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your ideas.\\nOur AI. Your growth.',
                      style: TextStyle(
                        fontSize: 23,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: _Brand.cream,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'Generate product descriptions, social media '
                      'captions and promotional messages in seconds.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: _Brand.cream.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: _Brand.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: _Brand.charcoal,
                  size: 43,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          'What would you like to create?',
          'Choose the type of marketing content you need.',
        ),
        const SizedBox(height: 15),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 650 ? 4 : 2;
            final spacing = 10.0;
            final itemWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _ContentType.values.map((type) {
                final selected = type == _type;

                return SizedBox(
                  width: itemWidth,
                  child: InkWell(
                    onTap: _isGenerating ? null : () => _selectType(type),
                    borderRadius: BorderRadius.circular(13),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: selected ? _Brand.beige : _Brand.white,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: selected ? _Brand.orange : _Brand.line,
                          width: selected ? 1.6 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            type.icon,
                            size: 22,
                            color: _Brand.charcoal,
                          ),
                          const SizedBox(height: 11),
                          Text(
                            type.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: _Brand.charcoal,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            selected ? 'Selected' : 'Choose',
                            style: TextStyle(
                              fontSize: 11,
                              color: selected
                                  ? _Brand.charcoal
                                  : _Brand.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _Brand.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Brand.line),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeading(
              'Product details',
              'Enter a few details to personalise your content.',
            ),
            const SizedBox(height: 23),
            const Text(
              'Product name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _Brand.charcoal,
              ),
            ),
            const SizedBox(height: 9),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: _decoration(
                'Product name',
                'e.g. Handmade cotton saree',
                Icons.sell_outlined,
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Enter the product name'
                      : null,
            ),
            const SizedBox(height: 19),
            const Text(
              'Business category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _Brand.charcoal,
              ),
            ),
            const SizedBox(height: 9),
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              decoration: _decoration(
                'Category',
                'Choose a category',
                Icons.category_outlined,
              ),
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: _isGenerating
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
            ),
            const SizedBox(height: 19),
            const Text(
              'Product price (₹)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _Brand.charcoal,
              ),
            ),
            const SizedBox(height: 9),
            TextFormField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _generate(),
              decoration: _decoration(
                'Price',
                'e.g. 499',
                Icons.currency_rupee_rounded,
              ),
              validator: (value) {
                final price = double.tryParse(value?.trim() ?? '');
                if (price == null || price < 0 || !price.isFinite) {
                  return 'Enter a valid price, like 499 or 49.50';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Brand.orange,
                  foregroundColor: _Brand.charcoal,
                  disabledBackgroundColor:
                      _Brand.orange.withValues(alpha: 0.55),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: _isGenerating
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: _Brand.charcoal,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 19),
                          SizedBox(width: 9),
                          Text(
                            'Generate Content',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Powered by AI • Ready in seconds',
                style: TextStyle(
                  color: _Brand.muted,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final result = _result;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 250),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _Brand.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Brand.line),
      ),
      child: result == null
          ? _buildResultPlaceholder()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _Brand.beige,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: _Brand.charcoal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Generated content',
                            style: TextStyle(
                              color: _Brand.charcoal,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _type.resultTitle,
                            style: const TextStyle(
                              color: _Brand.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _copyResult,
                      tooltip: 'Copy content',
                      style: IconButton.styleFrom(
                        backgroundColor: _Brand.beige,
                        foregroundColor: _Brand.charcoal,
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: _Brand.line),
                const SizedBox(height: 14),
                SelectableText(
                  result,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.75,
                    color: _Brand.charcoal,
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _copyResult,
                    icon: const Icon(Icons.copy_rounded, size: 17),
                    label: const Text('Copy content'),
                    style: TextButton.styleFrom(
                      foregroundColor: _Brand.charcoal,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildResultPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: _Brand.beige,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                color: _Brand.charcoal,
                size: 34,
              ),
            ),
            const SizedBox(height: 17),
            const Text(
              'Your content will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _Brand.charcoal,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a content type, enter your product details, '
              'and click Generate Content.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _Brand.muted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Brand.cream,
      appBar: AppBar(
        backgroundColor: _Brand.cream,
        foregroundColor: _Brand.charcoal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Marketing Studio',
          style: TextStyle(
            color: _Brand.charcoal,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final maxWidth = wide ? 1240.0 : 760.0;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    wide ? 32 : 20,
                    14,
                    wide ? 32 : 20,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPageHeader(),
                      const SizedBox(height: 30),
                      _buildContentTypes(),
                      const SizedBox(height: 25),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildForm()),
                            const SizedBox(width: 22),
                            Expanded(child: _buildResultCard()),
                          ],
                        )
                      else ...[
                        _buildForm(),
                        const SizedBox(height: 22),
                        _buildResultCard(),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
