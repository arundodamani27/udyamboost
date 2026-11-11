
import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../features/onboarding/brand_identity_screen.dart';
import '../features/authentication/signup_screen.dart';
import '../features/authentication/login_screen.dart';

class UdyamBoostApp extends StatelessWidget {
  const UdyamBoostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UdyamBoost',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color primary = Color(0xFF2457E6);
  static const Color dark = Color(0xFF14213D);
  static const Color green = Color(0xFF10B981);
  static const Color background = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BRAND HEADER
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UdyamBoost',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: dark,
                          letterSpacing: -0.6,
                        ),
                      ),
                      Text(
                        'GROW YOUR BUSINESS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 38),

              // BADGE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F8F1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: green,
                      size: 16,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'YOUR DIGITAL GROWTH PARTNER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF087A52),
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // MAIN HEADLINE
              const Text(
                'From Local Business\nTo Online Brand.',
                style: TextStyle(
                  fontSize: 34,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: dark,
                  letterSpacing: -1.1,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Everything you need to promote your business, '
                'create content and reach more customers — '
                'all in one place.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 30),

              // HERO ILLUSTRATION CARD
              Container(
                width: double.infinity,
                height: 205,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2457E6),
                      Color(0xFF4778F5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.20),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -25,
                      top: -45,
                      child: Container(
                        height: 170,
                        width: 170,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -35,
                      bottom: -75,
                      child: Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(23),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Think Bigger.\nGrow Faster.',
                                  style: TextStyle(
                                    fontSize: 23,
                                    height: 1.3,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Your business deserves\na digital presence.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: Colors.white.withValues(
                                      alpha: 0.85,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 112,
                            width: 105,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.trending_up_rounded,
                              color: Colors.white,
                              size: 75,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // FEATURES
              const Text(
                'Everything to grow online',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),

              const SizedBox(height: 17),

              _featureItem(
                icon: Icons.auto_awesome,
                iconColor: const Color(0xFF7C3AED),
                title: 'AI Marketing Assistant',
                subtitle: 'Create captions and promotional content.',
              ),

              const SizedBox(height: 14),

              _featureItem(
                icon: Icons.palette_outlined,
                iconColor: primary,
                title: 'Creative Poster Maker',
                subtitle: 'Design attractive business posters.',
              ),

              const SizedBox(height: 14),

              _featureItem(
                icon: Icons.inventory_2_outlined,
                iconColor: green,
                title: 'Digital Product Catalogue',
                subtitle: 'Showcase your products in one place.',
              ),

              const SizedBox(height: 30),

              // GET STARTED BUTTON
              SizedBox(
                width: double.infinity,
                height: 57,
                child: ElevatedButton(
                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const SignupScreen(),
    ),
  );
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 13),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ),
  );
},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: dark,
                    side: const BorderSide(
                      color: Color(0xFFDCE3ED),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'I already have an account',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Center(
                child: Text(
                  'MADE FOR LOCAL BUSINESSES  🇮🇳',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // REUSABLE FEATURE WIDGET
  Widget _featureItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEDF0F5)),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class BusinessOnboardingScreen extends StatefulWidget {
  const BusinessOnboardingScreen({super.key});

  @override
  State<BusinessOnboardingScreen> createState() =>
      _BusinessOnboardingScreenState();
}

class _BusinessOnboardingScreenState
    extends State<BusinessOnboardingScreen> {
  static const Color primary = Color(0xFF2457E6);
  static const Color dark = Color(0xFF14213D);
  static const Color muted = Color(0xFF64748B);

  final _formKey = GlobalKey<FormState>();

  final _businessName = TextEditingController();
  final _ownerName = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();

  String? _category;

  final List<String> _categories = [
    'Clothing & Fashion',
    'Food & Beverages',
    'Grocery & Retail',
    'Beauty & Wellness',
    'Electronics',
    'Handicrafts',
    'Home & Lifestyle',
    'Education',
    'Other',
  ];

  @override
  void dispose() {
    _businessName.dispose();
    _ownerName.dispose();
    _phone.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Business Profile',
          style: TextStyle(
            color: dark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PROGRESS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'STEP 01 OF 03',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '33% completed',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.33,
                          minHeight: 6,
                          backgroundColor: Color(0xFFE5EAF2),
                          valueColor:
                              AlwaysStoppedAnimation(primary),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'Let’s set up your\nbusiness profile.',
                        style: TextStyle(
                          fontSize: 29,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                          color: dark,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Tell us a little about your business. '
                        'We’ll use these details to personalize '
                        'your UdyamBoost experience.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: muted,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // BUSINESS IDENTITY
                      _sectionTitle(
                        'Business Identity',
                        'Basic information about your business',
                        Icons.storefront_outlined,
                      ),

                      const SizedBox(height: 19),

                      _fieldLabel('Business Name', required: true),

                      _textField(
                        controller: _businessName,
                        hint: 'e.g. Arun Fashion Store',
                        icon: Icons.store_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your business name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 19),

                      _fieldLabel('Owner Name', required: true),

                      _textField(
                        controller: _ownerName,
                        hint: 'Enter business owner name',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter owner name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // CATEGORY
                      _sectionTitle(
                        'Business Category',
                        'Choose the category that fits your business',
                        Icons.category_outlined,
                      ),

                      const SizedBox(height: 19),

                      _fieldLabel('Select Category', required: true),

                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        isExpanded: true,
                        decoration: _decoration(
                          'Choose business category',
                          Icons.grid_view_rounded,
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _category = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // CONTACT INFORMATION
                      _sectionTitle(
                        'Contact Information',
                        'Help customers find and contact you',
                        Icons.contact_phone_outlined,
                      ),

                      const SizedBox(height: 19),

                      _fieldLabel('Phone Number', required: true),

                      _textField(
                        controller: _phone,
                        hint: '10-digit mobile number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null ||
                              !RegExp(r'^[6-9]\d{9}$')
                                  .hasMatch(value.trim())) {
                            return 'Enter a valid 10-digit mobile number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 19),

                      _fieldLabel('Business Location', required: true),

                      _textField(
                        controller: _location,
                        hint: 'e.g. Mangaluru, Karnataka',
                        icon: Icons.location_on_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your location';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      // DESCRIPTION
                      _sectionTitle(
                        'About Your Business',
                        'Introduce your business to potential customers',
                        Icons.description_outlined,
                      ),

                      const SizedBox(height: 19),

                      _fieldLabel('Business Description'),

                      TextFormField(
                        controller: _description,
                        maxLines: 4,
                        maxLength: 250,
                        decoration: _decoration(
                          'Describe what your business offers...',
                          null,
                        ).copyWith(
                          alignLabelWithHint: true,
                          counterStyle: const TextStyle(
                            color: muted,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // PRIVACY NOTE
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: primary,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your business information helps us '
                                'personalize your marketing experience.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: Color(0xFF35558B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // BOTTOM CONTINUE BUTTON
            Container(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFEDF0F5)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 9),
                      Icon(Icons.arrow_forward_rounded, size: 19),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: dark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: dark,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _decoration(hint, icon),
    );
  }

  InputDecoration _decoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFF9AA5B5),
      ),
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: muted, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 17,
      ),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrandIdentityScreen(
          businessName: _businessName.text.trim(),
          ownerName: _ownerName.text.trim(),
          phone: _phone.text.trim(),
          category: _category!,
          location: _location.text.trim(),
          description: _description.text.trim(),
        ),
      ),
    );
  }
}
