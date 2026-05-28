import 'package:equatable/equatable.dart';
import 'package:cinteraction_vc/layers/data/dto/ai/ai_module_dto.dart';

abstract class AiState extends Equatable {
  const AiState();

  @override
  List<Object?> get props => [];
}

class AiInitial extends AiState {}

class AiLoading extends AiState {}

class AiLoaded extends AiState {
  final List<ModuleDto> modules;

  const AiLoaded({required this.modules});

  @override
  List<Object?> get props => [modules];
}

class AiError extends AiState {
  final String message;

  const AiError(this.message);

  @override
  List<Object?> get props => [message];
}
