import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../onboarding/../../app/app.dart';
import 'login_screen.dart';

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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
        },
      );

      if (!mounted) return;

      if (response.session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const BusinessOnboardingScreen(),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created. Please verify your email before logging in.',
            ),
          ),
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: _Brand.charcoal,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: _Brand.charcoal),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: _Brand.line),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < _splitBreakpoint) {
              return _formPane(showIntro: true, horizontal: 24);
            }

            return Row(
              children: [
                Expanded(flex: 5, child: _sidePanel()),
                Expanded(
                  flex: 7,
                  child: _formPane(showIntro: false, horizontal: 40),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── LAYOUT PIECES ──────────────────────────────────────────────────────────

  // Brand panel shown beside the form on laptops and desktops.
  Widget _sidePanel() {
    const features = [
      'AI Marketing Assistant',
      'Creative Poster Maker',
      'Digital Product Catalogue',
    ];

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
                _logo(),
                const SizedBox(height: 64),
                _heading(onDark: true),
                const SizedBox(height: 40),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: _Brand.creamLine,
                ),
                const SizedBox(height: 24),
                const Text(
                  'INCLUDED WITH UDYAMBOOST',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: _Brand.creamMuted,
                  ),
                ),
                const SizedBox(height: 16),
                for (final feature in features)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          height: 7,
                          width: 7,
                          decoration: const BoxDecoration(
                            color: _Brand.tangerine,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _Brand.cream,
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
    );
  }

  Widget _logo() {
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

  // Headline and description (original copy).
  Widget _heading({required bool onDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start your growth journey.',
          style: TextStyle(
            fontSize: onDark ? 40 : 30,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
            color: onDark ? _Brand.cream : _Brand.charcoal,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Create an account to manage and grow your business with '
          'UdyamBoost.',
          style: TextStyle(
            fontSize: onDark ? 16 : 14.5,
            height: 1.6,
            color: onDark ? _Brand.creamMuted : _Brand.muted,
          ),
        ),
      ],
    );
  }

  Widget _formPane({required bool showIntro, required double horizontal}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontal,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: _formContent(showIntro: showIntro),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _formContent({required bool showIntro}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showIntro) ...[
          _heading(onDark: false),
          const SizedBox(height: 32),
        ],

        _label('Full name'),
        TextFormField(
          controller: _nameController,
          style: const TextStyle(fontSize: 14.5, color: _Brand.charcoal),
          decoration: _decoration(
            'Enter your name',
            Icons.person_outline,
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Please enter your name'
              : null,
        ),
        const SizedBox(height: 20),

        _label('Email address'),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14.5, color: _Brand.charcoal),
          decoration: _decoration(
            'Enter your email',
            Icons.email_outlined,
          ),
          validator: (value) {
            if (value == null ||
                !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                    .hasMatch(value.trim())) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        _label('Password'),
        TextFormField(
          controller: _passwordController,
          obscureText: _hidePassword,
          style: const TextStyle(fontSize: 14.5, color: _Brand.charcoal),
          decoration: _decoration(
            'Create a password',
            Icons.lock_outline,
          ).copyWith(
            helperText: 'At least 8 characters',
            helperStyle: const TextStyle(
              fontSize: 12,
              color: _Brand.muted,
            ),
            suffixIcon: IconButton(
              tooltip: _hidePassword ? 'Show password' : 'Hide password',
              onPressed: () {
                setState(() => _hidePassword = !_hidePassword);
              },
              icon: Icon(
                _hidePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _Brand.subtle,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.length < 8) {
              return 'Password must have at least 8 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _signup,
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
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _Brand.charcoal,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
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
        const SizedBox(height: 20),

        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(color: _Brand.muted, fontSize: 14),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: _Brand.charcoal,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: _Brand.tangerine,
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _Brand.charcoal,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13.5, color: _Brand.subtle),
      prefixIcon: Icon(icon, color: _Brand.subtle, size: 20),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.65),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      errorStyle: const TextStyle(color: _Brand.error, fontSize: 12),
      border: border(_Brand.line),
      enabledBorder: border(const Color(0x40222222)),
      focusedBorder: border(_Brand.tangerine, 2),
      errorBorder: border(_Brand.error),
      focusedErrorBorder: border(_Brand.error, 2),
    );
  }
}