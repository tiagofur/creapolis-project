import 'package:dartz/dartz.dart';
import '../../domain/entities/form_entity.dart';
import '../../core/errors/failures.dart';

abstract class FormRepository {
  /// Get all forms for a project
  Future<Either<Failure, List<FormEntity>>> getFormsByProject(int projectId);

  /// Get form by ID
  Future<Either<Failure, FormEntity>> getFormById(int formId);

  /// Get form by public link (no auth)
  Future<Either<Failure, FormEntity>> getFormByPublicLink(String publicLink);

  /// Create a new form
  Future<Either<Failure, FormEntity>> createForm({
    required int projectId,
    required String title,
    String? description,
    required List<FormField> fields,
    required FormSettings settings,
  });

  /// Update form
  Future<Either<Failure, FormEntity>> updateForm({
    required int formId,
    String? title,
    String? description,
    bool? isActive,
    List<FormField>? fields,
    FormSettings? settings,
  });

  /// Delete form
  Future<Either<Failure, void>> deleteForm(int formId);

  /// Submit form (public, no auth)
  Future<Either<Failure, Map<String, dynamic>>> submitForm({
    required String publicLink,
    required Map<String, dynamic> data,
  });

  /// Get submissions for a form
  Future<Either<Failure, Map<String, dynamic>>> getFormSubmissions({
    required int formId,
    int page = 1,
    int limit = 20,
    bool includeTask = false,
  });

  /// Get form analytics
  Future<Either<Failure, Map<String, dynamic>>> getFormAnalytics(int formId);
}
