abstract class CompanyState {}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanySuccess extends CompanyState {}

class CompanyError extends CompanyState {
  final String message;
  CompanyError(this.message);
}
