import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/features/workspace/data/models/workspace_model.dart';
import 'package:creapolis_app/domain/entities/workspace_invitation.dart';
import 'package:creapolis_app/domain/repositories/workspace_repository.dart';
import 'package:creapolis_app/domain/usecases/workspace/create_invitation.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_invitation_test.mocks.dart';

@GenerateMocks([WorkspaceRepository])
void main() {
  late CreateInvitationUseCase usecase;
  late MockWorkspaceRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkspaceRepository();
    usecase = CreateInvitationUseCase(mockRepository);
  });

  final tParams = CreateInvitationParams(
    workspaceId: 1,
    email: 'newmember@example.com',
    role: WorkspaceRole.member,
  );

  final tInvitation = WorkspaceInvitation(
    id: 1,
    workspaceId: 1,
    workspaceName: 'Test Workspace',
    workspaceType: WorkspaceType.team,
    inviterName: 'John Doe',
    inviterEmail: 'john@example.com',
    inviteeEmail: 'newmember@example.com',
    role: WorkspaceRole.member,
    token: 'invitation_token_xyz',
    status: InvitationStatus.pending,
    expiresAt: DateTime.now().add(const Duration(days: 7)),
    createdAt: DateTime(2024, 1, 1),
  );

  group('CreateInvitation', () {
    test(
      'should create invitation successfully and return invitation object',
      () async {
        // arrange
        when(
          mockRepository.createInvitation(
            workspaceId: anyNamed('workspaceId'),
            email: anyNamed('email'),
            role: anyNamed('role'),
          ),
        ).thenAnswer((_) async => Right(tInvitation));

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, Right(tInvitation));
        verify(
          mockRepository.createInvitation(
            workspaceId: 1,
            email: 'newmember@example.com',
            role: WorkspaceRole.member,
          ),
        );
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return ValidationFailure when email is invalid', () async {
      // arrange
      final invalidParams = CreateInvitationParams(
        workspaceId: 1,
        email: 'invalid-email',
        role: WorkspaceRole.member,
      );

      when(
        mockRepository.createInvitation(
          workspaceId: anyNamed('workspaceId'),
          email: anyNamed('email'),
          role: anyNamed('role'),
        ),
      ).thenAnswer(
        (_) async => Left(ValidationFailure('Invalid email format')),
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(result, Left(ValidationFailure('Invalid email format')));
      verify(
        mockRepository.createInvitation(
          workspaceId: 1,
          email: 'invalid-email',
          role: WorkspaceRole.member,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return ValidationFailure when user is already a member',
      () async {
        // arrange
        when(
          mockRepository.createInvitation(
            workspaceId: anyNamed('workspaceId'),
            email: anyNamed('email'),
            role: anyNamed('role'),
          ),
        ).thenAnswer(
          (_) async => Left(
            ValidationFailure('User is already a member of this workspace'),
          ),
        );

        // act
        final result = await usecase(tParams);

        // assert
        expect(
          result,
          Left(ValidationFailure('User is already a member of this workspace')),
        );
        verify(
          mockRepository.createInvitation(
            workspaceId: 1,
            email: 'newmember@example.com',
            role: WorkspaceRole.member,
          ),
        );
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return AuthFailure when user lacks permission to invite',
      () async {
        // arrange
        when(
          mockRepository.createInvitation(
            workspaceId: anyNamed('workspaceId'),
            email: anyNamed('email'),
            role: anyNamed('role'),
          ),
        ).thenAnswer(
          (_) async => Left(AuthFailure('Insufficient permissions')),
        );

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, Left(AuthFailure('Insufficient permissions')));
        verify(
          mockRepository.createInvitation(
            workspaceId: 1,
            email: 'newmember@example.com',
            role: WorkspaceRole.member,
          ),
        );
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      when(
        mockRepository.createInvitation(
          workspaceId: anyNamed('workspaceId'),
          email: anyNamed('email'),
          role: anyNamed('role'),
        ),
      ).thenAnswer((_) async => Left(ServerFailure('Server error')));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(
        mockRepository.createInvitation(
          workspaceId: 1,
          email: 'newmember@example.com',
          role: WorkspaceRole.member,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // arrange
        when(
          mockRepository.createInvitation(
            workspaceId: anyNamed('workspaceId'),
            email: anyNamed('email'),
            role: anyNamed('role'),
          ),
        ).thenAnswer((_) async => Left(NetworkFailure('No internet')));

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, Left(NetworkFailure('No internet')));
        verify(
          mockRepository.createInvitation(
            workspaceId: 1,
            email: 'newmember@example.com',
            role: WorkspaceRole.member,
          ),
        );
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
