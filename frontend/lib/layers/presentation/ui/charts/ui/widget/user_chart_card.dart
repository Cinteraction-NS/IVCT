import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../../assets/colors/Colors.dart';
import '../../../../../data/dto/engagement_dto.dart';
import 'chart.dart';

class UserChartCard extends StatelessWidget {
  final String userName;
  final double duration;
  final List<LineSeries> data; // time-based points

  const UserChartCard({
    super.key,
    required this.userName,
    required this.duration,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return
      SizedBox(
        height: 300,
         child:         MultiLineChart(
                    title: userName,
                    minX: 0,
                    maxX: duration,
                    series: data,
                    // Example: custom bottom titles if x is time index
                    bottomTitleBuilder: (value, meta) {
                      if(value % 10 != 0)
                      {
                        return const Text("");
                      }

                      final secs = value.round(); // or: (value + 1e-6).floor()
                      final m = (secs ~/ 60).toString().padLeft(2, '0');
                      final s = (secs % 60).toString().padLeft(2, '0');
                      return Text('$m:$s', style: Theme.of(context).textTheme.labelSmall);
                    },
                    leftTitleBuilder: (value, meta) => Text('${value.toInt()}%', style: Theme.of(context).textTheme.labelSmall),
                  )

      );
  }
}
