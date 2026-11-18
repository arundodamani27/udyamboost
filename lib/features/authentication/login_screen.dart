
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/app.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;

  // UdyamBoost theme colors
  static const Color cream = Color(0xFFFAF3E1);
  static const Color beige = Color(0xFFF5E7C6);
  static const Color orange = Color(0xFFFF6D1F);
  static const Color charcoal = Color(0xFF222222);
  static const Color muted = Color(0xFF77716A);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final supabase = Supabase.instance.client;

      // Authenticate the user
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = response.user;

      if (user == null) {
        throw Exception('Unable to retrieve user account.');
      }

      // Check whether the user has a business profile
      final profile = await supabase
          .from('business_profiles')
          .select('business_name, category')
          .eq('user_id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (profile != null) {
        // Existing business: Open Dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              businessName: profile['business_name'],
              category: profile['category'],
            ),
          ),
          (route) => false,
        );
      } else {
        // New business: Start onboarding
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const BusinessOnboardingScreen(),
          ),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: orange),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      labelStyle: const TextStyle(color: muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: beige),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: beige),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: orange, width: 1.7),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: charcoal),
        title: const Text(
          'UdyamBoost',
          style: TextStyle(
            color: charcoal,
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 750;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1050),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: _buildWelcomePanel()),
                            const SizedBox(width: 55),
                            Expanded(child: _buildLoginForm()),
                          ],
                        )
                      : _buildLoginForm(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomePanel() {
    return Container(
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: beige,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Welcome back!',
            style: TextStyle(
              fontSize: 34,
              height: 1.2,
              fontWeight: FontWeight.w900,
              color: charcoal,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Your business journey continues here.',
            style: TextStyle(
              fontSize: 17,
              height: 1.5,
              color: muted,
            ),
          ),
          const SizedBox(height: 32),
          const _WelcomeFeature(
            icon: Icons.auto_awesome_rounded,
            title: 'Create with AI',
            subtitle: 'Generate marketing content for your brand.',
          ),
          const SizedBox(height: 22),
          const _WelcomeFeature(
            icon: Icons.trending_up_rounded,
            title: 'Grow your business',
            subtitle: 'Manage your products and online presence.',
          ),
          const SizedBox(height: 22),
          const _WelcomeFeature(
            icon: Icons.language_rounded,
            title: 'Reach more customers',
            subtitle: 'Connect with customers in their language.',
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: beige),
        boxShadow: [
          BoxShadow(
            color: charcoal.withValues(alpha: 0.05),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: beige,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'YOUR BUSINESS, YOUR GROWTH',
                style: TextStyle(
                  color: charcoal,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Login to your account',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: charcoal,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Enter your details to continue growing your business.',
              style: TextStyle(
                color: muted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'Email address',
              style: TextStyle(
                color: charcoal,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 9),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                label: 'Enter your email',
                icon: Icons.email_outlined,
              ),
              validator: (value) {
                if (value == null ||
                    !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(value.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),

            const Text(
              'Password',
              style: TextStyle(
                color: charcoal,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 9),
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              decoration: _inputDecoration(
                label: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _hidePassword = !_hidePassword);
                  },
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: muted,
                  ),
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty
                      ? 'Enter your password'
                      : null,
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: orange.withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 23,
                        width: 23,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 9),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'From Local Business to Online Brand.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _WelcomeFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: const Color(0xFFFF6D1F)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF222222),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF77716A),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
