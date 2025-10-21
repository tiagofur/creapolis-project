import 'package:flutter_test/flutter_test.dart';
import 'package:creapolis_app/data/models/project_model.dart';
import 'package:creapolis_app/domain/entities/project.dart';

void main() {
  group('ProjectModel', () {
    test('fromJson parses new project fields correctly', () {
      final json = {
        'id': 101,
        'name': 'Inception Gateway',
        'description': 'Exploración de nuevos mercados',
        'status': 'ACTIVE',
        'startDate': '2024-03-01T12:00:00.000Z',
        'endDate': '2024-06-01T18:00:00.000Z',
        'managerId': 42,
        'managerName': 'Laura Méndez',
        'workspaceId': 7,
        'createdAt': '2024-02-20T08:30:00.000Z',
        'updatedAt': '2024-02-25T09:15:00.000Z',
      };

      final model = ProjectModel.fromJson(json);

      expect(model.id, 101);
      expect(model.name, 'Inception Gateway');
      expect(model.description, 'Exploración de nuevos mercados');
      expect(model.status, ProjectStatus.active);
      expect(
        model.startDate.toUtc().toIso8601String(),
        '2024-03-01T12:00:00.000Z',
      );
      expect(
        model.endDate.toUtc().toIso8601String(),
        '2024-06-01T18:00:00.000Z',
      );
      expect(model.managerId, 42);
      expect(model.managerName, 'Laura Méndez');
      expect(model.workspaceId, 7);
      expect(
        model.createdAt.toUtc().toIso8601String(),
        '2024-02-20T08:30:00.000Z',
      );
      expect(
        model.updatedAt.toUtc().toIso8601String(),
        '2024-02-25T09:15:00.000Z',
      );
    });

    test(
      'fromJson infers manager info and workspaceId from nested objects',
      () {
        final json = {
          'id': 202,
          'name': 'Horizon Build',
          'description': 'Infraestructura para clientes enterprise',
          'status': 'PLANNED',
          'startDate': '2024-04-10T09:00:00.000Z',
          'endDate': '2024-07-15T17:00:00.000Z',
          'workspace': {'id': 11},
          'manager': {'id': 77, 'name': 'Mario Flores'},
          'createdAt': '2024-03-01T07:00:00.000Z',
          'updatedAt': '2024-03-05T10:00:00.000Z',
        };

        final model = ProjectModel.fromJson(json);

        expect(model.workspaceId, 11);
        expect(model.managerId, 77);
        expect(model.managerName, 'Mario Flores');
        expect(model.status, ProjectStatus.planned);
      },
    );

    test('toJson exports new fields in API format', () {
      final project = ProjectModel(
        id: 303,
        name: 'Aurora Labs',
        description: 'Investigación y prototipos',
        status: ProjectStatus.paused,
        startDate: DateTime.parse('2024-01-05T10:00:00.000Z').toLocal(),
        endDate: DateTime.parse('2024-02-20T15:30:00.000Z').toLocal(),
        managerId: 55,
        managerName: 'Daniela Ramírez',
        workspaceId: 4,
        createdAt: DateTime.parse('2023-12-15T08:00:00.000Z').toLocal(),
        updatedAt: DateTime.parse('2024-01-10T12:45:00.000Z').toLocal(),
      );

      final json = project.toJson();

      expect(json['status'], 'PAUSED');
      expect(
        DateTime.parse(json['startDate'] as String).toUtc().toIso8601String(),
        '2024-01-05T10:00:00.000Z',
      );
      expect(
        DateTime.parse(json['endDate'] as String).toUtc().toIso8601String(),
        '2024-02-20T15:30:00.000Z',
      );
      expect(json['managerId'], 55);
      expect(json['managerName'], 'Daniela Ramírez');
    });
  });
}
