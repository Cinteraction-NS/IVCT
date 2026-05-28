import 'package:cinteraction_vc/layers/domain/repos/company_repo.dart';
import 'package:cinteraction_vc/layers/domain/source/api.dart';

class CompanyRepoImpl extends CompanyRepo {
  final Api _api;

  CompanyRepoImpl({required Api api}) : _api = api;

  @override
  Future<void> createCompany({
    required int ownerId,
    required String name,
  }) async {
    try {
      final response = await _api.createCompany(
        name: name,
        ownerId: ownerId,
      );

      if (response.error != null) {
        throw Exception(response.error);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteCompany({required companyId}) async {
    try {
      final response = await _api.deleteCompany(companyId: companyId);
      if (response.error != null) {
        throw Exception(response.error);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeUserFromCompany({
    required int companyId,
    required int userId,
  }) async {
    final response =
        await _api.removeUserFromCompany(companyId: companyId, userId: userId);

    if (response.error != null) {
      throw Exception(response.error);
    }
  }

  @override
  Future<void> inviteUserToCompany({
    required int companyId,
    required String email,
    required bool isAdmin,
  }) async {
    final response = await _api.inviteUserToCompany(
      companyId: companyId,
      email: email,
      isAdmin: isAdmin,
    );

    if (response.error != null) {
      throw Exception(response.error!);
    }
  }
}
