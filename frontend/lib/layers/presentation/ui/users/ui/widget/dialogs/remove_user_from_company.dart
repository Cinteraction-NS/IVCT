import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/company/company_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoveUserFromCompany extends StatelessWidget {
  final int userId;
  const RemoveUserFromCompany({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Remove user'),
      content: const Text(
        'Are you sure you want to remove user from the company?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            await context.read<CompanyCubit>().removeUserFromCompany(
                companyId: context.getCurrentUser!.companyId!, userId: userId);
            context.read<ChatCubit>().removeUserLocally(userId);
            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
