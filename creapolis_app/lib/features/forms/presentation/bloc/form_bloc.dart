import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/create_form.dart';
import '../../domain/usecases/delete_form.dart';
import '../../domain/usecases/get_form_by_id.dart';
import '../../domain/usecases/get_forms_by_project.dart';
import '../../domain/usecases/get_public_form.dart';
import '../../domain/usecases/submit_public_form.dart';
import '../../domain/usecases/update_form.dart';
import 'form_event.dart';
import 'form_state.dart';

@injectable
class FormBloc extends Bloc<FormEvent, FormState> {
  final GetFormsByProject getFormsByProject;
  final GetFormById getFormById;
  final CreateForm createForm;
  final UpdateForm updateForm;
  final DeleteForm deleteForm;
  final GetPublicForm getPublicForm;
  final SubmitPublicForm submitPublicForm;

  FormBloc({
    required this.getFormsByProject,
    required this.getFormById,
    required this.createForm,
    required this.updateForm,
    required this.deleteForm,
    required this.getPublicForm,
    required this.submitPublicForm,
  }) : super(const FormState()) {
    on<GetFormsByProjectEvent>(_onGetFormsByProject);
    on<GetFormByIdEvent>(_onGetFormById);
    on<CreateFormEvent>(_onCreateForm);
    on<UpdateFormEvent>(_onUpdateForm);
    on<DeleteFormEvent>(_onDeleteForm);
    on<GetPublicFormEvent>(_onGetPublicForm);
    on<SubmitPublicFormEvent>(_onSubmitPublicForm);
  }

  Future<void> _onGetFormsByProject(
    GetFormsByProjectEvent event,
    Emitter<FormState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading));
    final result = await getFormsByProject(event.projectId);
    result.fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.error, errorMessage: failure.message),
      ),
      (forms) => emit(state.copyWith(status: FormStatus.loaded, forms: forms)),
    );
  }

  Future<void> _onGetFormById(
    GetFormByIdEvent event,
    Emitter<FormState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading));
    final result = await getFormById(event.formId);
    result.fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.error, errorMessage: failure.message),
      ),
      (form) =>
          emit(state.copyWith(status: FormStatus.loaded, selectedForm: form)),
    );
  }

  Future<void> _onCreateForm(
    CreateFormEvent event,
    Emitter<FormState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading));
    final result = await createForm(
      CreateFormParams(
        projectId: event.projectId,
        title: event.title,
        description: event.description,
        config: event.config,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.error, errorMessage: failure.message),
      ),
      (form) {
        final updatedForms = List.of(state.forms)..add(form);
        emit(
          state.copyWith(
            status: FormStatus.success,
            forms: updatedForms,
            selectedForm: form,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateForm(
    UpdateFormEvent event,
    Emitter<FormState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading));
    final result = await updateForm(
      UpdateFormParams(
        formId: event.formId,
        title: event.title,
        description: event.description,
        config: event.config,
        isActive: event.isActive,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.error, errorMessage: failure.message),
      ),
      (form) {
        final updatedForms = state.forms
            .map((f) => f.id == form.id ? form : f)
            .toList();
        emit(
          state.copyWith(
            status: FormStatus.success,
            forms: updatedForms,
            selectedForm: form,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteForm(
    DeleteFormEvent event,
    Emitter<FormState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading));
    final result = await deleteForm(event.formId);
    result.fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.error, errorMessage: failure.message),
      ),
      (_) {
        final updatedForms = state.forms
            .where((f) => f.id != event.formId)
            .toList();
        emit(
          state.copyWith(
            status: FormStatus.success,
            forms: updatedForms,
            selectedForm: null,
          ),
        );
      },
    );
  }

  Future<void> _onGetPublicForm(
    GetPublicFormEvent event,
    Emitter<FormState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading));
    final result = await getPublicForm(event.publicLink);
    result.fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.error, errorMessage: failure.message),
      ),
      (form) =>
          emit(state.copyWith(status: FormStatus.loaded, selectedForm: form)),
    );
  }

  Future<void> _onSubmitPublicForm(
    SubmitPublicFormEvent event,
    Emitter<FormState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading));
    final result = await submitPublicForm(
      SubmitPublicFormParams(publicLink: event.publicLink, data: event.data),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: FormStatus.error, errorMessage: failure.message),
      ),
      (_) => emit(state.copyWith(status: FormStatus.success)),
    );
  }
}
