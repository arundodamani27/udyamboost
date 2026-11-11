
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFFF7F9FC),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14213D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to continue growing your business.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
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
                const SizedBox(height: 18),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _hidePassword = !_hidePassword);
                      },
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty
                          ? 'Enter your password'
                          : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2457E6),
                      foregroundColor: Colors.white,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
