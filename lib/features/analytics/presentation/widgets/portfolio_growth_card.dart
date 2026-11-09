import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final primaryColor = isPositive ? AppColors.emerald : AppColors.error;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Portfolio Growth',
                            style: AppTextStyles.heading3(),
                            overflow: TextOverflow.ellipsis,
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
                          style: AppTextStyles.bodySmall(color: AppColors.textMuted),
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
          const SizedBox(height: 20),

          // Interactive fl_chart
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: performance.minValue * 0.98,
                maxY: performance.maxValue * 1.02,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (performance.maxValue - performance.minValue) / 3,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border.withValues(alpha: 0.5),
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
                      reservedSize: 22,
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
                            style: AppTextStyles.bodySmall(color: AppColors.textDim),
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
                    getTooltipColor: (spot) => AppColors.surfaceElevated,
                    tooltipBorderRadius: BorderRadius.circular(10),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          currencyFormatter.format(spot.y),
                          AppTextStyles.bodySmall().copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.emerald,
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
                    dotData: const FlDotData(show: false),
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
