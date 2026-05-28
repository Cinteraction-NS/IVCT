import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/navigation/route.dart';
import 'package:cinteraction_vc/layers/domain/entities/user.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateGroupDialog extends StatelessWidget {
  final ChatState state;
  final BuildContext context;

  const CreateGroupDialog({
    super.key,
    required this.state,
    required this.context,
  });
  @override
  Widget build(BuildContext innerContext) {
    TextEditingController groupNameController = TextEditingController();
    ValueNotifier<List<User>> selectedUsers = ValueNotifier([]);

    void _showValidationError(String message) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: const Text("Create New Group"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: groupNameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text("Add Users:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Container(
              height: 400,
              width: 500,
              child: ValueListenableBuilder<List<User>>(
                valueListenable: selectedUsers,
                builder: (context, selectedList, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.users?.length ?? 0,
                    itemBuilder: (context, index) {
                      var user = state.users![index];
                      return CheckboxListTile(
                        title: Text(user.name),
                        value: selectedList.contains(user),
                        onChanged: (isChecked) {
                          if (isChecked ?? false) {
                            selectedUsers.value = [
                              ...selectedUsers.value,
                              user
                            ];
                          } else {
                            selectedUsers.value = selectedUsers.value
                                .where((u) => u != user)
                                .toList();
                          }
                          selectedUsers.notifyListeners();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (groupNameController.text.isEmpty) {
              _showValidationError("Please enter a group name.");
              return;
            }
            if (selectedUsers.value.isEmpty) {
              _showValidationError("Please select at least one user.");
              return;
            }

            List<int> participantIds =
                selectedUsers.value.map((user) => int.parse(user.id)).toList();

            await getIt.get<ChatCubit>().chatUseCases.sendMessageToChatStream(
                  name: groupNameController.value.text,
                  participantIds: participantIds,
                  senderId: state.chatDetails!.authUser.id,
                  messageContent: '!@checkList',
                );
            // await Future.delayed(const Duration(seconds: 2));

            getIt.get<ChatCubit>().changeListType(ListType.Chats);
            Navigator.of(context).pop();
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
