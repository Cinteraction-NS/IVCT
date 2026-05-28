import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../assets/colors/Colors.dart';
import '../../presentation/ui/charts/ui/widget/chart.dart';

class CreateEngagementDto {
  final int meetingId;
  final int userId;
  final int moduleId;
  final double value;

  CreateEngagementDto({
    required this.meetingId,
    required this.userId,
    required this.moduleId,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'meeting_id': meetingId,
      'user_id': userId,
      'module_id': moduleId,
      'value': value,
    };
  }

  factory CreateEngagementDto.fromJson(Map<String, dynamic> json) {
    return CreateEngagementDto(
      meetingId: json['meeting_id'] as int,
      userId: json['user_id'] as int,
      moduleId: json['module_id'] as int,
      value: (json['value'] as num).toDouble(),
    );
  }
}

class EngagementResponseDto {
  final String message;

  EngagementResponseDto({
    required this.message,
  });

  factory EngagementResponseDto.fromJson(Map<String, dynamic> json) {
    return EngagementResponseDto(
      message: json['message'] as String,
    );
  }
}


class GraphUser{
  final int id;
  final String name;

  GraphUser({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is GraphUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class EngagementTotalAverageDto {

  final List<RawEngagementData> data;
  final List<GraphUser> users;

  EngagementTotalAverageDto({
    required this.data,
    required this.users
  });

  factory EngagementTotalAverageDto.fromJson(List<dynamic> json) {
    // Parse raw data and group by time slots
    final rawData = json
        .map((item) => RawEngagementData.fromJson(item as Map<String, dynamic>))
        .toList();



    final users = rawData.map((e) => GraphUser(id: e.userId, name: e.userName)).toSet().toList();



    List<GraphUser> mockUsers = List.empty(growable: true);
    mockUsers.addAll(users);
    mockUsers.addAll(users);
    mockUsers.addAll(users);
    mockUsers.addAll(users);
    mockUsers.addAll(users);
    return EngagementTotalAverageDto(
      data: rawData,
        users: users
    );
  }


// One line per moduleId. X axis == seconds since `meetStart`.
  /// Each dot is the average for that module inside its time slot.
  List<LineSeries> buildBinnedSeriesByModule({

    required Duration slot,                 // e.g. Duration(seconds: 10)
    required DateTime meetStart,            // meeting absolute start time
    required DateTime meetEnd,              // meeting absolute end time
    int? userId,                            // optional filter
    bool xAsTime = true,                    // true -> x in seconds since start; false -> x = bin index
    bool isCurved = false,
    bool showDots = false,
    double strokeWidth = 1,
  }) {
    if (data.isEmpty) return [];
    assert(meetEnd.isAfter(meetStart), 'meetEnd must be after meetStart');
    final slotMs = slot.inMilliseconds;
    assert(slotMs > 0, 'slot must be > 0');

    // Filter by user if provided and clamp to meeting window [meetStart, meetEnd)
    final filtered = (userId == null ? data : data.where((e) => e.userId == userId))
        .where((e) => !e.createdAt.isBefore(meetStart) && e.createdAt.isBefore(meetEnd))
        .toList();
    if (filtered.isEmpty) return [];

    // Number of slots covering [meetStart, meetEnd)
    final meetDurMs = meetEnd.millisecondsSinceEpoch - meetStart.millisecondsSinceEpoch;
    final slotCount = (meetDurMs + slotMs - 1) ~/ slotMs; // ceil
    if (slotCount <= 0) return [];

    // Group by module
    final Map<int, List<RawEngagementData>> byModule = {};
    for (final d in filtered) {
      byModule.putIfAbsent(d.moduleId, () => []).add(d);
    }

    final List<LineSeries> out = [];

    for (final entry in byModule.entries) {
      final moduleId = entry.key;
      final points = entry.value..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Aggregate values per slot index
      final Map<int, _Agg> binAgg = {}; // slotIndex -> agg
      for (final p in points) {
        final diffMs = p.createdAt.millisecondsSinceEpoch - meetStart.millisecondsSinceEpoch;
        if (diffMs < 0 || diffMs >= meetDurMs) continue; // safety
        final slotIdx = diffMs ~/ slotMs;                // floor → first 10s is slot 0
        (binAgg[slotIdx] ??= _Agg()).add(p.value);
      }

      // Produce FlSpots: one per slot that has data (gaps are allowed)
      final sortedIdx = binAgg.keys.toList()..sort();
      final spots = <FlSpot>[];
      for (final idx in sortedIdx) {
        final x = xAsTime
            ? (idx * slotMs) / 1000.0            // seconds from meeting start
            : idx.toDouble();                    // slot index 0,1,2,...
        spots.add(FlSpot(x, binAgg[idx]!.avg * 100));
      }

      if (spots.isEmpty) continue;

      out.add(
        LineSeries(
          id: points.first.moduleName.isNotEmpty ? points.first.moduleName : 'Module $moduleId',
          spots: spots,
          color: ColorConstants.graphColorFor(moduleId),
          isCurved: isCurved,
          showDots: showDots,
          strokeWidth: strokeWidth,
          fillBelowLine: true,
        ),
      );
    }

    return out;
  }
}

class _Agg {
  double sum = 0;
  int count = 0;
  void add(double v) { sum += v; count++; }
  double get avg => count == 0 ? 0 : sum / count;
}

class EngagementDataPoint {
  final String timeSlotStart;
  final double avgValue;

  EngagementDataPoint({
    required this.timeSlotStart,
    required this.avgValue,
  });

  factory EngagementDataPoint.fromJson(Map<String, dynamic> json) {
    return EngagementDataPoint(
      timeSlotStart: json['time_slot_start'] as String? ?? '',
      avgValue: double.tryParse(json['avg_value']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_slot_start': timeSlotStart,
      'avg_value': avgValue.toString(),
    };
  }
}

class UserEngagementData {
  final int userId;
  final String name;
  final List<EngagementDataPoint> data;

  UserEngagementData({
    required this.userId,
    required this.name,
    required this.data,
  });

  factory UserEngagementData.fromJson(Map<String, dynamic> json) {
    return UserEngagementData(
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) =>
                  EngagementDataPoint.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'data': data.map((d) => d.toJson()).toList(),
    };
  }
}

class RawEngagementData {
  final int id;
  final int meetingId;
  final int userId;
  final String userName;
  final int moduleId;
  final String moduleName;
  final double value;
  final DateTime createdAt;

  RawEngagementData({
    required this.id,
    required this.meetingId,
    required this.userId,
    required this.userName,
    required this.moduleId,
    required this.moduleName,
    required this.value,
    required this.createdAt,
  });

  factory RawEngagementData.fromJson(Map<String, dynamic> json) {
    return RawEngagementData(
      id: json['id'] as int? ?? 0,
      meetingId: json['meeting_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      userName: json['user_name'] as String? ?? '',
      moduleId: json['module_id'] as int? ?? 0,
      moduleName: json['module_name'] as String? ?? '',
      value: double.tryParse(json['value']?.toString() ?? '0') ?? 0.0,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

class TimeSlot {
  final DateTime start;
  final DateTime end;

  TimeSlot({required this.start, required this.end});
}
