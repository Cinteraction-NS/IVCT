import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/company/company_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/company/company_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InviteUserModel {
  final String email;
  final bool isAdmin;

  InviteUserModel({required this.email, required this.isAdmin});
}

class InviteUsersDialog extends StatefulWidget {
  const InviteUsersDialog({super.key});

  @override
  State<InviteUsersDialog> createState() => _InviteUsersDialogState();
}

class _InviteUsersDialogState extends State<InviteUsersDialog> {
  final List<_InviteUserFormItem> _users = [_InviteUserFormItem()];
  bool isSubmitting = false;

  void _addUserField() {
    setState(() => _users.add(_InviteUserFormItem()));
  }

  void _removeUserField(int index) {
    setState(() => _users.removeAt(index));
  }

  Future<void> _submitInvites() async {
    setState(() => isSubmitting = true);

    final users = _users
        .map((u) => InviteUserModel(
              email: u.emailController.text.trim(),
              isAdmin: u.isAdmin,
            ))
        .where((u) => u.email.isNotEmpty)
        .toList();

    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter at least one email")),
      );
      setState(() => isSubmitting = false);
      return;
    }

    await context.read<CompanyCubit>().inviteMultipleUsers(
          companyId: context.getCurrentUser!.companyId!,
          users: users,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyCubit, CompanyState>(
      listener: (context, state) {
        if (state is CompanySuccess) {
          context.showSnackBarMessage(
              'Invitation sent successfully. Awaiting user confirmation...',
              isError: false);
          if (mounted) Navigator.of(context).pop();
        } else if (state is CompanyError) {
          context.showSnackBarMessage(state.message, isError: true);
          setState(() => isSubmitting = false);
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Invite Users to Company",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ..._users.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: item.emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: CheckboxListTile(
                            title: const Text("Admin"),
                            contentPadding: EdgeInsets.zero,
                            value: item.isAdmin,
                            onChanged: (val) {
                              setState(() => item.isAdmin = val ?? false);
                            },
                          ),
                        ),
                        if (_users.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () => _removeUserField(index),
                          ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addUserField,
                    icon: const Icon(Icons.add),
                    label: const Text("Add more users"),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _submitInvites,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        backgroundColor: Colors.deepOrange,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text("Send Invites"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InviteUserFormItem {
  final TextEditingController emailController = TextEditingController();
  bool isAdmin = false;
}
