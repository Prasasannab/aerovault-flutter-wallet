import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/security/security_service.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/pin_dots_indicator.dart';
import '../widgets/scrambled_keypad.dart';
import 'security_lockout_screen.dart';

/// Bank-Grade Scrambled PIN Entry Screen
/// Implements Swiss & Private Banking anti-tamper security standards
class ScrambledPinScreen extends StatelessWidget {
  final String title;
  final String reason;

  const ScrambledPinScreen({
    super.key,
    this.title = 'Security Authentication',
    this.reason = 'Enter your 6-digit cryptographic PIN to verify identity',
  });

  static Future<bool?> push(BuildContext context, {String? title, String? reason}) {
    HapticFeedback.lightImpact();
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
          child: ScrambledPinScreen(
            title: title ?? 'Security Authentication',
            reason: reason ?? 'Enter your 6-digit cryptographic PIN to verify identity',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ScrambledPinView(title: title, reason: reason);
  }
}

class _ScrambledPinView extends StatefulWidget {
  final String title;
  final String reason;

  const _ScrambledPinView({
    required this.title,
    required this.reason,
  });

  @override
  State<_ScrambledPinView> createState() => _ScrambledPinViewState();
}

class _ScrambledPinViewState extends State<_ScrambledPinView> {
  String _pin = '';
  late List<int> _scrambledDigits;
  bool _isScrambled = true;
  bool _hasError = false;
  int _remainingAttempts = 3;

  @override
  void initState() {
    super.initState();
    _shuffleDigits();
    _remainingAttempts = sl<SecurityService>().remainingPinAttempts;
  }

  void _shuffleDigits() {
    final list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    if (_isScrambled) {
      list.shuffle(Random());
    }
    setState(() => _scrambledDigits = list);
  }

  void _toggleScramble() {
    setState(() {
      _isScrambled = !_isScrambled;
      _shuffleDigits();
    });
  }

  void _onDigitTap(int digit) {
    if (_pin.length >= 6) return;

    setState(() {
      _hasError = false;
      _pin += digit.toString();
    });

    if (_pin.length == 6) {
      // Trigger Verification via AuthBloc
      context.read<AuthBloc>().add(VerifyPinEvent(_pin));
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _hasError = false;
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _onBiometricTap() {
    context.read<AuthBloc>().add(
          const BiometricAuthEvent(
            localizedReason: 'Authenticate with Face ID to unlock AeroVault',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colors.surfaceElevated,
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: colors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Identity verified via ${state.method}',
                    style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is AuthPinError) {
          HapticFeedback.vibrate();
          setState(() {
            _hasError = true;
            _pin = '';
            _remainingAttempts = state.remainingAttempts;
            _shuffleDigits(); // Re-shuffle on failed attempt for anti-shoulder surfing
          });
        } else if (state is AuthLockedOut) {
          HapticFeedback.heavyImpact();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SecurityLockoutScreen(reason: state.reason),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: colors.textSecondary),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isScrambled ? Icons.shuffle_on_rounded : Icons.shuffle_rounded,
                color: _isScrambled ? colors.primary : colors.textSecondary,
              ),
              tooltip: 'Toggle Scrambled Pad',
              onPressed: _toggleScramble,
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Header & Info
                        Column(
                          children: [
                            const SizedBox(height: 8),

                            // Diamond Lock Emblem
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.primary.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: colors.primary,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primaryGlow,
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.lock_rounded,
                                color: colors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              widget.title,
                              style: AppTextStyles.heading1(color: colors.textPrimary).copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                widget.reason,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 6-Digit PIN Indicator Dots
                            PinDotsIndicator(
                              pinLength: _pin.length,
                              maxDigits: 6,
                              hasError: _hasError,
                            ),
                            const SizedBox(height: 14),

                            // Attempts Countdown Badge
                            _buildAttemptsBadge(context),
                          ],
                        ),

                        // Bottom Scrambled Keypad
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24, top: 12),
                          child: ScrambledKeypad(
                            digits: _scrambledDigits,
                            isScrambled: _isScrambled,
                            onDigitTap: _onDigitTap,
                            onBackspace: _onBackspace,
                            onBiometricTap: _onBiometricTap,
                            onShuffleTap: _shuffleDigits,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAttemptsBadge(BuildContext context) {
    final colors = context.colors;
    Color badgeColor = colors.primary;
    String text = '$_remainingAttempts attempts remaining';

    if (_remainingAttempts == 2) {
      badgeColor = const Color(0xFFFFB020);
      text = '⚠️ 2 attempts remaining';
    } else if (_remainingAttempts <= 1) {
      badgeColor = const Color(0xFFEF4444);
      text = '🚨 FINAL ATTEMPT: Session will wipe on failure';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
