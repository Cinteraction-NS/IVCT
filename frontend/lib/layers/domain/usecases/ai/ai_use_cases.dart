import 'package:cinteraction_vc/layers/data/dto/ai/ai_module_dto.dart';
import 'package:cinteraction_vc/layers/domain/repos/ai_repo.dart';

class AiUseCases {
  final AiRepo aiRepos;

  AiUseCases({required this.aiRepos});

  Future<void> getAiModules({required int companyId}) {
    return aiRepos.getAiModules(
      companyId: companyId,
    );
  }

  Future<void> addAiModule({
    required int companyId,
    required String aiModuleName,
    required String aiModuleUrl,
    required int enabled,
  }) {
    return aiRepos.addAiModule(
      companyId: companyId,
      aiModuleName: aiModuleName,
      aiModuleUrl: aiModuleUrl,
      enabled: enabled,
    );
  }

  Future<void> updateModule({
    required int moduleId,
    required int companyId,
    required String aiModuleName,
    required String aiModuleUrl,
    required int enabled,
    required int isGlobal,
  }) {
    return aiRepos.updateModule(
        moduleId: moduleId,
        companyId: companyId,
        aiModuleName: aiModuleName,
        aiModuleUrl: aiModuleUrl,
        enabled: enabled,
        isGlobal: isGlobal);
  }

  Future<void> deleteModule({required int moduleId, required int companyId}) {
    return aiRepos.deleteAiModule(moduleId: moduleId, companyId: companyId);
  }

  Stream<ModuleListResponse> getAiModuleStream() {
    return aiRepos.getAiModuleStream();
  }

  // Future<void> addAiModule({
  //   required String aiModuleName,
  //   required String aiModuleUrl,
  // }) {
  //   return aiRepos.addAiModule(
  //       aiModuleName: aiModuleName, aiModuleUrl: aiModuleUrl);
  // }

  // Future<void> deleteAiModule({
  //   required int aiModuleId,
  // }) {
  //   return aiRepos.deleteAiModule(aiModuleId: aiModuleId);
  // }
}
