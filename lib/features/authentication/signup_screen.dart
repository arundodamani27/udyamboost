
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../onboarding/../../app/app.dart';
import 'login_screen.dart';

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

  static const primary = Color(0xFF2457E6);
  static const dark = Color(0xFF14213D);

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
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        title: const Text(
          'Create Account',
          style: TextStyle(color: dark, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: dark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                const Text(
                  'Start your growth journey.',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create an account to manage and grow your business with UdyamBoost.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                _label('Full name'),
                TextFormField(
                  controller: _nameController,
                  decoration: _decoration(
                    'Enter your name',
                    Icons.person_outline,
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Please enter your name'
                          : null,
                ),
                const SizedBox(height: 20),

                _label('Email address'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
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
                  decoration: _decoration(
                    'Create a password',
                    Icons.lock_outline,
                  ).copyWith(
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
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Password must have at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 25),

                Center(
                  child: Wrap(
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Color(0xFF64748B)),
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
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w700,
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
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          color: dark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
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
    );
  }
}
