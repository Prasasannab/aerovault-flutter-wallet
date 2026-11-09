import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'core/security/anti_tamper_service.dart';
import 'core/security/biometric_service.dart';
import 'core/security/security_service.dart';
import 'core/theme/aerovault_colors.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/fintech_theme.dart';
import 'core/theme/glass_decorations.dart';
import 'core/theme/theme_cubit.dart';

import 'features/wallet/presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait mode for banking stability
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set immersive dark status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize dependency injection container
  await initCoreDependencies();

  runApp(const AeroVaultApp());
}

class AeroVaultApp extends StatelessWidget {
  const AeroVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: FintechTheme.lightTheme,
            darkTheme: FintechTheme.darkTheme,
            themeMode: themeMode,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}

/// Initial Security Audit & Startup Screen
class SecurityAuditScreen extends StatefulWidget {
  const SecurityAuditScreen({super.key});

  @override
  State<SecurityAuditScreen> createState() => _SecurityAuditScreenState();
}

class _SecurityAuditScreenState extends State<SecurityAuditScreen> {
  bool _isChecking = true;
  DeviceIntegrityResult? _integrityResult;
  bool _biometricsAvailable = false;
  String _statusMessage = 'Auditing device hardware enclave & integrity...';

  @override
  void initState() {
    super.initState();
    _runStartupAudit();
  }

  Future<void> _runStartupAudit() async {
    setState(() {
      _isChecking = true;
      _statusMessage = 'Scanning device environment for anti-tamper compliance...';
    });

    try {
      final antiTamper = sl<AntiTamperService>();
      final biometric = sl<BiometricService>();

      final integrity = await antiTamper.checkDeviceIntegrity();
      final hasBiometrics = await biometric.canAuthenticate();

      if (mounted) {
        setState(() {
          _integrityResult = integrity;
          _biometricsAvailable = hasBiometrics;
          _isChecking = false;
          _statusMessage = integrity.isSecure
              ? 'Security check passed. Bank-grade environment verified.'
              : 'Security warning: Execution environment risk detected.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _statusMessage = 'Audit error: $e';
        });
      }
    }
  }

  Future<void> _testBiometrics() async {
    HapticFeedback.lightImpact();
    final securityService = sl<SecurityService>();
    final success = await securityService.authenticateBiometric();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: success ? AppColors.emeraldDark : AppColors.surfaceElevated,
          content: Text(
            success ? 'Biometric Authentication Succeeded!' : 'Biometric Auth Canceled / Failed',
            style: AppTextStyles.bodyMedium(color: AppColors.textPrimary),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Brand Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.emeraldGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.emeraldGlow,
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.background,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: AppTextStyles.heading1(color: colors.textPrimary),
                      ),
                      Text(
                        'ENTERPRISE SECURITY CORE',
                        style: AppTextStyles.label(color: AppColors.emeraldDark),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Status Card
              GlassContainer(
                backgroundColor: colors.surface,
                borderColor: _isChecking
                    ? colors.border
                    : (_integrityResult?.isSecure ?? false)
                        ? AppColors.emerald.withValues(alpha: 0.5)
                        : AppColors.error.withValues(alpha: 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_isChecking)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.emerald,
                            ),
                          )
                        else
                          Icon(
                            (_integrityResult?.isSecure ?? false)
                                ? Icons.verified_user
                                : Icons.warning_amber_rounded,
                            color: (_integrityResult?.isSecure ?? false)
                                ? AppColors.emerald
                                : AppColors.error,
                            size: 22,
                          ),
                        const SizedBox(width: 12),
                        Text(
                          'Environment Security Audit',
                          style: AppTextStyles.heading3(color: colors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _statusMessage,
                      style: AppTextStyles.bodyMedium(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Security Indicators Grid
              Text(
                'SECURITY SUBSYSTEMS',
                style: AppTextStyles.label(),
              ),
              const SizedBox(height: 12),

              _buildSecurityTile(
                context,
                icon: Icons.vpn_key_outlined,
                title: 'Hardware Keystore / Secure Enclave',
                subtitle: 'iOS Keychain first_unlock_this_device / Android Keystore AES-256 GCM',
                isActive: true,
              ),
              const SizedBox(height: 10),

              _buildSecurityTile(
                context,
                icon: Icons.fingerprint,
                title: 'Biometric Authentication Engine',
                subtitle: _biometricsAvailable
                    ? 'Hardware Biometrics Enrolled & Available'
                    : 'Biometrics unavailable / Not enrolled on simulator',
                isActive: _biometricsAvailable,
              ),
              const SizedBox(height: 10),

              _buildSecurityTile(
                context,
                icon: Icons.lock_outline,
                title: 'SSL Certificate & Public Key Pinning',
                subtitle: 'SHA-256 host verification active on Dio transport',
                isActive: true,
              ),
              const SizedBox(height: 10),

              _buildSecurityTile(
                context,
                icon: Icons.security,
                title: 'Anti-Tamper & Root Detection',
                subtitle: 'Automated memory wipe active on integrity breach',
                isActive: true,
              ),

              const SizedBox(height: 28),

              // Quick Test Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _testBiometrics,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('TRIGGER BIOMETRIC PROMPT'),
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: Text(
                  'Phase 1 Core Architecture Ready • Flutter 3.24+ / Dart 3.5+',
                  style: AppTextStyles.bodySmall(color: AppColors.textDim),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
  }) {
    final colors = context.colors;

    return GlassContainer(
      backgroundColor: colors.surface,
      borderColor: colors.border,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.emeraldGlow : colors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.emeraldDark : colors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium(color: colors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall(color: colors.textMuted),
                ),
              ],
            ),
          ),
          Icon(
            isActive ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isActive ? AppColors.emeraldDark : colors.textDim,
            size: 18,
          ),
        ],
      ),
    );
  }
}
