import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/screens/scrambled_pin_screen.dart';
import '../../domain/entities/payment_card.dart';

class CardSecuritySwitchesWidget extends StatelessWidget {
  final PaymentCard card;
  final ValueChanged<bool> onToggleFreeze;
  final Function(CardChannel channel, bool isEnabled) onToggleChannel;
  final VoidCallback onRegenerateDisposable;

  const CardSecuritySwitchesWidget({
    super.key,
    required this.card,
    required this.onToggleFreeze,
    required this.onToggleChannel,
    required this.onRegenerateDisposable,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              Text(
                'SECURITY & CHANNEL PERMISSIONS',
                style: AppTextStyles.label(color: colors.textSecondary, fontSize: 11),
              ),
              const Icon(Icons.shield_outlined, size: 16, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 12),

          // Freeze / Lock Card Switch
          _buildSwitchRow(
            context,
            icon: Icons.ac_unit_rounded,
            iconColor: card.isFrozen ? const Color(0xFF38BDF8) : colors.textSecondary,
            title: 'Freeze & Lock Card',
            subtitle: 'Instantly block all authorizations and contactless POS',
            value: card.isFrozen,
            activeColor: const Color(0xFF38BDF8),
            onChanged: (val) {
              HapticFeedback.mediumImpact();
              onToggleFreeze(val);
            },
          ),
          const Divider(height: 20, thickness: 0.8),

          // Online Payments
          _buildSwitchRow(
            context,
            icon: Icons.language_rounded,
            iconColor: card.allowOnline ? colors.primary : colors.textSecondary,
            title: 'Online & In-App Purchases',
            subtitle: 'Enable digital checkouts, e-commerce, and Apple Pay',
            value: card.allowOnline,
            activeColor: colors.primary,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onToggleChannel(CardChannel.online, val);
            },
          ),
          const Divider(height: 20, thickness: 0.8),

          // International Roaming
          _buildSwitchRow(
            context,
            icon: Icons.flight_takeoff_rounded,
            iconColor: card.allowInternational ? colors.primary : colors.textSecondary,
            title: 'International ATM & Roaming',
            subtitle: 'Permit foreign currency settlements & physical ATM cash out',
            value: card.allowInternational,
            activeColor: colors.primary,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onToggleChannel(CardChannel.international, val);
            },
          ),
          const Divider(height: 20, thickness: 0.8),

          // Contactless NFC
          _buildSwitchRow(
            context,
            icon: Icons.contactless_rounded,
            iconColor: card.allowContactless ? colors.primary : colors.textSecondary,
            title: 'Contactless Tap-to-Pay',
            subtitle: 'In-store POS wireless payments under \$250 limit',
            value: card.allowContactless,
            activeColor: colors.primary,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onToggleChannel(CardChannel.contactless, val);
            },
          ),

          // Special Controls for Disposable Ghost Card
          if (card.type == CardType.disposableGhost) ...[
            const Divider(height: 24, thickness: 0.8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onRegenerateDisposable();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: context.colors.surfaceElevated,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      content: Text(
                        'New dynamic CVV & card number generated. Prior credentials destroyed.',
                        style: AppTextStyles.bodySmall(color: context.colors.textPrimary),
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFA855F7),
                  side: const BorderSide(color: Color(0xFFA855F7)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.autorenew_rounded, size: 18),
                label: const Text('REGENERATE DYNAMIC CVV NOW'),
              ),
            ),
          ],

          // Card PIN Setting
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                ScrambledPinScreen.push(context);
              },
              icon: Icon(Icons.dialpad_rounded, size: 18, color: colors.primary),
              label: Text(
                'Change Card PIN with Scrambled Keypad',
                style: AppTextStyles.bodySmall(
                  color: colors.primary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium(
                  color: colors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: activeColor.withValues(alpha: 0.35),
          activeThumbColor: activeColor,
        ),
      ],
    );
  }
}
