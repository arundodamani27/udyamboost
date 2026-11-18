import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// UdyamBoost brand palette (same values as app.dart).
class _Brand {
  static const Color cream = Color(0xFFFAF3E1);
  static const Color beige = Color(0xFFF5E7C6);
  static const Color tangerine = Color(0xFFFF6D1F);
  static const Color charcoal = Color(0xFF222222);

  static const Color muted = Color(0xB3222222);
  static const Color subtle = Color(0x73222222);
  static const Color line = Color(0x24222222);

  static const Color creamMuted = Color(0xB8FAF3E1);
  static const Color creamLine = Color(0x33FAF3E1);

  static const Color error = Color(0xFFB83A0A);
}

/// Width at which the page switches to a split brand-panel + form layout.
const double _splitBreakpoint = 960;

class BrandIdentityScreen extends StatefulWidget {
  final String businessName;
  final String ownerName;
  final String phone;
  final String category;
  final String location;
  final String description;

  const BrandIdentityScreen({
    super.key,
    required this.businessName,
    required this.ownerName,
    required this.phone,
    required this.category,
    required this.location,
    required this.description,
  });

  @override
  State<BrandIdentityScreen> createState() =>
      _BrandIdentityScreenState();
}

class _BrandIdentityScreenState extends State<BrandIdentityScreen> {
  static const double _formMaxWidth = 720;

  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  File? _logo;
  Color _primaryColor = const Color(0xFF2457E6);
  Color _secondaryColor = const Color(0xFF10B981);

  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _websiteController = TextEditingController();

