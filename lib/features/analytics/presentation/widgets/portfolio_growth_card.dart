import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/aerovault_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/glass_decorations.dart';
import '../../domain/entities/portfolio_performance.dart';
import 'timeframe_selector_widget.dart';

/// 60fps Dynamic Bezier Curve Growth Chart with Interactive Tooltips
class PortfolioGrowthCard extends StatelessWidget {
  final PortfolioPerformance performance;
  final ValueChanged<String> onTimeframeChanged;

  const PortfolioGrowthCard({
    super.key,
    required this.performance,
    required this.onTimeframeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isPositive = performance.isPositive;
    final colors = context.colors;
    final primaryColor = isPositive
        ? colors.primary
        : AppColors.error;

    return GlassContainer(
      backgroundColor: colors.surface,
      borderColor: colors.border,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Growth Tag & Timeframe Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: primaryColor,
                          size: 17,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Portfolio Growth',
                          style: AppTextStyles.heading3().copyWith(
                            fontSize: 14.5,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.9),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(
                          '+${performance.percentageGrowth.toStringAsFixed(1)}%',
                          style: AppTextStyles.label(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '(+${currencyFormatter.format(performance.netGrowthUsd)})',
                          style: AppTextStyles.bodySmall(color: colors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TimeframeSelectorWidget(
                activeTimeframe: performance.timeframe,
                onSelectTimeframe: onTimeframeChanged,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Interactive fl_chart with Live Tip Dot
          SizedBox(
            height: 125,
            child: LineChart(
              LineChartData(
                minY: performance.minValue * 0.98,
                maxY: performance.maxValue * 1.02,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (performance.maxValue - performance.minValue) / 3,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colors.border.withValues(alpha: 0.6),
                    strokeWidth: 1,
                    dashArray: [6, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < performance.points.length) {
                          // Display select points to prevent text crowding
                          if (performance.points.length > 8 && index % 2 != 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            performance.points[index].dateLabel,
                            style: AppTextStyles.bodySmall(color: colors.textDim).copyWith(fontSize: 10),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => colors.surfaceElevated,
                    tooltipBorderRadius: BorderRadius.circular(10),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          currencyFormatter.format(spot.y),
                          AppTextStyles.bodySmall().copyWith(
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: performance.points.map((p) => FlSpot(p.x, p.y)).toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: primaryColor,
                    barWidth: 2.8,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        return spot.x == barData.spots.last.x;
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: primaryColor,
                          strokeWidth: 2.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryColor.withValues(alpha: 0.3),
                          primaryColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
