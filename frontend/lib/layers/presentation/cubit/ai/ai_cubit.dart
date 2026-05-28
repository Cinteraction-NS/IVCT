import 'dart:async';

import 'package:cinteraction_vc/layers/presentation/cubit/app/app_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinteraction_vc/layers/domain/usecases/ai/ai_use_cases.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/ai/ai_state.dart';
import 'package:cinteraction_vc/core/logger/loggy_types.dart';

class AiCubit extends Cubit<AiState> with BlocLoggy {
  final AiUseCases aiUseCases;
  final AppCubit appCubit;
  StreamSubscription? _subscription;

  AiCubit({required this.aiUseCases, required this.appCubit})
      : super(AiInitial());

  Future<void> load({required int companyId}) async {
    emit(AiLoading());

    _subscription = aiUseCases.getAiModuleStream().listen((response) {
      emit(AiLoaded(modules: response.modules));
    });

    await aiUseCases.getAiModules(companyId: companyId);
  }

  Future<void> addModule({
    required int companyId,
    required String name,
    required String url,
    required int enabled,
  }) async {
    emit(AiLoading());
    try {
      await aiUseCases.addAiModule(
        companyId: companyId,
        aiModuleName: name,
        aiModuleUrl: url,
        enabled: enabled,
      );
      await load(companyId: companyId);

      await appCubit.fetchAndUpdateUser();
    } catch (e) {
      emit(const AiError('Failed to add module.'));
    }
  }

  Future<void> updateModule({
    required int moduleId,
    required int companyId,
    required String name,
    required String url,
    required int enabled,
    required int isGlobal,
  }) async {
    emit(AiLoading());
    try {
      await aiUseCases.updateModule(
          moduleId: moduleId,
          companyId: companyId,
          aiModuleName: name,
          aiModuleUrl: url,
          enabled: enabled,
          isGlobal: isGlobal);
      await load(companyId: companyId);

      await appCubit.fetchAndUpdateUser();
    } catch (e) {
      emit(const AiError('Failed to update module.'));
    }
  }

  Future<void> deleteModule(
      {required int moduleId, required int companyId}) async {
    emit(AiLoading());
    try {
      await aiUseCases.deleteModule(moduleId: moduleId, companyId: companyId);
      await load(companyId: companyId);

      await appCubit.fetchAndUpdateUser();
    } catch (e) {
      emit(const AiError('Failed to delete module.'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
