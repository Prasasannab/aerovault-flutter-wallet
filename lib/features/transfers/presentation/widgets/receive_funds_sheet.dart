import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bounce_button.dart';

/// Interactive Receive Funds Sheet
/// Displays Fiat IBAN/SWIFT Wire details & Crypto Deposit addresses
/// with a procedural high-tech CustomPainter QR code.
class ReceiveFundsSheet extends StatefulWidget {
  const ReceiveFundsSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ReceiveFundsSheet(),
    );
  }

  @override
  State<ReceiveFundsSheet> createState() => _ReceiveFundsSheetState();
}

class _ReceiveFundsSheetState extends State<ReceiveFundsSheet> {
  int _selectedTabIndex = 0; // 0: Fiat, 1: Crypto
  int _selectedCryptoIndex = 0; // 0: BTC, 1: ETH, 2: SOL

  final List<Map<String, String>> _cryptoAssets = [
    {
      'symbol': 'BTC',
      'name': 'Bitcoin',
      'network': 'Bitcoin Native SegWit',
      'address': 'bc1q9x0z6a74z34p0e2k9lvhj8a7k8m9v2w4',
    },
    {
      'symbol': 'ETH',
      'name': 'Ethereum',
      'network': 'Ethereum Mainnet (ERC-20)',
      'address': '0x71C8A3d994Ae4bB4Ff4961D12C09249E34B9C2A9',
    },
    {
      'symbol': 'SOL',
      'name': 'Solana',
      'network': 'Solana Mainnet-Beta',
      'address': '7Np2K1xV9uA3mH4kL8jQ5wR6tY7bN8cX9vM1pQ',
    },
  ];

