import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/extension/string.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/dto/chat/chat_detail_dto.dart';
import '../../../profile/ui/widget/user_image.dart';
import 'add_participiant_dialog.dart';

class EditGroupDialog extends StatelessWidget {
  final ChatState state;
  final BuildContext context;

  const EditGroupDialog({
    super.key,
    required this.state,
    required this.context,
  });

  @override
  Widget build(BuildContext innerContext) {
    final allParticipants = [
      ...state.chatDetails!.chatParticipants,
      state.chatDetails!.authUser,
    ];

    List<UserImageDto> userImages =
        allParticipants.map((a) => a.getUserImageDTO()).toList();

    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserImage.medium(userImages),
                const SizedBox(height: 16.0),
                Text(
                  state.chatDetails?.chatName ?? "Group Name",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "${allParticipants.length} participants",
                  ),
                ),
                const SizedBox(height: 40.0),
                SizedBox(
                  height: 300,
                  width: 500,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allParticipants.length,
                    itemBuilder: (context, index) {
                      final participant = allParticipants[index];
                      final isAuthUser =
                          participant.id == state.chatDetails!.authUser.id;

                      return HoverParticipantTile(
                        participant: participant,
                        isAuthUser: isAuthUser,
                        onRemove: () {
                          if (!isAuthUser) {
                            _showRemoveDialog(context, participant.name,
                                state.chatDetails!.chatId!, participant.id);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10.0),
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await Future.delayed(Duration.zero);

                    final currentParticipants = state
                        .chatDetails!.chatParticipants
                        .map((p) => p.id.toString())
                        .toSet();

                    final availableUsers = state.users!
                        .where((user) =>
                            !currentParticipants.contains(user.id.toString()))
                        .toList();

                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AddParticipantsDialog(
                        users: availableUsers,
                        onAddParticipants: (selectedUsers) async {
                          final participantIds = selectedUsers
                              .map((user) => int.parse(user.id))
                              .toList();

                          await getIt
                              .get<ChatCubit>()
                              .chatUseCases
                              .addUserToGroup(
                                  state.chatDetails!.chatId!,
                                  state.chatDetails!.authUser.id,
                                  participantIds);
                        },
                        context: context,
                      ),
                    );
                  },
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.blue),
                        SizedBox(width: 8.0),
                        Text(
                          "Add participants",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.grey,
                size: 24,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(
      BuildContext context, String participantName, int chatId, int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Participant"),
          content: Text(
            "Remove $participantName from this conversation?",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                await getIt
                    .get<ChatCubit>()
                    .chatUseCases
                    .removeUserFromGroup(chatId, userId);
                // I used this for double close
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              },
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );
  }
}

class HoverParticipantTile extends StatefulWidget {
  final ChatParticipantDto participant;
  final bool isAuthUser;
  final VoidCallback onRemove;

  const HoverParticipantTile({
    super.key,
    required this.participant,
    required this.isAuthUser,
    required this.onRemove,
  });

  @override
  State<HoverParticipantTile> createState() => _HoverParticipantTileState();
}

class _HoverParticipantTileState extends State<HoverParticipantTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ListTile(
        contentPadding: const EdgeInsets.all(2),
        leading: UserImage.medium([widget.participant.getUserImageDTO()]),
        title: Text(
          widget.participant.name,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: (_isHovered && !widget.isAuthUser)
            ? TextButton(
                onPressed: widget.onRemove,
                child: const Text(
                  "Remove",
                  style: TextStyle(color: ColorConstants.kPrimaryColor),
                ),
              )
            : null,
      ),
    );
  }
}
