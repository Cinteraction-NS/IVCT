import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// A single series to be drawn on the MultiLineChart.
class LineSeries {
  final String id;
  final List<FlSpot> spots;

  /// Use either [color] or [gradient]; if both are provided, [gradient] wins.
  final Color? color;
  final Gradient? gradient;

  final bool isCurved;
  final double strokeWidth;
  final bool showDots;
  final bool fillBelowLine;
  final int? dashArray; // e.g., 6 makes a dashed line

  LineSeries({
    required this.id,
    required this.spots,
    this.color,
    this.gradient,
    this.isCurved = false,
    this.strokeWidth = 2.0,
    this.showDots = false,
    this.fillBelowLine = false,
    this.dashArray,
  });
}

/// Reusable multi-line chart with sensible defaults and customization hooks.
class MultiLineChart extends StatelessWidget {
  final List<LineSeries> series;

  /// Optional explicit bounds. If null, inferred from data (with small padding).
  final double? minX;
  final double? maxX;

  /// How often to show grid/titles; if null, a “nice” interval is computed.
  final double? bottomInterval;
  final double? leftInterval;

  /// Axis label builders. Provide your own formatter (e.g. map x->DateTime).
  final Widget Function(double value, TitleMeta meta)? bottomTitleBuilder;
  final Widget Function(double value, TitleMeta meta)? leftTitleBuilder;

  /// Toggle grid/border/legend.
  final bool showGrid;
  final bool showBorder;
  final bool showLegend;
  final bool showSideTitles;
  final bool showBottomTitles;

  /// Height of the chart; wrap with SizedBox/Expanded outside if you prefer.
  final double height;

  /// Padding around chart.
  final EdgeInsetsGeometry padding;

  final Color backgroundColor;

  final String? title;

  const MultiLineChart(
      {super.key,
      required this.series,
      this.minX,
      this.maxX,
      this.bottomInterval,
      this.leftInterval,
      this.bottomTitleBuilder,
      this.leftTitleBuilder,
      this.showGrid = true,
      this.showBorder = true,
      this.showLegend = true,
      this.showSideTitles = true,
      this.showBottomTitles = true,
      this.height = 260,
      this.padding = const EdgeInsets.all(12),
      this.backgroundColor = Colors.white,
      this.title
      });

