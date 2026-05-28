import 'package:cinteraction_vc/layers/data/dto/ai/ai_module_dto.dart';

abstract class AiRepo {
  const AiRepo();

  Stream<ModuleListResponse> getAiModuleStream();

  Future<void> deleteAiModule({
    required int moduleId,
    required int companyId,
  });

  Future<void> addAiModule({
    required int companyId,
    required String aiModuleName,
    required String aiModuleUrl,
    required int enabled,
  });

  Future<void> getAiModules({
    required int companyId,
  });

  Future<void> updateModule({
    required int moduleId,
    required int companyId,
    required String aiModuleName,
    required String aiModuleUrl,
    required int enabled,
    required int isGlobal,
  });
}
