import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/payment_card.dart';

class NewCardSheet extends StatefulWidget {
  final Function(String name, CardType type, double limit) onCardCreated;

  const NewCardSheet({super.key, required this.onCardCreated});

  static Future<void> show(
    BuildContext context, {
    required Function(String name, CardType type, double limit) onCardCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewCardSheet(onCardCreated: onCardCreated),
    );
  }

  @override
  State<NewCardSheet> createState() => _NewCardSheetState();
}

class _NewCardSheetState extends State<NewCardSheet> {
  final _nameController = TextEditingController(text: 'Cloud Subscriptions');
  CardType _selectedType = CardType.virtualDebit;
  double _spendingLimit = 5000.0;
  bool _isIssuing = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleIssueCard() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isIssuing = true);

    final biometric = sl<BiometricService>();
    final auth = await biometric.authenticate(
      localizedReason: 'Authorize issuance of new ${_selectedType.name} card',
    );

    if (auth) {
      HapticFeedback.heavyImpact();
      widget.onCardCreated(name, _selectedType, _spendingLimit);
      if (mounted) Navigator.pop(context);
    } else {
      HapticFeedback.vibrate();
      setState(() => _isIssuing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 30),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: colors.border),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Issue New AeroVault Card',
                    style: AppTextStyles.heading2(color: colors.textPrimary),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                  ),
                ],
              ),
              Text(
                'Instant digital provisioning with zero plastic overhead',
                style: AppTextStyles.bodySmall(color: colors.textSecondary),
              ),
              const SizedBox(height: 22),

              // Card Type Selection
              Text('SELECT CARD TIER', style: AppTextStyles.label(color: colors.textSecondary, fontSize: 11)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeOption(
                      title: 'Virtual Debit',
                      subtitle: 'Everyday Apple Pay',
                      icon: Icons.credit_card_rounded,
                      color: const Color(0xFF00E599),
                      type: CardType.virtualDebit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeOption(
                      title: 'Disposable Ghost',
                      subtitle: 'Auto-destruct CVV',
                      icon: Icons.shield_moon_rounded,
                      color: const Color(0xFFA855F7),
                      type: CardType.disposableGhost,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Card Label / Name
              Text('CARD NICKNAME', style: AppTextStyles.label(color: colors.textSecondary, fontSize: 11)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: AppTextStyles.bodyMedium(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. AWS & SaaS Ops',
                  hintStyle: AppTextStyles.bodyMedium(color: colors.textSecondary),
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Spending Cap
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MONTHLY SPENDING CAP', style: AppTextStyles.label(color: colors.textSecondary, fontSize: 11)),
                  Text(
                    '\$${_spendingLimit.toStringAsFixed(0)}',
                    style: AppTextStyles.monospace(color: colors.primary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: colors.primary,
                  inactiveTrackColor: colors.border,
                  thumbColor: colors.primary,
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _spendingLimit,
                  min: 500,
                  max: 25000,
                  divisions: 49,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _spendingLimit = val);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Issue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isIssuing ? null : _handleIssueCard,
                  icon: _isIssuing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.fingerprint_rounded),
                  label: Text(_isIssuing ? 'PROVISIONING HARDWARE CIPHER...' : 'AUTHORIZE & ISSUE CARD'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required CardType type,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedType = type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : context.colors.border,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyles.bodyMedium(
                color: context.colors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
