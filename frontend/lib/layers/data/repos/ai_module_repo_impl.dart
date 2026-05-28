import 'dart:async';

import 'package:cinteraction_vc/layers/data/dto/ai/ai_module_dto.dart';
import 'package:cinteraction_vc/layers/domain/repos/ai_repo.dart';
import 'package:cinteraction_vc/layers/domain/source/api.dart';

class AiModuleRepoImpl extends AiRepo {
  AiModuleRepoImpl({required Api api}) : _api = api;
  final Api _api;

  final _aiModulesStream = StreamController<ModuleListResponse>.broadcast();

  @override
  Stream<ModuleListResponse> getAiModuleStream() {
    return _aiModulesStream.stream;
  }

  @override
  Future<void> getAiModules({required int companyId}) async {
    try {
      var response = await _api.getCompanyModules(companyId: companyId);
      if (response.error == null && response.response != null) {
        _aiModulesStream.add(response.response!);
      } else {
        print("Error: ${response.error}");
      }
    } catch (e) {
      print("Error while fetching chat: $e");
    }
  }

  @override
  Future<void> addAiModule({
    required int companyId,
    required String aiModuleName,
    required String aiModuleUrl,
    required int enabled,
  }) async {
    try {
      final response = await _api.addAiModule(
        companyId: companyId,
        aiModuleName: aiModuleName,
        aiModuleUrl: aiModuleUrl,
        enabled: enabled,
      );

      if (response.error == null && response.response != null) {
        _aiModulesStream.add(response.response!);
      } else {
        print("Add module error: ${response.error}");
      }
    } catch (e) {
      // print("Exception in addAiModule: $e");
    }
  }

  @override
  Future<void> updateModule({
    required int moduleId,
    required int companyId,
    required String aiModuleName,
    required String aiModuleUrl,
    required int enabled,
    required int isGlobal,
  }) async {
    try {
      final response = await _api.updateModule(
        moduleId: moduleId,
        companyId: companyId,
        aiModuleName: aiModuleName,
        aiModuleUrl: aiModuleUrl,
        enabled: enabled,
        isGlobal: isGlobal,
      );
      if (response.error == null && response.response != null) {
        _aiModulesStream.add(response.response!);
      } else {
        print("Update module error: ${response.error}");
      }
    } catch (e) {
      // print("Exception in updateAiModule: $e");
    }
  }

  @override
  Future<void> deleteAiModule(
      {required int moduleId, required int companyId}) async {
    try {
      final response =
          await _api.deleteAiModule(moduleId: moduleId, companyId: companyId);

      if (response.error == null && response.response != null) {
        _aiModulesStream.add(response.response!);
      } else {
        print("Delete module error: ${response.error}");
      }
    } catch (e) {
      // print("Exception in deleteAiModule: $e");
    }
  }
}
