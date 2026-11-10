import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/security/security_service.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';

/// Bank-Grade Emergency Security Lockout Screen
/// Displayed when maximum PIN attempts (3) are exceeded or device anti-tamper is triggered.
class SecurityLockoutScreen extends StatefulWidget {
  final String reason;

  const SecurityLockoutScreen({
    super.key,
    this.reason = 'Maximum PIN attempts exceeded. Ephemeral session and cryptographic tokens wiped.',
  });

  @override
  State<SecurityLockoutScreen> createState() => _SecurityLockoutScreenState();
}

class _SecurityLockoutScreenState extends State<SecurityLockoutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Urgent pulsing red glow adhering to 12-principles-of-animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _resetLockoutForDemo() async {
    HapticFeedback.heavyImpact();
    final security = sl<SecurityService>();
    // Re-initialize default keystore for demo evaluation
    await security.keystoreService.savePin('123456');
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const alertRed = Color(0xFFEF4444);

    return PopScope(
      canPop: false, // Prevent physical back gesture during security lockout
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 10),

                        // Center Alert Visuals
                        Column(
                          children: [
                            // Pulsing Red Shield
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: alertRed.withValues(alpha: 0.12),
                                    border: Border.all(
                                      color: alertRed,
                                      width: 2.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: alertRed.withValues(alpha: 0.35 * _pulseAnimation.value),
                                        blurRadius: 28 * _pulseAnimation.value,
                                        spreadRadius: 4 * _pulseAnimation.value,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.gpp_bad_rounded,
                                    color: alertRed,
                                    size: 46,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            Text(
                              'Vault Access Suspended',
                              style: AppTextStyles.heading1(color: colors.textPrimary).copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'Security Lockout Activated',
                              style: AppTextStyles.label(
                                color: alertRed,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              'All local cryptographic session keys and authentication tokens were wiped from Apple Secure Enclave & Android Keystore to protect client wealth.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium(color: colors.textSecondary).copyWith(
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Technical Security Audit Box
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: alertRed.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildAuditRow(
                                    context,
                                    label: 'Hardware Keystore',
                                    value: 'PURGED & CLEARED',
                                    valueColor: alertRed,
                                  ),
                                  Divider(
                                    height: 18,
                                    thickness: 0.6,
                                    color: colors.cardBorder.withValues(alpha: 0.5),
                                  ),
                                  _buildAuditRow(
                                    context,
                                    label: 'Session Encryption Key',
                                    value: 'REVOKED (0x00)',
                                    valueColor: alertRed,
                                  ),
                                  Divider(
                                    height: 18,
                                    thickness: 0.6,
                                    color: colors.cardBorder.withValues(alpha: 0.5),
                                  ),
                                  _buildAuditRow(
                                    context,
                                    label: 'Anti-Tamper Monitor',
                                    value: 'ACTIVE • 0 BRUTE FORCE',
                                    valueColor: colors.primary,
                                  ),
                                  Divider(
                                    height: 18,
                                    thickness: 0.6,
                                    color: colors.cardBorder.withValues(alpha: 0.5),
                                  ),
                                  _buildAuditRow(
                                    context,
                                    label: 'FDIC / FINMA Segregation',
                                    value: 'SAFE • CUSTODY INTACT',
                                    valueColor: colors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Bottom Recovery CTAs
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            // Demo Reset CTA
                            BounceButton(
                              onTap: _resetLockoutForDemo,
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colors.primary,
                                      colors.primary.withValues(alpha: 0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.primaryGlow,
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Restore Access (Reset Demo Lockout)',
                                  style: AppTextStyles.label(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Contact Support
                            BounceButton(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: colors.surfaceElevated,
                                    content: const Text(
                                      'AeroVault Wealth Concierge notified. Institutional support dispatched.',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colors.cardBorder),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.headset_mic_rounded,
                                      color: colors.textSecondary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Contact Sovereign Wealth Concierge',
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
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

  Widget _buildAuditRow(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
  }) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.monospace(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
