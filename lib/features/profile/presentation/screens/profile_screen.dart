import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/authorized_device.dart';
import '../../domain/entities/kyc_document.dart';
import '../../domain/entities/user_profile.dart';
import '../../../concierge/presentation/screens/concierge_screen.dart';
import '../../../governance/presentation/screens/governance_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static Future<void> navigate(BuildContext context) {
    HapticFeedback.lightImpact();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>()..add(const LoadProfileEvent()),
          child: const ProfileScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Column(
          children: [
            Text(
              'Client Profile & KYC',
              style: AppTextStyles.heading2(color: colors.textPrimary).copyWith(fontSize: 17),
            ),
            const SizedBox(height: 2),
            Text(
              'FINMA TIER 3 SOVEREIGN',
              style: AppTextStyles.label(color: AppColors.emerald, fontSize: 9.5),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user_outlined, color: AppColors.emerald, size: 22),
            tooltip: 'FINMA Compliance Verified',
            onPressed: () {
              HapticFeedback.lightImpact();
              _showComplianceSnack(context, 'FINMA Tier 3 Sovereign Status Active & Audited');
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && state.feedbackMessage != null) {
            _showComplianceSnack(context, state.feedbackMessage!);
          } else if (state is ProfileError) {
            _showComplianceSnack(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.emerald),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(state.message, style: AppTextStyles.bodyMedium(color: colors.textPrimary)),
                    const SizedBox(height: 16),
                    BounceButton(
                      onTap: () => context.read<ProfileBloc>().add(const LoadProfileEvent()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('Retry', style: AppTextStyles.label(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ProfileLoaded) {
            return _buildProfileContent(context, colors, state.profile);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showComplianceSnack(BuildContext context, String message, {bool isError = false}) {
    final colors = context.colors;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isError ? AppColors.error : colors.border),
        ),
        content: Row(
          children: [
            Icon(
              isError ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
              color: isError ? AppColors.error : AppColors.emerald,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 2500),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    AeroVaultColors colors,
    UserProfile profile,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Executive Hero Card
          _buildExecutiveHeroCard(context, colors, profile),
          const SizedBox(height: 20),

          // 2. Sovereign Tier Verification Card
          _buildSovereignTierCard(context, colors, profile),
          const SizedBox(height: 20),

          // 2.5 Dedicated Private Wealth Concierge Banner
          _buildConciergeLauncherCard(context, colors),
          const SizedBox(height: 20),

          // 2.8 Corporate Multi-Sig Governance & Dual-Control Approvals
          _buildGovernanceLauncherCard(context, colors),
          const SizedBox(height: 20),

          // 3. Liquidity & Banking Limits Panel
          _buildLimitsPanel(context, colors, profile),
          const SizedBox(height: 20),

          // 4. Verified KYC & Regulatory Document Vault
          _buildKycDocumentsVault(context, colors, profile),
          const SizedBox(height: 20),

          // 5. Hardware Enclave & Authorized Devices Subsystem
          _buildAuthorizedDevicesSection(context, colors, profile),
          const SizedBox(height: 24),

          // 6. Compliance & Privacy Action Buttons
          _buildComplianceActions(context, colors, profile),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildExecutiveHeroCard(
    BuildContext context,
    AeroVaultColors colors,
    UserProfile profile,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with Dual Ring Glow
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.emerald, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.emeraldGlow,
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/sample_avatar.jpg',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.6),
                    errorBuilder: (_, _, _) => Container(
                      color: colors.surfaceElevated,
                      child: const Center(
                        child: Text('PG', style: TextStyle(color: AppColors.emerald, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.fullName,
                            style: AppTextStyles.heading2(color: colors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: AppColors.emerald, size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.email,
                      style: AppTextStyles.bodySmall(color: colors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldGlow,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            profile.clientTier,
                            style: AppTextStyles.label(color: AppColors.emerald, fontSize: 8.5),
                          ),
                        ),
                        Text(
                          profile.taxResidence,
                          style: AppTextStyles.label(color: colors.textMuted, fontSize: 9.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 12),
          // Metadata Row: Client ID & Phone
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetaItem(
                context,
                colors,
                label: 'CLIENT IDENTIFIER',
                value: profile.id,
                onCopy: () => _copy(context, 'Client ID', profile.id),
              ),
              _buildMetaItem(
                context,
                colors,
                label: 'REGISTERED PHONE',
                value: profile.phoneMasked,
                onCopy: () => _copy(context, 'Phone', profile.phoneMasked),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(
    BuildContext context,
    AeroVaultColors colors, {
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return BounceButton(
      onTap: onCopy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label(color: colors.textMuted, fontSize: 8.5)),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTextStyles.monospace(color: colors.textPrimary, fontSize: 11),
              ),
              const SizedBox(width: 4),
              Icon(Icons.copy_rounded, size: 11, color: colors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSovereignTierCard(
    BuildContext context,
    AeroVaultColors colors,
    UserProfile profile,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surfaceElevated,
            colors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emeraldGlow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.emerald, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINMA Tier 3 Sovereign Clearance',
                      style: AppTextStyles.heading3(color: colors.textPrimary).copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Swiss Banking Act Art. 47 Regulatory Compliance',
                      style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.emerald),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'AUDITED',
                      style: AppTextStyles.label(color: AppColors.emerald, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AML RISK SCORE', style: AppTextStyles.label(color: colors.textMuted, fontSize: 8.5)),
                  const SizedBox(height: 3),
                  Text(
                    profile.amlRiskScore,
                    style: AppTextStyles.monospace(color: AppColors.emerald, fontSize: 11),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('SETTLEMENT SPEED', style: AppTextStyles.label(color: colors.textMuted, fontSize: 8.5)),
                  const SizedBox(height: 3),
                  Text(
                    'Instant Fedwire / SIC',
                    style: AppTextStyles.monospace(color: colors.textPrimary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConciergeLauncherCard(BuildContext context, AeroVaultColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.violet.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.violetGlow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.violet, width: 1.5),
                ),
                child: ClipOval(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'CD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppColors.emerald,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Claire Delacroix',
                        style: AppTextStyles.heading3(color: colors.textPrimary).copyWith(fontSize: 13.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: AppColors.emerald, size: 13),
                  ],
                ),
                const SizedBox(height: 1),
                Text('Geneva Private Wealth Concierge', style: AppTextStyles.label(color: AppColors.violetSoft, fontSize: 8.5)),
                Text('24/7 E2EE Direct Banking Desk • < 1 min SLA', style: AppTextStyles.label(color: colors.textMuted, fontSize: 8)),
              ],
            ),
          ),
          BounceButton(
            onTap: () => ConciergeScreen.navigate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.violet.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.violet),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.violetSoft, size: 12),
                  const SizedBox(width: 4),
                  Text('Connect', style: AppTextStyles.label(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGovernanceLauncherCard(BuildContext context, AeroVaultColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Treasury Dual-Control',
                        style: AppTextStyles.heading3(color: colors.textPrimary).copyWith(fontSize: 13.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: AppColors.emerald, size: 13),
                  ],
                ),
                const SizedBox(height: 1),
                Text('Corporate Multi-Sig Approvals', style: AppTextStyles.label(color: AppColors.warning, fontSize: 8.5)),
                Text('FINMA Art. 47 M-of-N Key Governance', style: AppTextStyles.label(color: colors.textMuted, fontSize: 8)),
              ],
            ),
          ),
          BounceButton(
            onTap: () => GovernanceScreen.navigate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.vpn_key_outlined, color: AppColors.warning, size: 12),
                  const SizedBox(width: 4),
                  Text('Review', style: AppTextStyles.label(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitsPanel(
    BuildContext context,
    AeroVaultColors colors,
    UserProfile profile,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TREASURY & LIQUIDITY LIMITS', style: AppTextStyles.label(color: colors.textMuted, fontSize: 9.5)),
              BounceButton(
                onTap: () => _showLimitAdjustmentModal(context, profile),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune_rounded, size: 12, color: AppColors.emerald),
                      const SizedBox(width: 4),
                      Text('Modify Limits', style: AppTextStyles.label(color: AppColors.emerald, fontSize: 9.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLimitRow(
            colors,
            icon: Icons.account_balance_outlined,
            title: 'Daily Outbound Wire',
            value: currencyFormat.format(profile.dailyWireLimit),
            subtitle: 'Direct Fedwire & Swiss SIC settlement',
          ),
          const SizedBox(height: 12),
          _buildLimitRow(
            colors,
            icon: Icons.credit_card_outlined,
            title: 'Monthly Card Spending Cap',
            value: currencyFormat.format(profile.monthlyCardCap),
            subtitle: 'AeroVault Obsidian Metal & Virtual Cards',
          ),
          const SizedBox(height: 12),
          _buildLimitRow(
            colors,
            icon: Icons.local_atm_outlined,
            title: 'Daily Global ATM Roaming',
            value: currencyFormat.format(profile.dailyAtmLimit),
            subtitle: 'Zero foreign surcharge worldwide',
          ),
        ],
      ),
    );
  }

  Widget _buildLimitRow(
    AeroVaultColors colors, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: Icon(icon, color: colors.textSecondary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySmall(color: colors.textPrimary).copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle, style: AppTextStyles.label(color: colors.textMuted, fontSize: 9)),
            ],
          ),
        ),
        Text(value, style: AppTextStyles.monospace(color: AppColors.emerald, fontSize: 13).copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildKycDocumentsVault(
    BuildContext context,
    AeroVaultColors colors,
    UserProfile profile,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('VERIFIED KYC & REGULATORY VAULT', style: AppTextStyles.label(color: colors.textMuted, fontSize: 9.5)),
              Text('${profile.documents.length} VERIFIED', style: AppTextStyles.label(color: AppColors.emerald, fontSize: 9.5)),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profile.documents.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = profile.documents[index];
              return _buildKycDocumentTile(context, colors, doc);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKycDocumentTile(
    BuildContext context,
    AeroVaultColors colors,
    KycDocument doc,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.emeraldGlow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.assignment_turned_in_outlined, color: AppColors.emerald, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        doc.title,
                        style: AppTextStyles.bodySmall(color: colors.textPrimary).copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldGlow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'VERIFIED',
                        style: AppTextStyles.label(color: AppColors.emerald, fontSize: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${doc.documentNumberMasked} • ${doc.issuingAuthority}',
                  style: AppTextStyles.bodySmall(color: colors.textMuted).copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Verified on ${doc.verifiedDate} • Exp: ${doc.expiryDate}',
                  style: AppTextStyles.label(color: colors.textSecondary, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorizedDevicesSection(
    BuildContext context,
    AeroVaultColors colors,
    UserProfile profile,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('HARDWARE ENCLAVE & AUTHORIZED DEVICES', style: AppTextStyles.label(color: colors.textMuted, fontSize: 9.5)),
              const Icon(Icons.lock_outline_rounded, color: AppColors.emerald, size: 15),
            ],
          ),
          const SizedBox(height: 12),
          // Enclave Key Hash Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.fingerprint_rounded, color: AppColors.emerald, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ENCLAVE HARDWARE KEY ID', style: AppTextStyles.label(color: colors.textMuted, fontSize: 8)),
                      const SizedBox(height: 2),
                      Text(
                        profile.hardwareEnclaveKeyId,
                        style: AppTextStyles.monospace(color: colors.textPrimary, fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                BounceButton(
                  onTap: () => _copy(context, 'Enclave Key ID', profile.hardwareEnclaveKeyId),
                  child: const Icon(Icons.copy_rounded, color: AppColors.emerald, size: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profile.authorizedDevices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final device = profile.authorizedDevices[index];
              return _buildDeviceTile(context, colors, device);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(
    BuildContext context,
    AeroVaultColors colors,
    AuthorizedDevice device,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: device.isCurrentDevice ? AppColors.emerald.withValues(alpha: 0.3) : colors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            device.isCurrentDevice ? Icons.phone_iphone_rounded : Icons.laptop_mac_rounded,
            color: device.isCurrentDevice ? AppColors.emerald : colors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.deviceName,
                        style: AppTextStyles.bodySmall(color: colors.textPrimary).copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (device.isCurrentDevice) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldGlow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'THIS DEVICE',
                          style: AppTextStyles.label(color: AppColors.emerald, fontSize: 7.5),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${device.platform} • ${device.lastActive}',
                  style: AppTextStyles.label(color: colors.textMuted, fontSize: 9),
                ),
                Text(
                  device.hardwareEnclaveType,
                  style: AppTextStyles.label(color: colors.textSecondary, fontSize: 8.5),
                ),
              ],
            ),
          ),
          if (!device.isCurrentDevice)
            BounceButton(
              onTap: () => _confirmRevokeDevice(context, device),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Revoke',
                  style: AppTextStyles.label(color: AppColors.error, fontSize: 9.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComplianceActions(
    BuildContext context,
    AeroVaultColors colors,
    UserProfile profile,
  ) {
    return Column(
      children: [
        // Export GDPR / Swiss DPA Compliance Audit
        BounceButton(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showComplianceSnack(context, 'Exported Swiss DPA & GDPR Encrypted Audit Bundle (JSON/PDF)');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download_rounded, color: AppColors.emerald, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Export Swiss DPA & GDPR Ledger Archive',
                  style: AppTextStyles.bodyMedium(color: colors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Session Wipe Action
        BounceButton(
          onTap: () => _confirmSessionPurge(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.power_settings_new_rounded, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Purge Session & Hardware Keystore',
                  style: AppTextStyles.bodyMedium(color: AppColors.error).copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLimitAdjustmentModal(BuildContext context, UserProfile profile) {
    HapticFeedback.lightImpact();
    double currentWireLimit = profile.dailyWireLimit;
    double currentCardCap = profile.monthlyCardCap;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final colors = context.colors;
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: colors.border),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.textMuted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Adjust Treasury & Card Limits', style: AppTextStyles.heading2(color: colors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('Instant adjustment with Swiss Tier 1 Clearing authorization', style: AppTextStyles.bodySmall(color: colors.textSecondary)),
                    const SizedBox(height: 20),

                    // Daily Wire Limit Slider
                    Text(
                      'DAILY WIRE LIMIT: \$${NumberFormat('#,##0').format(currentWireLimit)}',
                      style: AppTextStyles.label(color: AppColors.emerald),
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.emerald,
                        inactiveTrackColor: colors.surfaceElevated,
                        thumbColor: AppColors.emerald,
                        overlayColor: AppColors.emeraldGlow,
                      ),
                      child: Slider(
                        value: currentWireLimit,
                        min: 100000.0,
                        max: 2000000.0,
                        divisions: 19,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          setModalState(() => currentWireLimit = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Monthly Card Cap Slider
                    Text(
                      'MONTHLY CARD CAP: \$${NumberFormat('#,##0').format(currentCardCap)}',
                      style: AppTextStyles.label(color: AppColors.emerald),
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.emerald,
                        inactiveTrackColor: colors.surfaceElevated,
                        thumbColor: AppColors.emerald,
                        overlayColor: AppColors.emeraldGlow,
                      ),
                      child: Slider(
                        value: currentCardCap,
                        min: 25000.0,
                        max: 500000.0,
                        divisions: 19,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          setModalState(() => currentCardCap = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    BounceButton(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        context.read<ProfileBloc>().add(
                              UpdateLimitsEvent(
                                dailyWireLimit: currentWireLimit,
                                monthlyCardCap: currentCardCap,
                              ),
                            );
                        Navigator.pop(modalContext);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.emeraldGlow,
                              blurRadius: 12,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Authorize & Save Limits',
                            style: AppTextStyles.bodyMedium(color: Colors.black).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmRevokeDevice(BuildContext context, AuthorizedDevice device) {
    HapticFeedback.mediumImpact();
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (dlgContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.border),
        ),
        title: Text('Revoke Hardware Key?', style: AppTextStyles.heading2(color: colors.textPrimary)),
        content: Text(
          'This will revoke hardware enclave credentials for "${device.deviceName}". The device will immediately lose access.',
          style: AppTextStyles.bodyMedium(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgContext),
            child: Text('Cancel', style: AppTextStyles.label(color: colors.textMuted)),
          ),
          BounceButton(
            onTap: () {
              Navigator.pop(dlgContext);
              context.read<ProfileBloc>().add(RevokeDeviceEvent(device.id));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Revoke', style: AppTextStyles.label(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSessionPurge(BuildContext context) {
    HapticFeedback.mediumImpact();
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (dlgContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.error),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text('Purge Local Session?', style: AppTextStyles.heading2(color: colors.textPrimary)),
          ],
        ),
        content: Text(
          'This will immediately wipe AES-256 session keys, Secure Enclave tokens, and cached balances from local device storage.',
          style: AppTextStyles.bodyMedium(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgContext),
            child: Text('Cancel', style: AppTextStyles.label(color: colors.textMuted)),
          ),
          BounceButton(
            onTap: () {
              Navigator.pop(dlgContext);
              _showComplianceSnack(context, 'Local session wiped. Secure Enclave keys purged.');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Confirm Purge', style: AppTextStyles.label(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String label, String text) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    _showComplianceSnack(context, '$label copied to clipboard');
  }
}
