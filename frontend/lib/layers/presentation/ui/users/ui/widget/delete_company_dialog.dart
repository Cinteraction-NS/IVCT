import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/company/company_cubit.dart';

class DeleteCompanyDialog extends StatelessWidget {
  const DeleteCompanyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Company'),
      content: const Text(
        'Are you sure you want to delete the company?',
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
          onPressed: () {
            context
                .read<CompanyCubit>()
                .deleteCompany(companyId: context.getCurrentUser!.companyId!);
            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