  void _copyToClipboard(String label, String value) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: context.colors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: colors.cardBorder.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 36,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_downward_rounded,
                        color: colors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Receive Funds',
                          style: AppTextStyles.heading2(color: colors.textPrimary).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Direct Deposit & Crypto Vault',
                          style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.textSecondary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.cardBorder.withValues(alpha: 0.5)),

          // Segmented Tab Switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.cardBorder.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      index: 0,
                      label: 'Fiat Wire (IBAN/SWIFT)',
                      icon: Icons.account_balance_rounded,
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      index: 1,
                      label: 'Crypto (QR / Address)',
                      icon: Icons.qr_code_2_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _selectedTabIndex == 0
                  ? _buildFiatDetails(context)
                  : _buildCryptoDetails(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedTabIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primaryGlow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.black : colors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiatDetails(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        // Custody Trust Badge
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.cardBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: colors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FDIC & FINMA Segregated Custody',
                      style: AppTextStyles.label(
                        color: colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Institutional multi-currency wire account held in Zurich & New York.',
                      style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Wire Details Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.cardBorder,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildDetailItem(
                label: 'Beneficiary Name',
                value: 'Prasanna Buddhika',
              ),
              _buildDivider(),
              _buildDetailItem(
                label: 'Bank Name',
                value: 'AeroVault Sovereign Trust Ltd',
              ),
              _buildDivider(),
              _buildDetailItem(
                label: 'IBAN (EUR / CHF)',
                value: 'CH93 0076 2011 6238 5295 7',
                isMonospace: true,
                canCopy: true,
              ),
              _buildDivider(),
              _buildDetailItem(
                label: 'SWIFT / BIC Code',
                value: 'AEROCHZZ80A',
                isMonospace: true,
                canCopy: true,
              ),
              _buildDivider(),
              _buildDetailItem(
                label: 'Fedwire Routing (USD)',
                value: '021000021',
                isMonospace: true,
                canCopy: true,
              ),
              _buildDivider(),
              _buildDetailItem(
                label: 'Account Number',
                value: '8942019823',
                isMonospace: true,
                canCopy: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Share Details CTA
        BounceButton(
          onTap: () {
            HapticFeedback.lightImpact();
            _copyToClipboard('Wire Instructions', '''Beneficiary: Prasanna Buddhika
Bank: AeroVault Sovereign Trust Ltd
IBAN: CH93 0076 2011 6238 5295 7
SWIFT/BIC: AEROCHZZ80A
Routing: 021000021
Account: 8942019823''');
          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.copy_all_rounded,
                  color: colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Copy All Wire Instructions',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCryptoDetails(BuildContext context) {
    final colors = context.colors;
    final currentAsset = _cryptoAssets[_selectedCryptoIndex];

    return Column(
      children: [
        // Crypto Asset Selector Pills
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: List.generate(_cryptoAssets.length, (idx) {
            final asset = _cryptoAssets[idx];
            final isSelected = idx == _selectedCryptoIndex;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCryptoIndex = idx);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withValues(alpha: 0.15)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.cardBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      asset['symbol']!,
                      style: TextStyle(
                        color: isSelected ? colors.primary : colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      asset['name']!,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        // Procedural Custom QR Code Box with Ambient Glow
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, // Crisp high-contrast white backing for scanner readability
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.primaryGlow.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: 190,
                height: 190,
                child: CustomPaint(
                  painter: VaultQrPainter(
                    seed: currentAsset['address']!.hashCode,
                    accentColor: const Color(0xFF0D141F),
                    finderColor: const Color(0xFF00B074),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Network Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Text(
            currentAsset['network']!,
            style: AppTextStyles.label(
              color: colors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Address Box with Copy Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  currentAsset['address']!,
                  style: AppTextStyles.monospace(
                    color: colors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              BounceButton(
                onTap: () => _copyToClipboard(
                  '${currentAsset['symbol']} Address',
                  currentAsset['address']!,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.primary),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.copy_rounded, color: colors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Confirmation notice
        Text(
          'Funds will be credited automatically after 3 blockchain confirmations.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    bool isMonospace = false,
    bool canCopy = false,
  }) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall(color: colors.textSecondary).copyWith(
            fontSize: 13,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: isMonospace
                  ? AppTextStyles.monospace(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )
                  : AppTextStyles.bodyMedium(
                      color: colors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
            ),
            if (canCopy) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _copyToClipboard(label, value),
                child: Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: colors.primary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 20,
      thickness: 0.6,
      color: context.colors.cardBorder.withValues(alpha: 0.4),
    );
  }
}

/// Standalone Procedural QR Code Custom Painter
/// Draws mathematical finder patterns, timing patterns, data modules,
/// and an AeroVault stylized diamond lock emblem at the center.
class VaultQrPainter extends CustomPainter {
  final int seed;
  final Color accentColor;
  final Color finderColor;

  VaultQrPainter({
    required this.seed,
    required this.accentColor,
    required this.finderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const int matrixSize = 21;
    final double cellSize = size.width / matrixSize;

    final darkPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final finderPaint = Paint()
      ..color = finderColor
      ..style = PaintingStyle.fill;

    // 1. Draw 3 Standard Corner Finder Patterns
    _drawFinderPattern(canvas, 0, 0, cellSize, finderPaint, darkPaint);
    _drawFinderPattern(canvas, matrixSize - 7, 0, cellSize, finderPaint, darkPaint);
    _drawFinderPattern(canvas, 0, matrixSize - 7, cellSize, finderPaint, darkPaint);

    // 2. Deterministic Procedural Data Modules based on address seed
    final rng = Random(seed);
    for (int r = 0; r < matrixSize; r++) {
      for (int c = 0; c < matrixSize; c++) {
        // Skip corner finder zones
        if ((r < 7 && c < 7) ||
            (r < 7 && c >= matrixSize - 7) ||
            (r >= matrixSize - 7 && c < 7)) {
          continue;
        }

        // Reserve center emblem zone (7x7 in center)
        if (r >= 8 && r <= 12 && c >= 8 && c <= 12) {
          continue;
        }

        // Timing patterns
        if (r == 6 || c == 6) {
          if ((r + c) % 2 == 0) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(c * cellSize, r * cellSize, cellSize * 0.9, cellSize * 0.9),
                const Radius.circular(1.5),
              ),
              darkPaint,
            );
          }
          continue;
        }

        // Pseudo-random deterministic module fill
        if (rng.nextBool()) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * cellSize, r * cellSize, cellSize * 0.9, cellSize * 0.9),
              const Radius.circular(1.5),
            ),
            darkPaint,
          );
        }
      }
    }

    // 3. Center AeroVault Emblem (Metallic Diamond Shield)
    final double centerOffset = 8 * cellSize;
    final double centerSpan = 5 * cellSize;
    final centerRect = Rect.fromLTWH(centerOffset, centerOffset, centerSpan, centerSpan);

    // Emblem white background mask
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, const Radius.circular(6)),
      Paint()..color = Colors.white,
    );

    // Diamond Logo
    final diamondPath = Path()
      ..moveTo(size.width / 2, centerOffset + 4)
      ..lineTo(centerOffset + centerSpan - 4, size.height / 2)
      ..lineTo(size.width / 2, centerOffset + centerSpan - 4)
      ..lineTo(centerOffset + 4, size.height / 2)
      ..close();

    canvas.drawPath(diamondPath, finderPaint);

    // Small inner core
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      cellSize * 0.7,
      Paint()..color = Colors.white,
    );
  }

  void _drawFinderPattern(
    Canvas canvas,
    int col,
    int row,
    double cellSize,
    Paint outerPaint,
    Paint innerPaint,
  ) {
    final x = col * cellSize;
    final y = row * cellSize;

    // 7x7 Outer Box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 7 * cellSize, 7 * cellSize),
        const Radius.circular(6),
      ),
      outerPaint,
    );

    // 5x5 White Ring
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + cellSize, y + cellSize, 5 * cellSize, 5 * cellSize),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white,
    );

    // 3x3 Inner Core
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 2 * cellSize, y + 2 * cellSize, 3 * cellSize, 3 * cellSize),
        const Radius.circular(3),
      ),
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant VaultQrPainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.finderColor != finderColor;
}
