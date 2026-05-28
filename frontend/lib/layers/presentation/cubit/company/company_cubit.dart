import 'package:cinteraction_vc/core/logger/loggy_types.dart';
import 'package:cinteraction_vc/layers/domain/usecases/company/company_use_cases.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/app/app_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/company/company_state.dart';
import 'package:cinteraction_vc/layers/presentation/ui/users/ui/widget/invite_users_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompanyCubit extends Cubit<CompanyState> with BlocLoggy {
  final CompanyUseCases companyUseCases;
  final AppCubit appCubit;

  CompanyCubit({
    required this.companyUseCases,
    required this.appCubit,
  }) : super(CompanyInitial());

  Future<void> createCompany({
    required int ownerId,
    required String name,
  }) async {
    emit(CompanyLoading());

    try {
      await companyUseCases.createCompany(
        ownerId: ownerId,
        name: name,
      );

      await appCubit.fetchAndUpdateUser();

      emit(CompanySuccess());
    } catch (e, stack) {
      loggy.error("Failed to create company", e, stack);
      emit(CompanyError("Error: ${e.toString()}"));
    }
  }

  Future<void> deleteCompany({
    required int companyId,
  }) async {
    try {
      await companyUseCases.deleteCompany(companyId: companyId);
      await appCubit.fetchAndUpdateUser();
    } catch (e, stack) {
      loggy.error("Failed to create company", e, stack);
      emit(CompanyError("Error: ${e.toString()}"));
    }
  }

  Future<void> removeUserFromCompany({
    required int companyId,
    required int userId,
  }) async {
    try {
      await companyUseCases.removeUserFromCompany(
          companyId: companyId, userId: userId);
      emit(CompanyInitial());
    } catch (e, stack) {
      loggy.error("Failed to remove user from company", e, stack);
      emit(CompanyError("Error: ${e.toString()}"));
    }
  }

  Future<void> inviteMultipleUsers({
    required int companyId,
    required List<InviteUserModel> users,
  }) async {
    emit(CompanyLoading());

    try {
      for (final user in users) {
        await companyUseCases.inviteUserToCompany(
          companyId: companyId,
          email: user.email,
          isAdmin: user.isAdmin,
        );
      }

      emit(CompanySuccess());
    } catch (e, stack) {
      loggy.error("Failed to invite users", e, stack);
      emit(CompanyError("There is error: ${e.toString()}"));
    }
  }
}
