// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import 'core/network/dio_client.dart' as _i45;
import 'data/datasources/auth_remote_datasource.dart' as _i127;
import 'data/datasources/calendar_remote_datasource.dart' as _i318;
import 'data/datasources/project_remote_datasource.dart' as _i922;
import 'data/datasources/task_remote_datasource.dart' as _i1007;
import 'data/datasources/time_log_remote_datasource.dart' as _i714;
import 'data/datasources/workload_remote_datasource.dart' as _i233;
import 'data/datasources/workspace_local_datasource.dart' as _i268;
import 'data/datasources/workspace_remote_datasource.dart' as _i391;
import 'data/repositories/auth_repository_impl.dart' as _i145;
import 'data/repositories/calendar_repository_impl.dart' as _i365;
import 'data/repositories/project_repository_impl.dart' as _i40;
import 'data/repositories/task_repository_impl.dart' as _i221;
import 'data/repositories/time_log_repository_impl.dart' as _i384;
import 'data/repositories/workload_repository_impl.dart' as _i773;
import 'data/repositories/workspace_repository_impl.dart' as _i753;
import 'domain/repositories/auth_repository.dart' as _i716;
import 'domain/repositories/calendar_repository.dart' as _i916;
import 'domain/repositories/project_repository.dart' as _i17;
import 'domain/repositories/task_repository.dart' as _i449;
import 'domain/repositories/time_log_repository.dart' as _i657;
import 'domain/repositories/workload_repository.dart' as _i42;
import 'domain/repositories/workspace_repository.dart' as _i713;
import 'domain/usecases/complete_calendar_oauth_usecase.dart' as _i812;
import 'domain/usecases/connect_calendar_usecase.dart' as _i913;
import 'domain/usecases/create_project_usecase.dart' as _i1015;
import 'domain/usecases/create_task_usecase.dart' as _i612;
import 'domain/usecases/delete_project_usecase.dart' as _i177;
import 'domain/usecases/delete_task_usecase.dart' as _i757;
import 'domain/usecases/disconnect_calendar_usecase.dart' as _i566;
import 'domain/usecases/finish_task_usecase.dart' as _i339;
import 'domain/usecases/get_active_time_log_usecase.dart' as _i987;
import 'domain/usecases/get_calendar_connection_status_usecase.dart' as _i649;
import 'domain/usecases/get_calendar_events_usecase.dart' as _i587;
import 'domain/usecases/get_profile_usecase.dart' as _i889;
import 'domain/usecases/get_project_by_id_usecase.dart' as _i356;
import 'domain/usecases/get_projects_usecase.dart' as _i32;
import 'domain/usecases/get_resource_allocation_usecase.dart' as _i654;
import 'domain/usecases/get_task_by_id_usecase.dart' as _i199;
import 'domain/usecases/get_tasks_by_project_usecase.dart' as _i725;
import 'domain/usecases/get_time_logs_by_task_usecase.dart' as _i630;
import 'domain/usecases/get_user_workload_usecase.dart' as _i971;
import 'domain/usecases/get_workload_stats_usecase.dart' as _i353;
import 'domain/usecases/login_usecase.dart' as _i883;
import 'domain/usecases/logout_usecase.dart' as _i808;
import 'domain/usecases/register_usecase.dart' as _i784;
import 'domain/usecases/start_timer_usecase.dart' as _i137;
import 'domain/usecases/stop_timer_usecase.dart' as _i838;
import 'domain/usecases/update_project_usecase.dart' as _i589;
import 'domain/usecases/update_task_usecase.dart' as _i1018;
import 'domain/usecases/workspace/accept_invitation.dart' as _i927;
import 'domain/usecases/workspace/create_invitation.dart' as _i359;
import 'domain/usecases/workspace/create_workspace.dart' as _i225;
import 'domain/usecases/workspace/get_pending_invitations.dart' as _i591;
import 'domain/usecases/workspace/get_user_workspaces.dart' as _i820;
import 'domain/usecases/workspace/get_workspace_members.dart' as _i517;
import 'presentation/bloc/auth/auth_bloc.dart' as _i605;
import 'presentation/bloc/calendar/calendar_bloc.dart' as _i659;
import 'presentation/bloc/project/project_bloc.dart' as _i190;
import 'presentation/bloc/task/task_bloc.dart' as _i944;
import 'presentation/bloc/time_tracking/time_tracking_bloc.dart' as _i808;
import 'presentation/bloc/workload/workload_bloc.dart' as _i107;
import 'presentation/bloc/workspace/workspace_bloc.dart' as _i754;
import 'presentation/bloc/workspace_invitation/workspace_invitation_bloc.dart'
    as _i953;
