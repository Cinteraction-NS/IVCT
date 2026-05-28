import 'package:cinteraction_vc/layers/presentation/cubit/ai/ai_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddAiModuleDialog extends StatefulWidget {
  final int companyId;

  const AddAiModuleDialog({super.key, required this.companyId});

  @override
  State<AddAiModuleDialog> createState() => _AddAiModuleDialogState();
}

class _AddAiModuleDialogState extends State<AddAiModuleDialog> {
  String name = '';
  String url = '';
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add AI Module'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (value) => setState(() => name = value),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (value) => setState(() => url = value),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active', style: TextStyle(fontSize: 16)),
                Switch(
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val),
                  activeColor: Colors.green,
                  activeTrackColor: Colors.green[200],
                ),
              ],
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<AiCubit>().addModule(
                  companyId: widget.companyId,
                  name: name,
                  url: url,
                  enabled: isActive ? 1 : 0,
                );
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
