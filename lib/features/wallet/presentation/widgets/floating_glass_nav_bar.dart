import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

/// Enterprise Frosted Glass Floating Dock Navigation Bar
/// Adheres to luxury neobank aesthetics with real-time blur and micro-haptics
class FloatingGlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const FloatingGlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Vault'),
    _NavItem(icon: Icons.credit_card_rounded, label: 'Cards'),
    _NavItem(icon: Icons.swap_horizontal_circle_rounded, label: 'Transfers'),
    _NavItem(icon: Icons.insights_rounded, label: 'Growth'),
    _NavItem(icon: Icons.shield_rounded, label: 'Security'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xE60D131F), // Frosted obsidian
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0x3300E599), // Subtle neon emerald hairline
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 28,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Color(0x1A00E599),
                  blurRadius: 16,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final isSelected = selectedIndex == index;
                final item = _items[index];

                return GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      HapticFeedback.selectionClick();
                      onItemSelected(index);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 12 : 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.emerald.withValues(alpha: 0.16)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(
                              color: AppColors.emerald.withValues(alpha: 0.4),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 20,
                          color: isSelected ? AppColors.emerald : AppColors.textMuted,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: AppTextStyles.label(
                            color: isSelected ? AppColors.emerald : AppColors.textDim,
                            fontSize: 9.5,
                          ).copyWith(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
