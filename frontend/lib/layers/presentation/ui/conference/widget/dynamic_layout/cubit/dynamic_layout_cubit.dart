import 'package:equatable/equatable.dart';
import '../../../../../../../../core/logger/loggy_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/util/util.dart';
import '../widget/item_size.dart';
import 'dynamic_layout_state.dart';

class DynamicLayoutCubit extends Cubit<DynamicLayoutState> with BlocLoggy {
  DynamicLayoutCubit() : super(const DynamicLayoutState.initial()) {
    _init();
  }
  void _init() {

  }

  Future<void> setStreams(List<StreamRenderer> streams) async {
    emit(state.copyWith(streams: streams));
    _calculateOptimalLayout(1);
  }

  Future<void> onScreenSizeChanged(
      double screenWidth, double screenHeight) async {
    emit(state.copyWith(screenWidth: screenWidth, screenHeight: screenHeight));
    _calculateOptimalLayout(1);

  }

  List<int> distributeItemsToRows(int itemCount, int rowCount) {
    int base = itemCount ~/ rowCount;
    int extra = itemCount % rowCount;

    return List.generate(
      rowCount,
          (index) => index < extra ? base + 1 : base,
    );
  }

  double _calculateArea(List<int> itemsPerRow) {
    final screenArea = state.screenWidth * state.screenHeight;
    final aspectRatio = state.aspectRatios.first;
    final rowCount = itemsPerRow.length;
    final maxHeightPerRow = state.screenHeight / rowCount;

    double totalArea = 0;

    for (final count in itemsPerRow) {
      final maxWidthPerItem = state.screenWidth / count;
      final widthByAspect = maxHeightPerRow * aspectRatio;
      final itemWidth = widthByAspect > maxWidthPerItem ? maxWidthPerItem : widthByAspect;

      final itemSize = _calculateItemSize(itemWidth, maxHeightPerRow, count);
      final rowArea = itemSize.width * itemSize.height * count;

      totalArea += rowArea;
    }

    return totalArea / screenArea * 100;
  }

  void _calculateOptimalLayout(int rowCount) {
    final currentLayout = distributeItemsToRows(state.streams.length, rowCount);
    final currentArea = _calculateArea(currentLayout);

    final nextRowCount = rowCount + 1;
    final nextLayout = distributeItemsToRows(state.streams.length, nextRowCount);
    final nextArea = _calculateArea(nextLayout);

    if (nextArea > currentArea + 3  && nextArea.toInt() <= 100) {
      _calculateOptimalLayout(nextRowCount);
    } else {
      fillMatrix(currentLayout);
    }
  }

  ItemSize _calculateItemSize(double maxWidth, double maxHeight, int itemsInRow) {
    final portraitAspect = state.aspectRatios.length > 1 ? state.aspectRatios[1] : state.aspectRatios.first;

    final minWidth = maxHeight * portraitAspect;
    final maxWidthPerItem = state.screenWidth / itemsInRow;

    if (maxWidth >= minWidth && maxWidth * itemsInRow <= state.screenWidth) {
      return ItemSize(maxWidth, maxHeight);
    } else {
      final height = maxWidthPerItem / portraitAspect;
      return ItemSize(maxWidthPerItem, height);
    }
  }

  void fillMatrix(List<int> itemsPerRow) {
    final aspectRatio = state.aspectRatios.first;
    final rowCount = itemsPerRow.length;
    final maxHeightPerRow = state.screenHeight / rowCount;

    final matrix = itemsPerRow.map((count) {
      final maxWidthPerItem = state.screenWidth / count;
      final widthByAspect = maxHeightPerRow * aspectRatio;
      final itemWidth = widthByAspect > maxWidthPerItem ? maxWidthPerItem : widthByAspect;

      final itemSize = _calculateItemSize(itemWidth, maxHeightPerRow, count);
      return List<ItemSize>.filled(count, itemSize);
    }).toList();

    emit(state.copyWith(matrixxx: matrix));
  }
}
