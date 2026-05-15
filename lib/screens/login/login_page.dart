import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),

              // ── Title ───────────────────────────────────────────
              Text(
                'Login',
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 140),

              // ── Input Fields ────────────────────────────────────
              _LeafInputField(hint: 'Email'),
              const SizedBox(height: 20),
              _LeafInputField(hint: 'Password', obscure: true),

              const SizedBox(height: 40),

              // ── Or continue with Email divider ─────────────────
              _OrDivider(),

              const SizedBox(height: 30),

              // ── Google Sign In ──────────────────────────────────
              _GoogleSignInButton(),

              const SizedBox(height: 24),

              // ── Login Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGreenBg,
                    foregroundColor: AppColors.deepGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    textStyle: AppTypography.displaySmall.copyWith(
                      color: AppColors.deepGreen,
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Login'),
                ),
              ),

              const SizedBox(height: 30),

              // ── Footer ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTypography.footerLight.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Sign up',
                      style: AppTypography.footerBold.copyWith(
                        color: AppColors.lightGreenBg,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Leaf Input Field Widget ──────────────────────────────────
class _LeafInputField extends StatelessWidget {
  final String hint;
  final bool obscure;

  const _LeafInputField({required this.hint, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        obscureText: obscure,
        style: AppTypography.bodyLarge.copyWith(color: AppColors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyLarge.copyWith(
            color: AppColors.white.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}

// ── Or Continue with Email Divider ───────────────────────────
class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.white.withValues(alpha: 0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or continue with Email',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.white.withValues(alpha: 0.3))),
      ],
    );
  }
}

// ── Google Sign-In Button ────────────────────────────────────
class _GoogleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        label: Text(
          'Sign in with Google',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.white),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.white.withValues(alpha: 0.4), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
      ),
    );
  }
}
