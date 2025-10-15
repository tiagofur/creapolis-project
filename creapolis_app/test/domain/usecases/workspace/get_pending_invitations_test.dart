import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/entities/workspace.dart';
import 'package:creapolis_app/domain/entities/workspace_invitation.dart';
import 'package:creapolis_app/domain/repositories/workspace_repository.dart';
import 'package:creapolis_app/domain/usecases/workspace/get_pending_invitations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_pending_invitations_test.mocks.dart';

@GenerateMocks([WorkspaceRepository])
void main() {
  late GetPendingInvitationsUseCase usecase;
  late MockWorkspaceRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkspaceRepository();
    usecase = GetPendingInvitationsUseCase(mockRepository);
  });

  final tInvitations = [
    WorkspaceInvitation(
      id: 1,
      workspaceId: 1,
      workspaceName: 'Team Workspace',
      workspaceDescription: 'A collaborative team workspace',
      workspaceType: WorkspaceType.team,
      inviterName: 'John Doe',
      inviterEmail: 'john@example.com',
      inviteeEmail: 'user@example.com',
      role: WorkspaceRole.member,
      token: 'token_abc123',
      status: InvitationStatus.pending,
      createdAt: DateTime(2024, 1, 1),
      expiresAt: DateTime(2024, 1, 8),
    ),
    WorkspaceInvitation(
      id: 2,
      workspaceId: 2,
      workspaceName: 'Enterprise Workspace',
      workspaceType: WorkspaceType.enterprise,
      inviterName: 'Jane Smith',
      inviterEmail: 'jane@company.com',
      inviteeEmail: 'user@example.com',
      role: WorkspaceRole.admin,
      token: 'token_xyz789',
      status: InvitationStatus.pending,
      createdAt: DateTime(2024, 1, 2),
      expiresAt: DateTime(2024, 1, 9),
    ),
  ];

  group('GetPendingInvitations', () {
    test('should get list of pending invitations from repository', () async {
      // arrange
      when(
        mockRepository.getPendingInvitations(),
      ).thenAnswer((_) async => Right(tInvitations));

      // act
      final result = await usecase();

      // assert
      expect(result, Right(tInvitations));
      verify(mockRepository.getPendingInvitations());
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return empty list when user has no pending invitations',
      () async {
        // arrange
        when(
          mockRepository.getPendingInvitations(),
        ).thenAnswer((_) async => const Right(<WorkspaceInvitation>[]));

        // act
        final result = await usecase();

        // assert
        expect(result, const Right(<WorkspaceInvitation>[]));
        verify(mockRepository.getPendingInvitations());
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      when(
        mockRepository.getPendingInvitations(),
      ).thenAnswer((_) async => Left(ServerFailure('Server error')));

      // act
      final result = await usecase();

      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(mockRepository.getPendingInvitations());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when user is not authenticated', () async {
      // arrange
      when(
        mockRepository.getPendingInvitations(),
      ).thenAnswer((_) async => Left(AuthFailure('Not authenticated')));

      // act
      final result = await usecase();

      // assert
      expect(result, Left(AuthFailure('Not authenticated')));
      verify(mockRepository.getPendingInvitations());
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // arrange
        when(
          mockRepository.getPendingInvitations(),
        ).thenAnswer((_) async => Left(NetworkFailure('No internet')));

        // act
        final result = await usecase();

        // assert
        expect(result, Left(NetworkFailure('No internet')));
        verify(mockRepository.getPendingInvitations());
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}



