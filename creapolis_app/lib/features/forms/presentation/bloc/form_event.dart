import 'package:equatable/equatable.dart';
import '../../domain/entities/form_entity.dart';

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
}

class GetFormsByProjectEvent extends FormEvent {
  final int projectId;

  const GetFormsByProjectEvent(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class GetFormByIdEvent extends FormEvent {
  final int formId;

  const GetFormByIdEvent(this.formId);

  @override
  List<Object?> get props => [formId];
}

class CreateFormEvent extends FormEvent {
  final int projectId;
  final String title;
  final String? description;
  final FormConfig config;

  const CreateFormEvent({
    required this.projectId,
    required this.title,
    this.description,
    required this.config,
  });

  @override
  List<Object?> get props => [projectId, title, description, config];
}

class UpdateFormEvent extends FormEvent {
  final int formId;
  final String? title;
  final String? description;
  final FormConfig? config;
  final bool? isActive;

  const UpdateFormEvent({
    required this.formId,
    this.title,
    this.description,
    this.config,
    this.isActive,
  });

  @override
  List<Object?> get props => [formId, title, description, config, isActive];
}

class DeleteFormEvent extends FormEvent {
  final int formId;

  const DeleteFormEvent(this.formId);

  @override
  List<Object?> get props => [formId];
}

class GetPublicFormEvent extends FormEvent {
  final String publicLink;

  const GetPublicFormEvent(this.publicLink);

  @override
  List<Object?> get props => [publicLink];
}

class SubmitPublicFormEvent extends FormEvent {
  final String publicLink;
  final Map<String, dynamic> data;

  const SubmitPublicFormEvent({required this.publicLink, required this.data});

  @override
  List<Object?> get props => [publicLink, data];
}
