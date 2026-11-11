
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  static const Color primary = Color(0xFF2457E6);
  static const Color dark = Color(0xFF14213D);
  static const Color muted = Color(0xFF64748B);
  static const Color background = Color(0xFFF7F9FC);

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

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: dark,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: muted,
          ),
        ),
      ],
    );
  }

  Widget _socialField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: muted, size: 20),
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
        ),
      ),
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: dark,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 13,
          runSpacing: 12,
          children: _brandColors.map((color) {
            final isSelected = color == selectedColor;

            return GestureDetector(
              onTap: () => onSelected(color),
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: dark, width: 2.5)
                      : null,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 19,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLogoPicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickLogo,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFFD5E2FF),
                  width: 1.5,
                ),
              ),
              child: _logo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(23),
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
                          color: primary,
                          size: 35,
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Add Logo',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _pickLogo,
            icon: const Icon(Icons.upload_outlined, size: 18),
            label: Text(_logo == null ? 'Upload logo' : 'Change logo'),
          ),
          const Text(
            'PNG or JPG recommended',
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandPreview() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR BRAND PREVIEW',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: muted,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: _primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _logo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(_logo!, fit: BoxFit.cover),
                      )
                    : Icon(
                        Icons.storefront_rounded,
                        color: _primaryColor,
                        size: 29,
                      ),
              ),
              const SizedBox(width: 13),
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
                        fontWeight: FontWeight.w700,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.category,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
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
            style: TextStyle(
              fontSize: 12,
              color: muted,
            ),
          ),
        ],
      ),
    );
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
        content: Text('Please log in before saving your business profile.'),
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
        backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Brand Identity',
          style: TextStyle(
            color: dark,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'STEP 02 OF 03',
                      style: TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '66% completed',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.66,
                    minHeight: 6,
                    backgroundColor: Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation(primary),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Make your brand\nrecognisable.',
                    style: TextStyle(
                      color: dark,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a visual identity that represents your business.',
                    style: TextStyle(
                      color: muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),

                  _sectionTitle(
                    'Business Logo',
                    'Add your existing business logo.',
                  ),
                  const SizedBox(height: 17),
                  _buildLogoPicker(),

                  const SizedBox(height: 28),
                  _sectionTitle(
                    'Brand Colours',
                    'Choose colours that represent your brand.',
                  ),
                  const SizedBox(height: 17),
                  _colorPicker(
                    title: 'Primary colour',
                    selectedColor: _primaryColor,
                    onSelected: (color) {
                      setState(() => _primaryColor = color);
                    },
                  ),
                  const SizedBox(height: 22),
                  _colorPicker(
                    title: 'Secondary colour',
                    selectedColor: _secondaryColor,
                    onSelected: (color) {
                      setState(() => _secondaryColor = color);
                    },
                  ),

                  const SizedBox(height: 28),
                  _sectionTitle(
                    'Social Media & Website',
                    'Help customers discover your business online.',
                  ),
                  _socialField(
                    icon: Icons.camera_alt_outlined,
                    label: 'Instagram',
                    hint: 'https://instagram.com/yourbusiness',
                    controller: _instagramController,
                  ),
                  _socialField(
                    icon: Icons.facebook,
                    label: 'Facebook',
                    hint: 'https://facebook.com/yourbusiness',
                    controller: _facebookController,
                  ),
                  _socialField(
                    icon: Icons.language,
                    label: 'Website',
                    hint: 'https://yourbusiness.com',
                    controller: _websiteController,
                  ),

                  const SizedBox(height: 28),
                  _sectionTitle(
                    'Brand Preview',
                    'See how your business identity looks.',
                  ),
                  const SizedBox(height: 14),
                  _buildBrandPreview(),

                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: muted,
                        size: 17,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can update your brand details later.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(22, 13, 22, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _continue,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
    ? const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
    : const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Continue',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          SizedBox(width: 9),
          Icon(Icons.arrow_forward_rounded, size: 19),
        ],
      ),
            ),
          ),
        ),
      ),
    );
  }
}
