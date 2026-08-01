import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_chrome.dart';

/// Demo credentials for the local test login flow.
abstract final class DemoAuth {
  static const email = 'demo@calebsons.com';
  static const password = 'calebsons123';
}

/// First-run auth screen. Shows test credentials so local demos can sign in.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: DemoAuth.email);
  late final _password = TextEditingController(text: DemoAuth.password);
  bool _obscure = true;
  bool _submitting = false;
  String? _error;
  Timer? _submitTimer;

  @override
  void dispose() {
    _submitTimer?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _submitting = true;
    });

    _submitTimer?.cancel();
    _submitTimer = Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;

      final email = _email.text.trim();
      final password = _password.text;

      if (email == DemoAuth.email && password == DemoAuth.password) {
        AppScope.of(context).signIn();
        return;
      }

      setState(() {
        _submitting = false;
        _error = 'Use the demo login and password shown below.';
      });
    });
  }

  void _fillDemo() {
    setState(() {
      _email.text = DemoAuth.email;
      _password.text = DemoAuth.password;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.medium;

    return AppBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 32 : 20,
                vertical: 28,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: FadeIn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Calebsons Flutter',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fraunces(
                          fontSize: wide ? 40 : 32,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Business Operations Suite',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: wide ? 16 : 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sign in to manage orders and inventory',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.muted,
                            ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                        decoration: BoxDecoration(
                          color: AppColors.chalk.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.line.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Login',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                decoration: _fieldDecoration(
                                  hint: 'you@company.com',
                                  icon: Icons.mail_outline_rounded,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter a login email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Password',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _password,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    _submit();
                                  }
                                },
                                decoration: _fieldDecoration(
                                  hint: '••••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    onPressed: () => setState(
                                      () => _obscure = !_obscure,
                                    ),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter a password';
                                  }
                                  return null;
                                },
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 14),
                                Text(
                                  _error!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.alert),
                                ),
                              ],
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: _submitting
                                    ? null
                                    : () {
                                        if (_formKey.currentState
                                                ?.validate() ??
                                            false) {
                                          _submit();
                                        }
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.teal,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      AppColors.teal.withValues(alpha: 0.45),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _submitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Sign in',
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DemoCredentialsCard(onUse: _fillDemo),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.muted, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.wash,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.line.withValues(alpha: 0.9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.line.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.4),
      ),
    );
  }
}

class _DemoCredentialsCard extends StatelessWidget {
  const _DemoCredentialsCard({required this.onUse});

  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F6F6A), Color(0xFF134E4A)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Test credentials',
                style: GoogleFonts.manrope(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onUse,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Fill form'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CredentialLine(
            label: 'Login',
            value: DemoAuth.email,
          ),
          const SizedBox(height: 8),
          _CredentialLine(
            label: 'Password',
            value: DemoAuth.password,
          ),
        ],
      ),
    );
  }
}

class _CredentialLine extends StatelessWidget {
  const _CredentialLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: GoogleFonts.manrope(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Copy $label',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: value));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label copied'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          icon: Icon(
            Icons.copy_rounded,
            size: 16,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
