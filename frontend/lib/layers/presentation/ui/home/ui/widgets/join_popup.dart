import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class JoinPopup extends StatelessWidget {
  const JoinPopup({super.key});

  @override
  Widget build(BuildContext context) {

    TextEditingController textFieldController = TextEditingController();

    void join()
    {
      Navigator.pop(context);
      // context.pushReplacement('/echo');
      context.pushNamed('meeting',
          pathParameters: {
            'roomId': textFieldController.text,
          },
          extra: context.getCurrentUser?.name);
    }

        return AlertDialog(
          title: const Text('Enter room ID'),
          content: TextField(
            autofocus: true,
            controller: textFieldController,
            decoration: const InputDecoration(hintText: "Room ID"),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              // Your action here
              join();
            },

          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Join'),
              onPressed: () {
                join();
              },
            ),
          ],
    );
  }
}