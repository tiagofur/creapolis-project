import 'package:equatable/equatable.dart';
import '../../domain/entities/form_entity.dart';

enum FormStatus { initial, loading, loaded, success, error }

class FormState extends Equatable {
  final FormStatus status;
  final List<FormEntity> forms;
  final FormEntity? selectedForm;
  final String? errorMessage;

  const FormState({
    this.status = FormStatus.initial,
    this.forms = const [],
    this.selectedForm,
    this.errorMessage,
  });

  FormState copyWith({
    FormStatus? status,
    List<FormEntity>? forms,
    FormEntity? selectedForm,
    String? errorMessage,
  }) {
    return FormState(
      status: status ?? this.status,
      forms: forms ?? this.forms,
      selectedForm: selectedForm ?? this.selectedForm,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, forms, selectedForm, errorMessage];
}
