import 'package:bloc_test/bloc_test.dart';
import 'package:creapolis_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:creapolis_app/presentation/bloc/auth/auth_event.dart';
import 'package:creapolis_app/presentation/bloc/auth/auth_state.dart';
import 'package:creapolis_app/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginScreen(),
      ),
    );
  }

  testWidgets('LoginScreen renders correctly', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for animations to finish

    expect(find.text('Creapolis'), findsOneWidget);
    expect(find.text('Gestión de Proyectos Urbanos'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Regístrate'), findsOneWidget);
  });

  testWidgets('Shows loading indicator when state is AuthLoading', (
    tester,
  ) async {
    when(() => mockAuthBloc.state).thenReturn(AuthLoading());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Start animations
    // We don't pumpAndSettle here because the loading indicator is an infinite animation
    // But we need to advance enough to show the initial widgets if they are animated
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsNothing);
  });

  testWidgets('Shows error snackbar when state is AuthError', (tester) async {
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([const AuthError('Error de prueba')]),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for initial animations

    expect(find.text('Error de prueba'), findsOneWidget);
  });
}
