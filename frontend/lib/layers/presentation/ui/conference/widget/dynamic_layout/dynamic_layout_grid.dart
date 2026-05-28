import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/participant_video_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/dynamic_layout_cubit.dart';
import 'cubit/dynamic_layout_state.dart';

class DynamicLayoutGrid extends StatelessWidget {
  const DynamicLayoutGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DynamicLayoutCubit, DynamicLayoutState>(
      builder: (context, state) {
        return LayoutBuilder(builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          if (state.screenWidth != screenWidth ||
              state.screenHeight != screenHeight) {
            context
                .read<DynamicLayoutCubit>()
                .onScreenSizeChanged(screenWidth, screenHeight);
          }

          var matrix = state.matrixxx;

          var index = -1;
          return Center(
            child: SizedBox(
              height: screenHeight,
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: matrix.map((row) {
                  final itemsInRow = row.length;
                  final rowCount = matrix.length;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((itemSize) {
                      index++;
                      final maxWidthPerItem = screenWidth / itemsInRow;
                      final maxHeightPerItem = screenHeight / rowCount;

                      final stretchedWidth =
                      itemSize.width.clamp(0.0, maxWidthPerItem);
                      final stretchedHeight =
                      itemSize.height.clamp(0.0, maxHeightPerItem);
                      return ParticipantVideoWidget(remoteStream: state.streams[index], height: stretchedHeight, width: stretchedWidth);
                    }).toList(),

                  );
                }).toList(),
              ),
            ),
          );
        });
      },
      listenWhen: (previous, current) {
        if (previous.streams != current.streams) return true;
        if (previous.screenWidth != current.screenWidth) return true;
        return false;
      },
      listener: (BuildContext context, DynamicLayoutState state) {
        // print("state changed");
      },
    );
  }
}