import 'presentation/bloc/workspace_member/workspace_member_bloc.dart' as _i53;
import 'presentation/providers/theme_provider.dart' as _i999;
import 'presentation/providers/workspace_context.dart' as _i34;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i268.WorkspaceLocalDataSource>(
      () => _i268.WorkspaceLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.singleton<_i45.DioClient>(
      () => _i45.DioClient(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i391.WorkspaceRemoteDataSource>(
      () => _i391.WorkspaceRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i127.AuthRemoteDataSource>(
      () => _i127.AuthRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.factory<_i318.CalendarRemoteDataSource>(
      () => _i318.CalendarRemoteDataSource(gh<_i45.DioClient>()),
    );
    gh.factory<_i233.WorkloadRemoteDataSource>(
      () => _i233.WorkloadRemoteDataSource(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i922.ProjectRemoteDataSource>(
      () => _i922.ProjectRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.lazySingleton<_i716.AuthRepository>(
      () => _i145.AuthRepositoryImpl(
        gh<_i127.AuthRemoteDataSource>(),
        gh<_i558.FlutterSecureStorage>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i714.TimeLogRemoteDataSource>(
      () => _i714.TimeLogRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.factory<_i916.CalendarRepository>(
      () => _i365.CalendarRepositoryImpl(gh<_i318.CalendarRemoteDataSource>()),
    );
    gh.lazySingleton<_i1007.TaskRemoteDataSource>(
      () => _i1007.TaskRemoteDataSourceImpl(gh<_i45.DioClient>()),
    );
    gh.factory<_i889.GetProfileUseCase>(
      () => _i889.GetProfileUseCase(gh<_i716.AuthRepository>()),
    );
    gh.factory<_i883.LoginUseCase>(
      () => _i883.LoginUseCase(gh<_i716.AuthRepository>()),
    );
    gh.factory<_i808.LogoutUseCase>(
      () => _i808.LogoutUseCase(gh<_i716.AuthRepository>()),
    );
    gh.factory<_i784.RegisterUseCase>(
      () => _i784.RegisterUseCase(gh<_i716.AuthRepository>()),
    );
    gh.lazySingleton<_i713.WorkspaceRepository>(
      () => _i753.WorkspaceRepositoryImpl(
        gh<_i391.WorkspaceRemoteDataSource>(),
        gh<_i268.WorkspaceLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i17.ProjectRepository>(
      () => _i40.ProjectRepositoryImpl(gh<_i922.ProjectRemoteDataSource>()),
    );
    gh.lazySingleton<_i657.TimeLogRepository>(
      () => _i384.TimeLogRepositoryImpl(gh<_i714.TimeLogRemoteDataSource>()),
    );
    gh.lazySingleton<_i449.TaskRepository>(
      () => _i221.TaskRepositoryImpl(gh<_i1007.TaskRemoteDataSource>()),
    );
    gh.factory<_i42.WorkloadRepository>(
      () => _i773.WorkloadRepositoryImpl(gh<_i233.WorkloadRemoteDataSource>()),
    );
    gh.factory<_i927.AcceptInvitationUseCase>(
      () => _i927.AcceptInvitationUseCase(gh<_i713.WorkspaceRepository>()),
    );
    gh.factory<_i359.CreateInvitationUseCase>(
      () => _i359.CreateInvitationUseCase(gh<_i713.WorkspaceRepository>()),
    );
    gh.factory<_i225.CreateWorkspaceUseCase>(
      () => _i225.CreateWorkspaceUseCase(gh<_i713.WorkspaceRepository>()),
    );
    gh.factory<_i591.GetPendingInvitationsUseCase>(
      () => _i591.GetPendingInvitationsUseCase(gh<_i713.WorkspaceRepository>()),
    );
    gh.factory<_i820.GetUserWorkspacesUseCase>(
      () => _i820.GetUserWorkspacesUseCase(gh<_i713.WorkspaceRepository>()),
    );
    gh.factory<_i517.GetWorkspaceMembersUseCase>(
      () => _i517.GetWorkspaceMembersUseCase(gh<_i713.WorkspaceRepository>()),
    );
    gh.factory<_i53.WorkspaceMemberBloc>(
      () => _i53.WorkspaceMemberBloc(gh<_i517.GetWorkspaceMembersUseCase>()),
    );
    gh.factory<_i1015.CreateProjectUseCase>(
      () => _i1015.CreateProjectUseCase(gh<_i17.ProjectRepository>()),
    );
    gh.factory<_i177.DeleteProjectUseCase>(
      () => _i177.DeleteProjectUseCase(gh<_i17.ProjectRepository>()),
    );
    gh.factory<_i32.GetProjectsUseCase>(
      () => _i32.GetProjectsUseCase(gh<_i17.ProjectRepository>()),
    );
    gh.factory<_i356.GetProjectByIdUseCase>(
      () => _i356.GetProjectByIdUseCase(gh<_i17.ProjectRepository>()),
    );
    gh.factory<_i589.UpdateProjectUseCase>(
      () => _i589.UpdateProjectUseCase(gh<_i17.ProjectRepository>()),
    );
    gh.factory<_i812.CompleteCalendarOAuthUseCase>(
      () => _i812.CompleteCalendarOAuthUseCase(gh<_i916.CalendarRepository>()),
    );
    gh.factory<_i913.ConnectCalendarUseCase>(
      () => _i913.ConnectCalendarUseCase(gh<_i916.CalendarRepository>()),
    );
    gh.factory<_i566.DisconnectCalendarUseCase>(
      () => _i566.DisconnectCalendarUseCase(gh<_i916.CalendarRepository>()),
    );
    gh.factory<_i649.GetCalendarConnectionStatusUseCase>(
      () => _i649.GetCalendarConnectionStatusUseCase(
        gh<_i916.CalendarRepository>(),
      ),
    );
    gh.factory<_i587.GetCalendarEventsUseCase>(
      () => _i587.GetCalendarEventsUseCase(gh<_i916.CalendarRepository>()),
    );
    gh.factory<_i605.AuthBloc>(
      () => _i605.AuthBloc(
        gh<_i883.LoginUseCase>(),
        gh<_i784.RegisterUseCase>(),
        gh<_i889.GetProfileUseCase>(),
        gh<_i808.LogoutUseCase>(),
      ),
    );
    gh.factory<_i953.WorkspaceInvitationBloc>(
      () => _i953.WorkspaceInvitationBloc(
        gh<_i591.GetPendingInvitationsUseCase>(),
        gh<_i359.CreateInvitationUseCase>(),
        gh<_i927.AcceptInvitationUseCase>(),
      ),
    );
    gh.factory<_i659.CalendarBloc>(
      () => _i659.CalendarBloc(
        gh<_i913.ConnectCalendarUseCase>(),
        gh<_i566.DisconnectCalendarUseCase>(),
        gh<_i649.GetCalendarConnectionStatusUseCase>(),
        gh<_i587.GetCalendarEventsUseCase>(),
        gh<_i812.CompleteCalendarOAuthUseCase>(),
      ),
    );
    gh.factory<_i654.GetResourceAllocationUseCase>(
      () => _i654.GetResourceAllocationUseCase(gh<_i42.WorkloadRepository>()),
    );
    gh.factory<_i971.GetUserWorkloadUseCase>(
      () => _i971.GetUserWorkloadUseCase(gh<_i42.WorkloadRepository>()),
    );
    gh.factory<_i353.GetWorkloadStatsUseCase>(
      () => _i353.GetWorkloadStatsUseCase(gh<_i42.WorkloadRepository>()),
    );
    gh.factory<_i339.FinishTaskUseCase>(
      () => _i339.FinishTaskUseCase(gh<_i657.TimeLogRepository>()),
    );
    gh.factory<_i987.GetActiveTimeLogUseCase>(
      () => _i987.GetActiveTimeLogUseCase(gh<_i657.TimeLogRepository>()),
    );
    gh.factory<_i630.GetTimeLogsByTaskUseCase>(
      () => _i630.GetTimeLogsByTaskUseCase(gh<_i657.TimeLogRepository>()),
    );
    gh.factory<_i137.StartTimerUseCase>(
      () => _i137.StartTimerUseCase(gh<_i657.TimeLogRepository>()),
    );
    gh.factory<_i838.StopTimerUseCase>(
      () => _i838.StopTimerUseCase(gh<_i657.TimeLogRepository>()),
    );
    gh.factory<_i808.TimeTrackingBloc>(
      () => _i808.TimeTrackingBloc(
        gh<_i137.StartTimerUseCase>(),
        gh<_i838.StopTimerUseCase>(),
        gh<_i339.FinishTaskUseCase>(),
        gh<_i630.GetTimeLogsByTaskUseCase>(),
        gh<_i987.GetActiveTimeLogUseCase>(),
      ),
    );
    gh.factory<_i612.CreateTaskUseCase>(
      () => _i612.CreateTaskUseCase(gh<_i449.TaskRepository>()),
    );
    gh.factory<_i757.DeleteTaskUseCase>(
      () => _i757.DeleteTaskUseCase(gh<_i449.TaskRepository>()),
    );
    gh.factory<_i725.GetTasksByProjectUseCase>(
      () => _i725.GetTasksByProjectUseCase(gh<_i449.TaskRepository>()),
    );
    gh.factory<_i199.GetTaskByIdUseCase>(
      () => _i199.GetTaskByIdUseCase(gh<_i449.TaskRepository>()),
    );
    gh.factory<_i1018.UpdateTaskUseCase>(
      () => _i1018.UpdateTaskUseCase(gh<_i449.TaskRepository>()),
    );
    gh.factory<_i190.ProjectBloc>(
      () => _i190.ProjectBloc(
        gh<_i32.GetProjectsUseCase>(),
        gh<_i356.GetProjectByIdUseCase>(),
        gh<_i1015.CreateProjectUseCase>(),
        gh<_i589.UpdateProjectUseCase>(),
        gh<_i177.DeleteProjectUseCase>(),
      ),
    );
    gh.factory<_i754.WorkspaceBloc>(
      () => _i754.WorkspaceBloc(
        gh<_i820.GetUserWorkspacesUseCase>(),
        gh<_i225.CreateWorkspaceUseCase>(),
      ),
    );
    gh.factory<_i107.WorkloadBloc>(
      () => _i107.WorkloadBloc(
        gh<_i654.GetResourceAllocationUseCase>(),
        gh<_i971.GetUserWorkloadUseCase>(),
        gh<_i353.GetWorkloadStatsUseCase>(),
      ),
    );
    gh.factory<_i944.TaskBloc>(
      () => _i944.TaskBloc(
        gh<_i725.GetTasksByProjectUseCase>(),
        gh<_i199.GetTaskByIdUseCase>(),
        gh<_i612.CreateTaskUseCase>(),
        gh<_i1018.UpdateTaskUseCase>(),
        gh<_i757.DeleteTaskUseCase>(),
        gh<_i449.TaskRepository>(),
      ),
    );
    gh.factory<_i34.WorkspaceContext>(
      () => _i34.WorkspaceContext(gh<_i754.WorkspaceBloc>()),
    );
    gh.factory<_i999.ThemeProvider>(
      () => _i999.ThemeProvider(gh<_i460.SharedPreferences>()),
    );
    return this;
  }
}
