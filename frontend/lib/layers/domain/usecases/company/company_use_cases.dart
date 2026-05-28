import 'package:cinteraction_vc/layers/domain/repos/company_repo.dart';

class CompanyUseCases {
  final CompanyRepo companyRepos;

  CompanyUseCases({required this.companyRepos});

  Future<void> createCompany({
    required int ownerId,
    required String name,
  }) {
    return companyRepos.createCompany(
      ownerId: ownerId,
      name: name,
    );
  }

  Future<void> deleteCompany({
    required int companyId,
  }) {
    return companyRepos.deleteCompany(companyId: companyId);
  }

  Future<void> removeUserFromCompany(
      {required int companyId, required int userId}) {
    return companyRepos.removeUserFromCompany(
        companyId: companyId, userId: userId);
  }

  Future<void> inviteUserToCompany({
    required int companyId,
    required String email,
    required bool isAdmin,
  }) {
    return companyRepos.inviteUserToCompany(
      companyId: companyId,
      email: email,
      isAdmin: isAdmin,
    );
  }
}
