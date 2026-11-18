
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _ProfileColors {
  static const cream = Color(0xFFFAF3E1);
  static const beige = Color(0xFFF5E7C6);
  static const orange = Color(0xFFFF6D1F);
  static const charcoal = Color(0xFF222222);
  static const muted = Color(0x99222222);
  static const line = Color(0x24222222);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _businessName = TextEditingController();
  final _ownerName = TextEditingController();
  final _phone = TextEditingController();
  final _category = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  final _instagram = TextEditingController();
  final _facebook = TextEditingController();
  final _website = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  String? _email;
  String? _logoUrl;
  XFile? _selectedLogo;
  Uint8List? _logoBytes;

  Color _primaryColor = _ProfileColors.orange;
  Color _secondaryColor = const Color(0xFF10B981);

  final List<Color> _brandColors = const [
    Color(0xFF2457E6),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFF97316),
    Color(0xFFEF4444),
    Color(0xFF0F172A),
    Color(0xFFEC4899),
    Color(0xFF0891B2),
    Color(0xFFFF6D1F),
    Color(0xFF222222),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _businessName.dispose();
    _ownerName.dispose();
    _phone.dispose();
    _category.dispose();
    _location.dispose();
    _description.dispose();
    _instagram.dispose();
    _facebook.dispose();
    _website.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Please log in to view your profile.');
      }

      _email = user.email;

      final data = await supabase
          .from('business_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (data == null) {
        throw Exception('Business profile not found.');
      }

      _businessName.text = data['business_name']?.toString() ?? '';
      _ownerName.text = data['owner_name']?.toString() ?? '';
      _phone.text = data['phone']?.toString() ?? '';
      _category.text = data['category']?.toString() ?? '';
      _location.text = data['location']?.toString() ?? '';
      _description.text = data['description']?.toString() ?? '';
      _instagram.text = data['instagram_url']?.toString() ?? '';
      _facebook.text = data['facebook_url']?.toString() ?? '';
      _website.text = data['website_url']?.toString() ?? '';
      _logoUrl = data['logo_url']?.toString();

      _primaryColor = _parseColor(
        data['primary_color'],
        _ProfileColors.orange,
      );
      _secondaryColor = _parseColor(
        data['secondary_color'],
        const Color(0xFF10B981),
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load profile: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _parseColor(dynamic value, Color fallback) {
    if (value == null) return fallback;

    try {
      String hex = value.toString().replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _pickLogo() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedLogo = image;
        _logoBytes = bytes;
      });
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to select image: $error');
    }
  }

  Future<String?> _uploadLogo(String userId) async {
    if (_selectedLogo == null || _logoBytes == null) {
      return _logoUrl;
    }

    final extension = _selectedLogo!.name.split('.').last.toLowerCase();

    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    final filePath = '$userId/logo.$extension';

    await Supabase.instance.client.storage
        .from('business-assets')
        .uploadBinary(
          filePath,
          _logoBytes!,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );

    return Supabase.instance.client.storage
        .from('business-assets')
        .getPublicUrl(filePath);
  }

  Future<void> _saveProfile() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showMessage('Please log in again to update your profile.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final logoUrl = await _uploadLogo(user.id);

      await supabase.from('business_profiles').upsert(
        {
          'user_id': user.id,
          'business_name': _businessName.text.trim(),
          'owner_name': _ownerName.text.trim(),
          'phone': _phone.text.trim(),
          'category': _category.text.trim(),
          'location': _location.text.trim(),
          'description': _description.text.trim(),
          'primary_color': _colorToHex(_primaryColor),
          'secondary_color': _colorToHex(_secondaryColor),
          'instagram_url': _nullableText(_instagram.text),
          'facebook_url': _nullableText(_facebook.text),
          'website_url': _nullableText(_website.text),
          'logo_url': logoUrl,
        },
        onConflict: 'user_id',
      );

      if (!mounted) return;

      setState(() {
        _logoUrl = logoUrl;
        _selectedLogo = null;
        _logoBytes = null;
      });

      _showMessage('Your business profile has been updated!');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to save profile: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _nullableText(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _ProfileColors.cream,
        title: const Text(
          'Log out?',
          style: TextStyle(
            color: _ProfileColors.charcoal,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text('Are you sure you want to log out of UdyamBoost?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _ProfileColors.charcoal),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _ProfileColors.orange,
              foregroundColor: _ProfileColors.charcoal,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      // Return to the app's initial screen after signing out.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to log out: $error');
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _ProfileColors.muted, size: 20),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.65),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      labelStyle: const TextStyle(color: _ProfileColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _ProfileColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: _ProfileColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _ProfileColors.orange,
          width: 1.8,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: _ProfileColors.charcoal,
        fontSize: 14,
      ),
      decoration: _inputDecoration(label, icon),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _ProfileColors.beige,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _ProfileColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _ProfileColors.orange,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: _ProfileColors.charcoal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _ProfileColors.charcoal,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _ProfileColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget _buildLogoPicker() {
    Widget image;

    if (_logoBytes != null) {
      image = Image.memory(_logoBytes!, fit: BoxFit.cover);
    } else if (_logoUrl != null && _logoUrl!.isNotEmpty) {
      image = Image.network(
        _logoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.storefront_rounded,
          size: 36,
          color: _ProfileColors.charcoal,
        ),
      );
    } else {
      image = const Icon(
        Icons.storefront_rounded,
        size: 36,
        color: _ProfileColors.charcoal,
      );
    }

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 92,
            height: 92,
            color: _ProfileColors.cream,
            child: image,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Business logo',
                style: TextStyle(
                  color: _ProfileColors.charcoal,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Choose a PNG or JPG image for your business.',
                style: TextStyle(
                  color: _ProfileColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickLogo,
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: const Text('Change logo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _ProfileColors.charcoal,
                  side: const BorderSide(color: _ProfileColors.charcoal),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker({
    required String title,
    required Color selected,
    required ValueChanged<Color> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ProfileColors.charcoal,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _brandColors.map((color) {
            final isSelected = color.toARGB32() == selected.toARGB32();

            return GestureDetector(
              onTap: () => onSelected(color),
              child: Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? _ProfileColors.charcoal
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 17)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _ProfileColors.charcoal,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: _ProfileColors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: _logoBytes != null
                ? Image.memory(_logoBytes!, fit: BoxFit.cover)
                : (_logoUrl != null && _logoUrl!.isNotEmpty)
                    ? Image.network(
                        _logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.storefront_rounded,
                          size: 34,
                          color: _ProfileColors.charcoal,
                        ),
                      )
                    : const Icon(
                        Icons.storefront_rounded,
                        size: 34,
                        color: _ProfileColors.charcoal,
                      ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR BUSINESS PROFILE',
                  style: TextStyle(
                    color: _ProfileColors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _businessName.text.isEmpty
                      ? 'Your business'
                      : _businessName.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ProfileColors.cream,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _category.text,
                  style: const TextStyle(
                    color: _ProfileColors.cream,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ProfileColors.line),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.mail_outline_rounded,
            color: _ProfileColors.charcoal,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registered email',
                  style: TextStyle(
                    color: _ProfileColors.muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email ?? 'Not available',
                  style: const TextStyle(
                    color: _ProfileColors.charcoal,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_user_outlined,
            color: _ProfileColors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(double width) {
    final fieldWidth = width >= 720 ? (width - 16) / 2 : width;

    Widget field(Widget child) => SizedBox(
          width: fieldWidth,
          child: child,
        );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(
            title: 'Business logo',
            subtitle: 'Your business identity at a glance.',
            icon: Icons.storefront_outlined,
            child: _buildLogoPicker(),
          ),
          const SizedBox(height: 18),
          _sectionCard(
            title: 'Business information',
            subtitle: 'Keep your business details up to date.',
            icon: Icons.business_outlined,
            child: Wrap(
              spacing: 16,
              runSpacing: 18,
              children: [
                field(_textField(
                  controller: _businessName,
                  label: 'Business name',
                  icon: Icons.storefront_outlined,
                )),
                field(_textField(
                  controller: _ownerName,
                  label: 'Owner name',
                  icon: Icons.person_outline,
                )),
                field(_textField(
                  controller: _phone,
                  label: 'Phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                )),
                field(_textField(
                  controller: _category,
                  label: 'Business category',
                  icon: Icons.category_outlined,
                )),
                field(_textField(
                  controller: _location,
                  label: 'Business location',
                  icon: Icons.location_on_outlined,
                )),
                SizedBox(
                  width: width,
                  child: _textField(
                    controller: _description,
                    label: 'Business description',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _sectionCard(
            title: 'Brand colours',
            subtitle: 'Choose the colours that represent your business.',
            icon: Icons.palette_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColorPicker(
                  title: 'Primary colour',
                  selected: _primaryColor,
                  onSelected: (color) =>
                      setState(() => _primaryColor = color),
                ),
                const SizedBox(height: 22),
                _buildColorPicker(
                  title: 'Secondary colour',
                  selected: _secondaryColor,
                  onSelected: (color) =>
                      setState(() => _secondaryColor = color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _sectionCard(
            title: 'Social media & website',
            subtitle: 'Help customers find you online.',
            icon: Icons.language_rounded,
            child: Wrap(
              spacing: 16,
              runSpacing: 18,
              children: [
                field(_textField(
                  controller: _instagram,
                  label: 'Instagram URL',
                  icon: Icons.camera_alt_outlined,
                  required: false,
                  keyboardType: TextInputType.url,
                )),
                field(_textField(
                  controller: _facebook,
                  label: 'Facebook URL',
                  icon: Icons.facebook,
                  required: false,
                  keyboardType: TextInputType.url,
                )),
                SizedBox(
                  width: width,
                  child: _textField(
                    controller: _website,
                    label: 'Website URL',
                    icon: Icons.language,
                    required: false,
                    keyboardType: TextInputType.url,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildAccountCard(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: _ProfileColors.charcoal,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _isSaving ? 'Saving changes...' : 'Save profile changes',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _ProfileColors.orange,
                foregroundColor: _ProfileColors.charcoal,
                disabledBackgroundColor:
                    _ProfileColors.orange.withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB83A0A),
                side: const BorderSide(color: Color(0xFFB83A0A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProfileColors.cream,
      appBar: AppBar(
        backgroundColor: _ProfileColors.cream,
        foregroundColor: _ProfileColors.charcoal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: _ProfileColors.orange,
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding =
                    constraints.maxWidth >= 1000 ? 40.0 : 20.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    40,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1050),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 24),
                          const Text(
                            'Manage your business details',
                            style: TextStyle(
                              color: _ProfileColors.charcoal,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Update your information and keep your brand identity current.',
                            style: TextStyle(
                              color: _ProfileColors.muted,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFormContent(
                            constraints.maxWidth - horizontalPadding * 2 > 1050
                                ? 1050
                                : constraints.maxWidth -
                                    horizontalPadding * 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