  @override
  Widget build(BuildContext context) {
    assert(series.isNotEmpty, 'Provide at least one series');

    // Flatten all points to infer bounds if not provided.
    final allSpots = series.expand((s) => s.spots);
    final inferredMinX = minX ??
        (allSpots
                .map((e) => e.x)
                .fold<double>(double.infinity, (a, b) => a < b ? a : b)) -
            0.5;
    final inferredMaxX = maxX ??
        (allSpots
                .map((e) => e.x)
                .fold<double>(-double.infinity, (a, b) => a > b ? a : b)) +
            0.5;

    // Add a touch of padding so lines don’t hug the border
    final xInterval = bottomInterval ??
        _niceInterval(inferredMinX, inferredMaxX, targetTicks: 6);

    final lines = series.map((s) {
      final gradient = s.gradient;
      final color = s.color ?? Colors.blueGrey;
      return LineChartBarData(
        spots: s.spots,
        isCurved: s.isCurved,
        barWidth: s.strokeWidth,
        dotData: FlDotData(show: s.showDots),
        isStrokeCapRound: true,
        dashArray: s.dashArray != null ? [s.dashArray!, s.dashArray!] : null,
        gradient: gradient,
        color: gradient == null ? color : null,
        belowBarData: BarAreaData(
          show: s.fillBelowLine,
          gradient: gradient ??
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (s.color ?? Colors.blueGrey).withOpacity(0.25),
                  Colors.transparent,
                ],
              ),
        ),
      );
    }).toList();

    double yMin = 0;
    double yMax = 100;
    double yInterval = 10;

    final chart = LineChart(
      LineChartData(
        minX: inferredMinX,
        maxX: inferredMaxX,
        minY: yMin,
        maxY: yMax,
        lineBarsData: lines,
        gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: true,
          horizontalInterval: yInterval,
          verticalInterval: xInterval,
          getDrawingHorizontalLine: (value) =>
              FlLine(strokeWidth: 0.3, color: Theme.of(context).dividerColor),
          getDrawingVerticalLine: (value) => FlLine(
              strokeWidth: 0.3,
              color: Theme.of(context).dividerColor.withOpacity(0.6)),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: showSideTitles,
              reservedSize: 44,
              interval: yInterval,
              getTitlesWidget: leftTitleBuilder ??
                  (v, meta) => Text(
                        _trimTrailingZeros(v),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: showBottomTitles,
              interval: xInterval,
              reservedSize: 28,
              getTitlesWidget: bottomTitleBuilder ??
                  (v, meta) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _trimTrailingZeros(v),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: showBorder,
          border: Border.all(
            width: 0.6,
            color: Theme.of(context).dividerColor,
          ),
        ),
        lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (barData, indicators) {
            return indicators.map((index) {

              return TouchedSpotIndicatorData(
                const FlLine(color: Colors.red, strokeWidth: 1), // hide vertical line if you want
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                        radius: 3, // 👈 smaller circle (default ~6)
                        color: barData.color ?? Colors.white,
                      ),
                ),
              );
            }).toList();
          },
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((ts) {
                final s = series[ts.barIndex];
                // final label = s.id;
                final valueY  = double.parse(ts.y.toStringAsFixed(2));
                final val = '${_trimTrailingZeros(valueY)}%';
                return LineTooltipItem(
                  val, TextStyle(fontSize: 12, color: (s.color ?? Colors.white),
                  ),
                );
              }).toList();
            },

          ),
        ),
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );

    return Card(
      color: backgroundColor,
      margin: padding,
      elevation: showBorder ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: showBorder
            ? const BorderSide(color: Colors.white, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // helps if parent allows intrinsic height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(title != null)
              Column(
                  children: [
        Text(
        title!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
                    const SizedBox(height: 12),
                  ],
                ),
            if (showLegend) _Legend(series: series),
            const SizedBox(height: 12),
            Flexible(
              // 👈 instead of SizedBox(height: height)
              child: SizedBox(
                width: double.infinity,
                child: chart,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static double _niceInterval(double min, double max, {int targetTicks = 5}) {
    final span = (max - min).abs();
    if (span == 0 || span.isNaN || span.isInfinite) return 1;
    final raw = span / targetTicks;
    final mag = _pow10((log10(raw)).floor());
    final norm = raw / mag;
    double nice;
    if (norm < 1.5) {
      nice = 1;
    } else if (norm < 3) {
      nice = 2;
    } else if (norm < 7) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * mag;
  }

  static double _pow10(int p) {
    double v = 1;
    for (int i = 0; i < p; i++) v *= 10;
    return v;
  }

  static double log10(num x) => (x == 0) ? 0 : (log(x) / ln10);

  static String _trimTrailingZeros(double v) {
    var s = v.toStringAsFixed(6);
    s = s.replaceFirst(RegExp(r'\.?0+$'), '');
    return s;
  }
}

class _Legend extends StatelessWidget {
  final List<LineSeries> series;
  const _Legend({required this.series});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: series.map((s) {
        final color = s.color ?? Colors.blueGrey;

        // Calculate average value for this series
        double averageValue = 0;
        if (s.spots.isNotEmpty) {
          averageValue = s.spots.map((spot) => spot.y).reduce((a, b) => a + b) /
              s.spots.length;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: s.gradient,
                color: s.gradient == null ? color : null,
                border: Border.all(color: Colors.black12, width: 0.5),
              ),
            ),
            const SizedBox(width: 6),
            Text('${s.id} (${averageValue.toInt()}%)',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        );
      }).toList(),
    );
  }
}
