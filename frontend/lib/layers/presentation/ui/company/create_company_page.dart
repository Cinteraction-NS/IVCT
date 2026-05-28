import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/ui/images/image.dart';
import 'package:cinteraction_vc/core/util/secure_local_storage.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/company/company_state.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/company/company_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/route.dart';

class CreateCompanyPage extends StatefulWidget {
  const CreateCompanyPage({super.key});

  @override
  State<CreateCompanyPage> createState() => _CreateCompanyPageState();
}

class _CreateCompanyPageState extends State<CreateCompanyPage> {
  final TextEditingController _nameController = TextEditingController();

  void _submit() async {
    final name = _nameController.text.trim();
    final user = context.getCurrentUser;

    if (name.isEmpty) {
      _showMessage("Company name is required");
      return;
    }

    context.read<CompanyCubit>().createCompany(
          ownerId: int.parse(user!.id),
          name: name,
        );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.maxFinite,
          alignment: Alignment.centerLeft,
          child: imageSVGAsset('original_long_logo'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<CompanyCubit, CompanyState>(
        listener: (context, state) {
          print('stateCompany: $state');
          if (state is CompanyError) {
            _showMessage(state.message);
          } else if (state is CompanySuccess) {
            context.go(AppRoute.home.path);
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Welcome to Cinteraction!",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Let’s start by creating your company profile.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Company Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<CompanyCubit, CompanyState>(
                          builder: (context, state) {
                            final isLoading = state is CompanyLoading;
                            return ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text("Create Company"),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          context.logOut();
                          // context.go(AppRoute.auth.path);
                        },
                        child: const Text(" <- Back to Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
