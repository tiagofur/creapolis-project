import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/features/workspace/data/models/workspace_model.dart';
import 'package:creapolis_app/domain/repositories/workspace_repository.dart';
import 'package:creapolis_app/domain/usecases/workspace/accept_invitation.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'accept_invitation_test.mocks.dart';

@GenerateMocks([WorkspaceRepository])
void main() {
  late AcceptInvitationUseCase usecase;
  late MockWorkspaceRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkspaceRepository();
    usecase = AcceptInvitationUseCase(mockRepository);
  });

  const tToken = 'valid_invitation_token_12345';
  final tWorkspace = Workspace(
    id: 1,
    name: 'Accepted Workspace',
    description: 'Workspace from accepted invitation',
    avatarUrl: null,
    type: WorkspaceType.team,
    ownerId: 2,
    owner: const WorkspaceOwner(
      id: 2,
      name: 'John Doe',
      email: 'john@example.com',
    ),
    userRole: WorkspaceRole.member, // Usuario aceptó invitación como member
    memberCount: 5,
    projectCount: 3,
    settings: WorkspaceSettings.defaults(),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('AcceptInvitation', () {
    test(
      'should accept invitation and return workspace from repository',
      () async {
        // arrange
        when(
          mockRepository.acceptInvitation(any),
        ).thenAnswer((_) async => Right(tWorkspace));

        // act
        final result = await usecase(AcceptInvitationParams(token: tToken));

        // assert
        expect(result, Right(tWorkspace));
        verify(mockRepository.acceptInvitation(tToken));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return NotFoundFailure when token is invalid or expired',
      () async {
        // arrange
        when(mockRepository.acceptInvitation(any)).thenAnswer(
          (_) async => Left(NotFoundFailure('Invitation not found or expired')),
        );

        // act
        final result = await usecase(
          AcceptInvitationParams(token: 'invalid_token'),
        );

        // assert
        expect(
          result,
          Left(NotFoundFailure('Invitation not found or expired')),
        );
        verify(mockRepository.acceptInvitation('invalid_token'));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return ValidationFailure when user is already a member',
      () async {
        // arrange
        when(mockRepository.acceptInvitation(any)).thenAnswer(
          (_) async => Left(
            ValidationFailure('User is already a member of this workspace'),
          ),
        );

        // act
        final result = await usecase(AcceptInvitationParams(token: tToken));

        // assert
        expect(
          result,
          Left(ValidationFailure('User is already a member of this workspace')),
        );
        verify(mockRepository.acceptInvitation(tToken));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      when(
        mockRepository.acceptInvitation(any),
      ).thenAnswer((_) async => Left(ServerFailure('Server error')));

      // act
      final result = await usecase(AcceptInvitationParams(token: tToken));

      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(mockRepository.acceptInvitation(tToken));
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // arrange
        when(
          mockRepository.acceptInvitation(any),
        ).thenAnswer((_) async => Left(NetworkFailure('No internet')));

        // act
        final result = await usecase(AcceptInvitationParams(token: tToken));

        // assert
        expect(result, Left(NetworkFailure('No internet')));
        verify(mockRepository.acceptInvitation(tToken));
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