  final List<Color> _brandColors = [
    const Color(0xFF2457E6),
    const Color(0xFF10B981),
    const Color(0xFF8B5CF6),
    const Color(0xFFF97316),
    const Color(0xFFEF4444),
    const Color(0xFF0F172A),
    const Color(0xFFEC4899),
    const Color(0xFF0891B2),
  ];

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _logo = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to select image.')),
      );
    }
  }

  @override
  void dispose() {
    _instagramController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<String?> _uploadLogo(String userId) async {
    if (_logo == null) return null;

    final supabase = Supabase.instance.client;

    final extension = _logo!.path.split('.').last.toLowerCase();

    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    final filePath = '$userId/logo.$extension';

    await supabase.storage
        .from('business-assets')
        .upload(
          filePath,
          _logo!,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );

    return supabase.storage
        .from('business-assets')
        .getPublicUrl(filePath);
  }

  Future<void> _continue() async {
    if (_isSaving) return;

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please log in before saving your business profile.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final logoUrl = await _uploadLogo(user.id);

      await supabase.from('business_profiles').upsert(
        {
          'user_id': user.id,
          'business_name': widget.businessName,
          'owner_name': widget.ownerName,
          'phone': widget.phone,
          'category': widget.category,
          'location': widget.location,
          'description': widget.description,
          'primary_color':
              '#${_primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
          'secondary_color':
              '#${_secondaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
          'instagram_url': _instagramController.text.trim().isEmpty
              ? null
              : _instagramController.text.trim(),
          'facebook_url': _facebookController.text.trim().isEmpty
              ? null
              : _facebookController.text.trim(),
          'website_url': _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          'logo_url': ?logoUrl,
        },
        onConflict: 'user_id',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            businessName: widget.businessName,
            category: widget.category,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save business profile: $error'),
          backgroundColor: _Brand.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ── PAGE ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Brand.cream,
      appBar: AppBar(
        backgroundColor: _Brand.cream,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _Brand.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Brand Identity',
          style: TextStyle(
            color: _Brand.charcoal,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: _Brand.line),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < _splitBreakpoint) {
              // Phones and tablets: one scrolling column.
              return _formPane(showIntro: true);
            }

            // Laptops and desktops: brand panel with live preview + form.
            return Row(
              children: [
                Expanded(flex: 5, child: _sidePanel()),
                Expanded(flex: 7, child: _formPane(showIntro: false)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sidePanel() {
    return Container(
      width: double.infinity,
      color: _Brand.charcoal,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(56, 48, 56, 48),
        child: Align(
          alignment: Alignment.topRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _logoMark(),
                const SizedBox(height: 56),
                _intro(onDark: true, roomy: true),
                const SizedBox(height: 40),
                _previewSection(onDark: true),
                const SizedBox(height: 20),
                _laterNote(onDark: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoMark() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: _Brand.tangerine,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: _Brand.charcoal,
            size: 25,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'UdyamBoost',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: _Brand.cream,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }

  Widget _formPane({required bool showIntro}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool roomy = constraints.maxWidth >= 680;
        final double hPad = roomy ? 40 : 22;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _formMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showIntro) ...[
                          _intro(onDark: false, roomy: roomy),
                          const SizedBox(height: 28),
                        ],

                        // LOGO
                        _section(
                          title: 'Business Logo',
                          subtitle: 'Add your existing business logo.',
                          showDivider: showIntro,
                          child: _buildLogoPicker(),
                        ),

                        // COLOURS
                        _section(
                          title: 'Brand Colours',
                          subtitle:
                              'Choose colours that represent your brand.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _colorPicker(
                                title: 'Primary colour',
                                selectedColor: _primaryColor,
                                onSelected: (color) {
                                  setState(() => _primaryColor = color);
                                },
                              ),
                              const SizedBox(height: 24),
                              _colorPicker(
                                title: 'Secondary colour',
                                selectedColor: _secondaryColor,
                                onSelected: (color) {
                                  setState(() => _secondaryColor = color);
                                },
                              ),
                            ],
                          ),
                        ),

                        // SOCIAL
                        _section(
                          title: 'Social Media & Website',
                          subtitle:
                              'Help customers discover your business online.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _socialField(
                                icon: Icons.camera_alt_outlined,
                                label: 'Instagram',
                                hint: 'https://instagram.com/yourbusiness',
                                controller: _instagramController,
                              ),
                              const SizedBox(height: 18),
                              _socialField(
                                icon: Icons.facebook,
                                label: 'Facebook',
                                hint: 'https://facebook.com/yourbusiness',
                                controller: _facebookController,
                              ),
                              const SizedBox(height: 18),
                              _socialField(
                                icon: Icons.language,
                                label: 'Website',
                                hint: 'https://yourbusiness.com',
                                controller: _websiteController,
                              ),
                            ],
                          ),
                        ),

                        // PREVIEW + NOTE (shown here on narrow layouts only;
                        // on desktop they live in the side panel)
                        if (showIntro) ...[
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: _Brand.line,
                          ),
                          const SizedBox(height: 24),
                          _previewSection(onDark: false),
                          const SizedBox(height: 20),
                          _laterNote(onDark: false),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // BOTTOM CONTINUE BAR
            Container(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
              decoration: const BoxDecoration(
                color: _Brand.cream,
                border: Border(top: BorderSide(color: _Brand.line)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _formMaxWidth),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _Brand.tangerine,
                        foregroundColor: _Brand.charcoal,
                        disabledBackgroundColor:
                            _Brand.tangerine.withValues(alpha: 0.6),
                        disabledForegroundColor: _Brand.charcoal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: _Brand.charcoal,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Progress indicator, heading and description.
  Widget _intro({required bool onDark, required bool roomy}) {
    final Color main = onDark ? _Brand.cream : _Brand.charcoal;
    final Color soft = onDark ? _Brand.creamMuted : _Brand.muted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP 02 OF 03',
              style: TextStyle(
                color: main,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '66% completed',
              style: TextStyle(color: soft, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.66,
            minHeight: 6,
            backgroundColor: onDark ? _Brand.creamLine : _Brand.beige,
            valueColor: const AlwaysStoppedAnimation(_Brand.tangerine),
          ),
        ),
        SizedBox(height: onDark ? 36 : 30),
        Text(
          'Make your brand\nrecognisable.',
          style: TextStyle(
            fontSize: onDark ? 40 : (roomy ? 34 : 29),
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
            color: main,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Create a visual identity that represents your business.',
          style: TextStyle(
            fontSize: onDark ? 16 : 14.5,
            height: 1.6,
            color: soft,
          ),
        ),
      ],
    );
  }

  // ── SECTIONS & SMALL WIDGETS ───────────────────────────────────────────────
  Widget _section({
    required String title,
    required String subtitle,
    required Widget child,
    bool showDivider = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider) ...[
          const Divider(height: 1, thickness: 1, color: _Brand.line),
          const SizedBox(height: 24),
        ],
        _sectionTitle(title, subtitle),
        const SizedBox(height: 18),
        child,
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _sectionTitle(String title, String subtitle, {bool onDark = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: onDark ? _Brand.cream : _Brand.charcoal,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.5,
            color: onDark ? _Brand.creamMuted : _Brand.muted,
          ),
        ),
      ],
    );
  }

  Widget _optionalLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _Brand.charcoal,
          ),
          children: const [
            TextSpan(
              text: '   Optional',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _Brand.subtle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _optionalLabel(label),
        TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          style: const TextStyle(fontSize: 14.5, color: _Brand.charcoal),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _Brand.subtle, size: 20),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13.5, color: _Brand.subtle),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.65),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: border(_Brand.line),
            enabledBorder: border(const Color(0x40222222)),
            focusedBorder: border(_Brand.tangerine, 2),
          ),
        ),
      ],
    );
  }

  Widget _colorPicker({
    required String title,
    required Color selectedColor,
    required ValueChanged<Color> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _Brand.charcoal,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _brandColors.map((color) {
            final isSelected = color == selectedColor;

            return GestureDetector(
              onTap: () => onSelected(color),
              child: Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _Brand.charcoal : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLogoPicker() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _pickLogo,
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: _Brand.beige,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _Brand.line, width: 1.5),
            ),
            child: _logo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14.5),
                    child: Image.file(
                      _logo!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: _Brand.charcoal,
                        size: 32,
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Add Logo',
                        style: TextStyle(
                          color: _Brand.charcoal,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: _pickLogo,
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: Text(_logo == null ? 'Upload logo' : 'Change logo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _Brand.charcoal,
                  minimumSize: const Size(0, 44),
                  side: const BorderSide(color: _Brand.charcoal),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'PNG or JPG recommended',
                style: TextStyle(color: _Brand.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewSection({required bool onDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Brand Preview',
          'See how your business identity looks.',
          onDark: onDark,
        ),
        const SizedBox(height: 16),
        _buildBrandPreview(onDark: onDark),
      ],
    );
  }

  Widget _buildBrandPreview({required bool onDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: onDark ? _Brand.cream : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: onDark ? null : Border.all(color: _Brand.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR BRAND PREVIEW',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: _Brand.muted,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _logo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_logo!, fit: BoxFit.cover),
                      )
                    : Icon(
                        Icons.storefront_rounded,
                        color: _primaryColor,
                        size: 29,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _Brand.charcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _Brand.muted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [_primaryColor, _secondaryColor],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your business. Your identity. Your growth.',
            style: TextStyle(fontSize: 12, color: _Brand.muted),
          ),
        ],
      ),
    );
  }

  Widget _laterNote({required bool onDark}) {
    final Color color = onDark ? _Brand.creamMuted : _Brand.muted;

    return Row(
      children: [
        Icon(Icons.info_outline, color: color, size: 17),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'You can update your brand details later.',
            style: TextStyle(color: color, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
