import 'package:creapolis_app/domain/entities/workspace.dart';
import 'package:creapolis_app/presentation/widgets/workspace/role_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoleBadge Widget', () {
    Widget createWidget({
      required WorkspaceRole role,
      bool showIcon = true,
      double fontSize = 12,
      EdgeInsetsGeometry? padding,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: RoleBadge(
            role: role,
            showIcon: showIcon,
            fontSize: fontSize,
            padding: padding,
          ),
        ),
      );
    }

    testWidgets('should display owner role with correct text and icon', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(role: WorkspaceRole.owner));

      expect(find.text('Propietario'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should display admin role with correct text and icon', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(role: WorkspaceRole.admin));

      expect(find.text('Administrador'), findsOneWidget);
      expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
    });

    testWidgets('should display member role with correct text and icon', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(role: WorkspaceRole.member));

      expect(find.text('Miembro'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should display guest role with correct text and icon', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(role: WorkspaceRole.guest));

      expect(find.text('Invitado'), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should not show icon when showIcon is false', (tester) async {
      await tester.pumpWidget(
        createWidget(role: WorkspaceRole.owner, showIcon: false),
      );

      expect(find.text('Propietario'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('should show icon when showIcon is true', (tester) async {
      await tester.pumpWidget(
        createWidget(role: WorkspaceRole.owner, showIcon: true),
      );

      expect(find.text('Propietario'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should apply custom fontSize', (tester) async {
      await tester.pumpWidget(
        createWidget(role: WorkspaceRole.member, fontSize: 16),
      );

      final textWidget = tester.widget<Text>(find.text('Miembro'));
      expect(textWidget.style?.fontSize, 16);
    });

    testWidgets('should apply custom padding when provided', (tester) async {
      const customPadding = EdgeInsets.all(16);
      await tester.pumpWidget(
        createWidget(role: WorkspaceRole.admin, padding: customPadding),
      );

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              widget.padding == customPadding,
        ),
      );
      expect(container.padding, customPadding);
    });

    testWidgets('should use default padding when not provided', (tester) async {
      await tester.pumpWidget(createWidget(role: WorkspaceRole.member));

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration,
        ),
      );
      expect(
        container.padding,
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      );
    });

    testWidgets('should have correct color for owner role', (tester) async {
      await tester.pumpWidget(createWidget(role: WorkspaceRole.owner));

      // Owner should be red
      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, Colors.red);
    });

    testWidgets('should have correct color for admin role', (tester) async {
      await tester.pumpWidget(createWidget(role: WorkspaceRole.admin));

      // Admin should be orange
      final icon = tester.widget<Icon>(find.byIcon(Icons.admin_panel_settings));
      expect(icon.color, Colors.orange);
    });

    testWidgets('should have correct color for member role', (tester) async {
      await tester.pumpWidget(createWidget(role: WorkspaceRole.member));

      // Member should be green
      final icon = tester.widget<Icon>(find.byIcon(Icons.person));
      expect(icon.color, Colors.green);
    });

    testWidgets('should have correct color for guest role', (tester) async {
      await tester.pumpWidget(createWidget(role: WorkspaceRole.guest));

      // Guest should be grey
      final icon = tester.widget<Icon>(find.byIcon(Icons.visibility));
      expect(icon.color, Colors.grey);
    });

    testWidgets('should have rounded border', (tester) async {
      await tester.pumpWidget(createWidget(role: WorkspaceRole.member));

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('should have border with role color', (tester) async {
      await tester.pumpWidget(createWidget(role: WorkspaceRole.owner));

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration,
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      // Owner color is red
      expect(border.top.color, Colors.red.withValues(alpha: 0.3));
    });

    testWidgets('should display all role types correctly', (tester) async {
      final roles = [
        (WorkspaceRole.owner, 'Propietario', Icons.star),
        (WorkspaceRole.admin, 'Administrador', Icons.admin_panel_settings),
        (WorkspaceRole.member, 'Miembro', Icons.person),
        (WorkspaceRole.guest, 'Invitado', Icons.visibility),
      ];

      for (final (role, displayName, icon) in roles) {
        await tester.pumpWidget(createWidget(role: role));
        expect(find.text(displayName), findsOneWidget);
        expect(find.byIcon(icon), findsOneWidget);
        await tester.pumpWidget(Container()); // Clear widget tree
      }
    });

    testWidgets('should have bold text style', (tester) async {
      await tester.pumpWidget(createWidget(role: WorkspaceRole.member));

      final textWidget = tester.widget<Text>(find.text('Miembro'));
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });
  });
}



