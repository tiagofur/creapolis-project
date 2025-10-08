import 'package:flutter_test/flutter_test.dart';

import 'package:creapolis_app/data/models/time_log_model.dart';

void main() {
  group('TimeLogModel.fromJson', () {
    test('parses backend response with duration in hours', () {
      final json = {
        'id': 1,
        'taskId': 2,
        'userId': 3,
        'startTime': '2025-10-08T20:55:52.495Z',
        'endTime': '2025-10-08T21:55:52.495Z',
        'duration': 1.5,
        'createdAt': '2025-10-08T20:55:52.497Z',
        'updatedAt': '2025-10-08T21:55:52.497Z',
        'user': {'id': 3, 'name': 'Test User', 'email': 'test@example.com'},
      };

      final model = TimeLogModel.fromJson(json);

      expect(model.id, 1);
      expect(model.taskId, 2);
      expect(model.userId, 3);
      expect(model.durationInSeconds, 5400);
      expect(model.startTime.toIso8601String(), '2025-10-08T20:55:52.495Z');
      expect(model.endTime?.toIso8601String(), '2025-10-08T21:55:52.495Z');
    });

    test('supports alternate key styles and duration in seconds', () {
      final json = {
        'id': '5',
        'task_id': 7,
        'start_time': '2025-10-08T20:55:52.495Z',
        'created_at': '2025-10-08T20:55:52.497Z',
        'updated_at': '2025-10-08T20:56:52.497Z',
        'duration_in_seconds': 1200,
      };

      final model = TimeLogModel.fromJson(json);

      expect(model.id, 5);
      expect(model.taskId, 7);
      expect(model.userId, isNull);
      expect(model.durationInSeconds, 1200);
      expect(model.endTime, isNull);
    });

    test(
      'parses active time log payload with nested task and null duration',
      () {
        final json = {
          'id': 42,
          'taskId': 2,
          'task': {
            'id': 2,
            'title': 'hacer proyectos',
            'status': 'IN_PROGRESS',
            'project': {'id': 5, 'name': 'Ingenieria Abitalia'},
          },
          'user': {'id': 17, 'name': 'Tester'},
          'startTime': '2025-10-08T20:55:52.495Z',
          'endTime': null,
          'duration': null,
          'createdAt': '2025-10-08T20:55:52.497Z',
          'updatedAt': '2025-10-08T20:55:52.497Z',
        };

        final model = TimeLogModel.fromJson(json);

        expect(model.id, 42);
        expect(model.taskId, 2);
        expect(model.userId, 17);
        expect(model.durationInSeconds, isNull);
        expect(model.endTime, isNull);
      },
    );
  });

  group('TimeLogModel.toJson', () {
    test('includes both duration units when available', () {
      final model = TimeLogModel(
        id: 10,
        taskId: 20,
        userId: 30,
        startTime: DateTime.parse('2025-10-08T20:55:52.495Z'),
        endTime: DateTime.parse('2025-10-08T22:55:52.495Z'),
        durationInSeconds: 3600,
        createdAt: DateTime.parse('2025-10-08T20:55:52.497Z'),
        updatedAt: DateTime.parse('2025-10-08T21:55:52.497Z'),
      );

      final json = model.toJson();

      expect(json['id'], 10);
      expect(json['taskId'], 20);
      expect(json['userId'], 30);
      expect(json['startTime'], '2025-10-08T20:55:52.495Z');
      expect(json['endTime'], '2025-10-08T22:55:52.495Z');
      expect(json['durationInSeconds'], 3600);
      expect(json['duration'], closeTo(1.0, 1e-9));
      expect(json['createdAt'], '2025-10-08T20:55:52.497Z');
      expect(json['updatedAt'], '2025-10-08T21:55:52.497Z');
    });
  });
}
