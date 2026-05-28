import 'package:equatable/equatable.dart';

import '../../../../../../../../core/util/util.dart';
import '../widget/item_size.dart';

class DynamicLayoutState extends Equatable {
  final List<StreamRenderer> streams; // numberOfStreams
  final List<double> aspectRatios;
  final List<double> finalWidths;
  final List<List<ItemSize>> matrixxx;
  final double screenWidth;
  final double screenHeight;
  final int landscapePerRow;
  final List<bool> matrix;
  final double itemHeight;

  const DynamicLayoutState({
    required this.streams,
    required this.aspectRatios,
    required this.screenWidth,
    required this.screenHeight,
    required this.landscapePerRow,
    required this.matrix,
    required this.itemHeight,
    required this.finalWidths,
    required this.matrixxx,
  });

  const DynamicLayoutState.initial(
      {List<StreamRenderer> streams = const [],
        List<double> aspectRatios = const [16 / 9, 3 / 4],
        List<double> finalWidths = const [],
        List<List<ItemSize>> matrixxx = const [],
        double screenWidth = 1920,
        double screenHeight = 1080,
        int landscapePerRow = 0,
        List<bool> matrix = const [],
        double itemHeight = 1080})
      : this(
    streams: streams,
    aspectRatios: aspectRatios,
    finalWidths: finalWidths,
    matrixxx: matrixxx,
    screenWidth: screenWidth,
    screenHeight: screenHeight,
    landscapePerRow: landscapePerRow,
    matrix: matrix,
    itemHeight: itemHeight,
  );

  @override
  List<Object?> get props => [
    streams,
    aspectRatios,
    screenWidth,
    screenHeight,
    landscapePerRow,
    matrix,
    itemHeight,
    finalWidths,
    matrixxx
  ];

  DynamicLayoutState copyWith({
    List<StreamRenderer>? streams,
    List<double>? aspectRatios,
    List<double>? finalWidths,
    List<List<ItemSize>>? matrixxx,
    double? screenWidth,
    double? screenHeight,
    double? itemHeight,
    int? landscapePerRow,
    List<bool>? matrix,
  }) {
    return DynamicLayoutState(
      streams: streams ?? this.streams,
      aspectRatios: aspectRatios ?? this.aspectRatios,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      landscapePerRow: landscapePerRow ?? this.landscapePerRow,
      matrix: matrix ?? this.matrix,
      itemHeight: itemHeight ?? this.itemHeight,
      finalWidths: finalWidths ?? this.finalWidths,
      matrixxx: matrixxx ?? this.matrixxx,
    );
  }
}