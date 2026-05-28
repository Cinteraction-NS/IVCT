import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubit/chat/chat_cubit.dart';
import '../../../../cubit/chat/chat_state.dart';
import '../../../../cubit/conference/conference_cubit.dart';
import '../../../chat/widget/chat_details_widget.dart';

Widget getChatView(BuildContext context, double width) {
  return Container(
    width: width,
    height: double.maxFinite,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(23.0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chat messages',
                  style: context.titleTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  context.read<ConferenceCubit>().toggleChatWindow();
                },
              )
            ],
          ),
          Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                builder: (context, state) {
                  return ChatDetailsWidget(state);
                },
                listener: (BuildContext context, ChatState state) {},
              )),
        ],
      ),
    ),
  );
}