import 'package:cinteraction_vc/layers/presentation/cubit/ai/ai_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteAiModuleDialog extends StatelessWidget {
  final int companyId;
  final int moduleId;

  const DeleteAiModuleDialog({
    super.key,
    required this.companyId,
    required this.moduleId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Deletion'),
      content: const Text('Are you sure you want to delete this module?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Cancel
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            context.read<AiCubit>().deleteModule(
                  moduleId: moduleId,
                  companyId: companyId,
                );
            Navigator.pop(context); // Close dialog after delete
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
