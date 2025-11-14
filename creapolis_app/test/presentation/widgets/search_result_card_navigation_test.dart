import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:creapolis_app/features/search/presentation/widgets/search_result_card.dart';
import 'package:creapolis_app/domain/entities/search_result.dart';

// Removed LastRouteService fallback; using workspace in metadata

Widget _routerShell(Widget child) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: Center(child: child)),
      ),
      GoRoute(
        path: '/more/profile',
        builder: (context, state) => const Text('Profile', key: Key('profile')), 
      ),
      GoRoute(
        path: '/more/workspaces/:wId/projects/:pId',
        builder: (context, state) => const Text('ProjectDetail', key: Key('project_detail')),
      ),
      GoRoute(
        path: '/more/workspaces/:wId/projects/:pId/tasks/:tId',
        builder: (context, state) => const Text('TaskDetail', key: Key('task_detail')),
      ),
    ],
    initialLocation: '/',
  );

  return MaterialApp.router(routerConfig: router);
}

void main() {
  setUp(() {});

  testWidgets('SearchResultCard navigates to task detail', (tester) async {
    final result = SearchResult(
      id: '10',
      type: 'task',
      title: 'Task X',
      relevance: 90,
      metadata: {
        'project': {'id': 5},
        'workspace': {'id': 2},
      },
    );

    final widget = _routerShell(SearchResultCard(result: result));
    await tester.pumpWidget(widget);
    await tester.tap(find.byType(SearchResultCard));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('task_detail')), findsOneWidget);
  });

  testWidgets('SearchResultCard navigates to project detail when workspace provided', (tester) async {
    final result = SearchResult(
      id: '5',
      type: 'project',
      title: 'Project Y',
      relevance: 80,
      metadata: {
        'workspace': {'id': 3},
      },
    );

    final widget = _routerShell(SearchResultCard(result: result));
    await tester.pumpWidget(widget);
    await tester.tap(find.byType(SearchResultCard));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('project_detail')), findsOneWidget);
  });
}
