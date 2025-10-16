// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import 'core/database/cache_manager.dart' as _i454;
import 'core/network/api_client.dart' as _i871;
import 'core/network/dio_client.dart' as _i45;
import 'core/services/connectivity_service.dart' as _i524;
import 'core/services/firebase_messaging_service.dart' as _i43;
import 'core/services/sync_notification_service.dart' as _i659;
import 'core/sync/sync_manager.dart' as _i223;
import 'core/sync/sync_operation_executor.dart' as _i203;
import 'data/datasources/auth_remote_datasource.dart' as _i127;
import 'data/datasources/calendar_remote_datasource.dart' as _i318;
import 'data/datasources/comment_remote_datasource.dart' as _i976;
import 'data/datasources/local/project_cache_datasource.dart' as _i255;
import 'data/datasources/local/task_cache_datasource.dart' as _i314;
import 'data/datasources/local/workspace_cache_datasource.dart' as _i618;
import 'data/datasources/nlp_remote_datasource.dart' as _i23;
import 'data/datasources/notification_remote_datasource.dart' as _i888;
import 'data/datasources/project_member_remote_datasource.dart' as _i31;
import 'data/datasources/project_remote_datasource.dart' as _i922;
import 'data/datasources/push_notification_remote_datasource.dart' as _i959;
import 'data/datasources/remote/category_remote_datasource.dart' as _i1050;
import 'data/datasources/search_remote_datasource.dart' as _i232;
import 'data/datasources/task_remote_datasource.dart' as _i1007;
import 'data/datasources/time_log_remote_datasource.dart' as _i714;
import 'data/datasources/workload_remote_datasource.dart' as _i233;
import 'data/datasources/workspace_local_datasource.dart' as _i268;
import 'data/datasources/workspace_remote_datasource.dart' as _i391;
import 'data/repositories/auth_repository_impl.dart' as _i145;
import 'data/repositories/calendar_repository_impl.dart' as _i365;
import 'data/repositories/category_repository_impl.dart' as _i1032;
import 'data/repositories/comment_repository_impl.dart' as _i329;
import 'data/repositories/nlp_repository_impl.dart' as _i693;
import 'data/repositories/notification_repository_impl.dart' as _i704;
import 'data/repositories/project_member_repository_impl.dart' as _i788;
import 'data/repositories/project_repository_impl.dart' as _i40;
import 'data/repositories/search_repository_impl.dart' as _i409;
import 'data/repositories/task_repository_impl.dart' as _i221;
import 'data/repositories/time_log_repository_impl.dart' as _i384;
import 'data/repositories/workload_repository_impl.dart' as _i773;
import 'data/repositories/workspace_repository_impl.dart' as _i753;
import 'domain/repositories/auth_repository.dart' as _i716;
import 'domain/repositories/calendar_repository.dart' as _i916;
import 'domain/repositories/category_repository.dart' as _i615;
import 'domain/repositories/comment_repository.dart' as _i60;
import 'domain/repositories/nlp_repository.dart' as _i511;
import 'domain/repositories/notification_repository.dart' as _i82;
import 'domain/repositories/project_member_repository.dart' as _i51;
import 'domain/repositories/project_repository.dart' as _i17;
import 'domain/repositories/search_repository.dart' as _i844;
import 'domain/repositories/task_repository.dart' as _i449;
import 'domain/repositories/time_log_repository.dart' as _i657;
import 'domain/repositories/workload_repository.dart' as _i42;
import 'domain/repositories/workspace_repository.dart' as _i713;
import 'domain/usecases/category/apply_category_usecase.dart' as _i696;
import 'domain/usecases/category/get_category_metrics_usecase.dart' as _i766;
import 'domain/usecases/category/get_category_suggestion_usecase.dart' as _i494;
import 'domain/usecases/category/get_suggestions_history_usecase.dart' as _i424;
import 'domain/usecases/category/submit_category_feedback_usecase.dart'
    as _i597;
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
import 'domain/usecases/get_nlp_examples_usecase.dart' as _i764;
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
import 'domain/usecases/parse_task_instruction_usecase.dart' as _i82;
import 'domain/usecases/register_usecase.dart' as _i784;
import 'domain/usecases/start_timer_usecase.dart' as _i137;
import 'domain/usecases/stop_timer_usecase.dart' as _i838;
import 'domain/usecases/update_project_usecase.dart' as _i589;
import 'domain/usecases/update_task_usecase.dart' as _i1018;
import 'domain/usecases/workspace/accept_invitation.dart' as _i927;
import 'domain/usecases/workspace/create_invitation.dart' as _i359;
import 'domain/usecases/workspace/create_workspace.dart' as _i225;
import 'domain/usecases/workspace/decline_invitation.dart' as _i9;
import 'domain/usecases/workspace/delete_workspace.dart' as _i154;
import 'domain/usecases/workspace/get_active_workspace.dart' as _i890;
import 'domain/usecases/workspace/get_pending_invitations.dart' as _i591;
import 'domain/usecases/workspace/get_user_workspaces.dart' as _i820;
import 'domain/usecases/workspace/get_workspace_members.dart' as _i517;
import 'domain/usecases/workspace/set_active_workspace.dart' as _i245;
import 'domain/usecases/workspace/update_workspace.dart' as _i1066;
import 'features/projects/presentation/blocs/project_bloc.dart' as _i328;
import 'features/search/presentation/blocs/search_bloc.dart' as _i807;
import 'features/tasks/presentation/blocs/task_bloc.dart' as _i100;
import 'features/workspace/data/datasources/workspace_remote_datasource.dart'
    as _i398;
import 'features/workspace/presentation/bloc/workspace_bloc.dart' as _i207;
import 'presentation/bloc/auth/auth_bloc.dart' as _i605;
import 'presentation/bloc/calendar/calendar_bloc.dart' as _i659;
import 'presentation/bloc/category/category_bloc.dart' as _i116;
import 'presentation/bloc/comment/comment_bloc.dart' as _i462;
import 'presentation/bloc/notification/notification_bloc.dart' as _i571;
import 'presentation/bloc/task/task_bloc.dart' as _i944;
import 'presentation/bloc/time_tracking/time_tracking_bloc.dart' as _i808;
import 'presentation/bloc/workload/workload_bloc.dart' as _i107;
import 'presentation/bloc/workspace_invitation/workspace_invitation_bloc.dart'
    as _i953;
import 'presentation/bloc/workspace_member/workspace_member_bloc.dart' as _i53;
import 'presentation/blocs/project_member/project_member_bloc.dart' as _i124;
import 'presentation/providers/theme_provider.dart' as _i971;
import 'presentation/providers/workspace_context.dart' as _i34;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i454.CacheManager>(() => _i454.CacheManager());
    gh.lazySingleton<_i618.WorkspaceCacheDataSource>(
        () => _i618.WorkspaceCacheDataSourceImpl(gh<_i454.CacheManager>()));
    gh.lazySingleton<_i31.ProjectMemberRemoteDataSource>(
        () => _i31.ProjectMemberRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.factory<_i971.ThemeProvider>(
        () => _i971.ThemeProvider(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i255.ProjectCacheDataSource>(
        () => _i255.ProjectCacheDataSourceImpl(gh<_i454.CacheManager>()));
    gh.lazySingleton<_i232.SearchRemoteDataSource>(
        () => _i232.SearchRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i314.TaskCacheDataSource>(
        () => _i314.TaskCacheDataSourceImpl(gh<_i454.CacheManager>()));
    gh.lazySingleton<_i959.PushNotificationRemoteDataSource>(() =>
        _i959.PushNotificationRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i976.CommentRemoteDataSource>(
        () => _i976.CommentRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i922.ProjectRemoteDataSource>(
        () => _i922.ProjectRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i1007.TaskRemoteDataSource>(
        () => _i1007.TaskRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i268.WorkspaceLocalDataSource>(() =>
        _i268.WorkspaceLocalDataSourceImpl(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i1050.CategoryRemoteDataSource>(
        () => _i1050.CategoryRemoteDataSource(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i398.WorkspaceRemoteDataSource>(
        () => _i398.WorkspaceRemoteDataSource(gh<_i871.ApiClient>()));
    gh.singleton<_i45.DioClient>(
        () => _i45.DioClient(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i23.NLPRemoteDataSource>(
        () => _i23.NLPRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i888.NotificationRemoteDataSource>(
        () => _i888.NotificationRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i60.CommentRepository>(
        () => _i329.CommentRepositoryImpl(gh<_i976.CommentRemoteDataSource>()));
    gh.lazySingleton<_i615.CategoryRepository>(() =>
        _i1032.CategoryRepositoryImpl(gh<_i1050.CategoryRemoteDataSource>()));
    gh.lazySingleton<_i391.WorkspaceRemoteDataSource>(
        () => _i391.WorkspaceRemoteDataSourceImpl(gh<_i45.DioClient>()));
    gh.lazySingleton<_i844.SearchRepository>(
        () => _i409.SearchRepositoryImpl(gh<_i232.SearchRemoteDataSource>()));
    gh.lazySingleton<_i43.FirebaseMessagingService>(
        () => _i43.FirebaseMessagingService(
              gh<_i892.FirebaseMessaging>(),
              gh<_i959.PushNotificationRemoteDataSource>(),
            ));
    gh.factory<_i462.CommentBloc>(
        () => _i462.CommentBloc(gh<_i60.CommentRepository>()));
    gh.lazySingleton<_i127.AuthRemoteDataSource>(
        () => _i127.AuthRemoteDataSourceImpl(gh<_i45.DioClient>()));
    gh.lazySingleton<_i51.ProjectMemberRepository>(() =>
        _i788.ProjectMemberRepositoryImpl(
            gh<_i31.ProjectMemberRemoteDataSource>()));
    gh.lazySingleton<_i82.NotificationRepository>(() =>
        _i704.NotificationRepositoryImpl(
            gh<_i888.NotificationRemoteDataSource>()));
    gh.lazySingleton<_i524.ConnectivityService>(
        () => _i524.ConnectivityService(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i207.WorkspaceBloc>(
        () => _i207.WorkspaceBloc(gh<_i398.WorkspaceRemoteDataSource>()));
    gh.factory<_i318.CalendarRemoteDataSource>(
        () => _i318.CalendarRemoteDataSource(gh<_i45.DioClient>()));
    gh.factory<_i233.WorkloadRemoteDataSource>(
        () => _i233.WorkloadRemoteDataSource(gh<_i45.DioClient>()));
    gh.lazySingleton<_i713.WorkspaceRepository>(
        () => _i753.WorkspaceRepositoryImpl(
              gh<_i391.WorkspaceRemoteDataSource>(),
              gh<_i268.WorkspaceLocalDataSource>(),
              gh<_i618.WorkspaceCacheDataSource>(),
              gh<_i524.ConnectivityService>(),
            ));
    gh.factory<_i807.SearchBloc>(
        () => _i807.SearchBloc(gh<_i844.SearchRepository>()));
    gh.factory<_i927.AcceptInvitationUseCase>(
        () => _i927.AcceptInvitationUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i359.CreateInvitationUseCase>(
        () => _i359.CreateInvitationUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i225.CreateWorkspaceUseCase>(
        () => _i225.CreateWorkspaceUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i9.DeclineInvitationUseCase>(
        () => _i9.DeclineInvitationUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i154.DeleteWorkspaceUseCase>(
        () => _i154.DeleteWorkspaceUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i890.GetActiveWorkspaceUseCase>(
        () => _i890.GetActiveWorkspaceUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i591.GetPendingInvitationsUseCase>(() =>
        _i591.GetPendingInvitationsUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i820.GetUserWorkspacesUseCase>(
        () => _i820.GetUserWorkspacesUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i517.GetWorkspaceMembersUseCase>(() =>
        _i517.GetWorkspaceMembersUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i245.SetActiveWorkspaceUseCase>(
        () => _i245.SetActiveWorkspaceUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i1066.UpdateWorkspaceUseCase>(
        () => _i1066.UpdateWorkspaceUseCase(gh<_i713.WorkspaceRepository>()));
    gh.lazySingleton<_i17.ProjectRepository>(() => _i40.ProjectRepositoryImpl(
          gh<_i922.ProjectRemoteDataSource>(),
          gh<_i255.ProjectCacheDataSource>(),
          gh<_i524.ConnectivityService>(),
        ));
    gh.factory<_i53.WorkspaceMemberBloc>(
        () => _i53.WorkspaceMemberBloc(gh<_i517.GetWorkspaceMembersUseCase>()));
    gh.lazySingleton<_i716.AuthRepository>(() => _i145.AuthRepositoryImpl(
          gh<_i127.AuthRemoteDataSource>(),
          gh<_i558.FlutterSecureStorage>(),
          gh<_i460.SharedPreferences>(),
        ));
    gh.factory<_i1015.CreateProjectUseCase>(
        () => _i1015.CreateProjectUseCase(gh<_i17.ProjectRepository>()));
    gh.factory<_i177.DeleteProjectUseCase>(
        () => _i177.DeleteProjectUseCase(gh<_i17.ProjectRepository>()));
    gh.factory<_i32.GetProjectsUseCase>(
        () => _i32.GetProjectsUseCase(gh<_i17.ProjectRepository>()));
    gh.factory<_i356.GetProjectByIdUseCase>(
        () => _i356.GetProjectByIdUseCase(gh<_i17.ProjectRepository>()));
    gh.factory<_i589.UpdateProjectUseCase>(
        () => _i589.UpdateProjectUseCase(gh<_i17.ProjectRepository>()));
    gh.lazySingleton<_i696.ApplyCategoryUseCase>(
        () => _i696.ApplyCategoryUseCase(gh<_i615.CategoryRepository>()));
    gh.lazySingleton<_i766.GetCategoryMetricsUseCase>(
        () => _i766.GetCategoryMetricsUseCase(gh<_i615.CategoryRepository>()));
    gh.lazySingleton<_i494.GetCategorySuggestionUseCase>(() =>
        _i494.GetCategorySuggestionUseCase(gh<_i615.CategoryRepository>()));
    gh.lazySingleton<_i424.GetSuggestionsHistoryUseCase>(() =>
        _i424.GetSuggestionsHistoryUseCase(gh<_i615.CategoryRepository>()));
    gh.lazySingleton<_i597.SubmitCategoryFeedbackUseCase>(() =>
        _i597.SubmitCategoryFeedbackUseCase(gh<_i615.CategoryRepository>()));
    gh.factory<_i571.NotificationBloc>(
        () => _i571.NotificationBloc(gh<_i82.NotificationRepository>()));
    gh.lazySingleton<_i714.TimeLogRemoteDataSource>(
        () => _i714.TimeLogRemoteDataSourceImpl(gh<_i45.DioClient>()));
    gh.factory<_i916.CalendarRepository>(() =>
        _i365.CalendarRepositoryImpl(gh<_i318.CalendarRemoteDataSource>()));
    gh.factory<_i953.WorkspaceInvitationBloc>(
        () => _i953.WorkspaceInvitationBloc(
              gh<_i591.GetPendingInvitationsUseCase>(),
              gh<_i359.CreateInvitationUseCase>(),
              gh<_i927.AcceptInvitationUseCase>(),
              gh<_i9.DeclineInvitationUseCase>(),
            ));
    gh.factory<_i124.ProjectMemberBloc>(
        () => _i124.ProjectMemberBloc(gh<_i51.ProjectMemberRepository>()));
    gh.factory<_i889.GetProfileUseCase>(
        () => _i889.GetProfileUseCase(gh<_i716.AuthRepository>()));
    gh.factory<_i883.LoginUseCase>(
        () => _i883.LoginUseCase(gh<_i716.AuthRepository>()));
    gh.factory<_i808.LogoutUseCase>(
        () => _i808.LogoutUseCase(gh<_i716.AuthRepository>()));
    gh.factory<_i784.RegisterUseCase>(
        () => _i784.RegisterUseCase(gh<_i716.AuthRepository>()));
    gh.lazySingleton<_i511.NLPRepository>(() => _i693.NLPRepositoryImpl(
          gh<_i23.NLPRemoteDataSource>(),
          gh<_i524.ConnectivityService>(),
        ));
    gh.factory<_i764.GetNLPExamplesUseCase>(
        () => _i764.GetNLPExamplesUseCase(gh<_i511.NLPRepository>()));
    gh.factory<_i82.ParseTaskInstructionUseCase>(
        () => _i82.ParseTaskInstructionUseCase(gh<_i511.NLPRepository>()));
    gh.lazySingleton<_i449.TaskRepository>(() => _i221.TaskRepositoryImpl(
          gh<_i1007.TaskRemoteDataSource>(),
          gh<_i314.TaskCacheDataSource>(),
          gh<_i524.ConnectivityService>(),
        ));
    gh.lazySingleton<_i657.TimeLogRepository>(
        () => _i384.TimeLogRepositoryImpl(gh<_i714.TimeLogRemoteDataSource>()));
    gh.factory<_i612.CreateTaskUseCase>(
        () => _i612.CreateTaskUseCase(gh<_i449.TaskRepository>()));
    gh.factory<_i757.DeleteTaskUseCase>(
        () => _i757.DeleteTaskUseCase(gh<_i449.TaskRepository>()));
    gh.factory<_i725.GetTasksByProjectUseCase>(
        () => _i725.GetTasksByProjectUseCase(gh<_i449.TaskRepository>()));
    gh.factory<_i199.GetTaskByIdUseCase>(
        () => _i199.GetTaskByIdUseCase(gh<_i449.TaskRepository>()));
    gh.factory<_i1018.UpdateTaskUseCase>(
        () => _i1018.UpdateTaskUseCase(gh<_i449.TaskRepository>()));
    gh.singleton<_i34.WorkspaceContext>(
        () => _i34.WorkspaceContext(gh<_i207.WorkspaceBloc>()));
    gh.factory<_i42.WorkloadRepository>(() =>
        _i773.WorkloadRepositoryImpl(gh<_i233.WorkloadRemoteDataSource>()));
    gh.factory<_i100.TaskBloc>(
        () => _i100.TaskBloc(taskRepository: gh<_i449.TaskRepository>()));
    gh.factory<_i328.ProjectBloc>(() => _i328.ProjectBloc(
          gh<_i32.GetProjectsUseCase>(),
          gh<_i356.GetProjectByIdUseCase>(),
          gh<_i1015.CreateProjectUseCase>(),
          gh<_i589.UpdateProjectUseCase>(),
          gh<_i177.DeleteProjectUseCase>(),
        ));
    gh.factory<_i116.CategoryBloc>(() => _i116.CategoryBloc(
          gh<_i494.GetCategorySuggestionUseCase>(),
          gh<_i696.ApplyCategoryUseCase>(),
          gh<_i597.SubmitCategoryFeedbackUseCase>(),
          gh<_i766.GetCategoryMetricsUseCase>(),
          gh<_i424.GetSuggestionsHistoryUseCase>(),
        ));
    gh.lazySingleton<_i203.SyncOperationExecutor>(
        () => _i203.SyncOperationExecutor(
              gh<_i713.WorkspaceRepository>(),
              gh<_i17.ProjectRepository>(),
              gh<_i449.TaskRepository>(),
            ));
    gh.factory<_i812.CompleteCalendarOAuthUseCase>(() =>
        _i812.CompleteCalendarOAuthUseCase(gh<_i916.CalendarRepository>()));
    gh.factory<_i913.ConnectCalendarUseCase>(
        () => _i913.ConnectCalendarUseCase(gh<_i916.CalendarRepository>()));
    gh.factory<_i566.DisconnectCalendarUseCase>(
        () => _i566.DisconnectCalendarUseCase(gh<_i916.CalendarRepository>()));
    gh.factory<_i649.GetCalendarConnectionStatusUseCase>(() =>
        _i649.GetCalendarConnectionStatusUseCase(
            gh<_i916.CalendarRepository>()));
    gh.factory<_i587.GetCalendarEventsUseCase>(
        () => _i587.GetCalendarEventsUseCase(gh<_i916.CalendarRepository>()));
    gh.factory<_i605.AuthBloc>(() => _i605.AuthBloc(
          gh<_i883.LoginUseCase>(),
          gh<_i784.RegisterUseCase>(),
          gh<_i889.GetProfileUseCase>(),
          gh<_i808.LogoutUseCase>(),
        ));
    gh.factory<_i944.TaskBloc>(() => _i944.TaskBloc(
          gh<_i725.GetTasksByProjectUseCase>(),
          gh<_i199.GetTaskByIdUseCase>(),
          gh<_i612.CreateTaskUseCase>(),
          gh<_i1018.UpdateTaskUseCase>(),
          gh<_i757.DeleteTaskUseCase>(),
          gh<_i449.TaskRepository>(),
        ));
    gh.lazySingleton<_i223.SyncManager>(() => _i223.SyncManager(
          gh<_i524.ConnectivityService>(),
          gh<_i203.SyncOperationExecutor>(),
        ));
    gh.factory<_i659.CalendarBloc>(() => _i659.CalendarBloc(
          gh<_i913.ConnectCalendarUseCase>(),
          gh<_i566.DisconnectCalendarUseCase>(),
          gh<_i649.GetCalendarConnectionStatusUseCase>(),
          gh<_i587.GetCalendarEventsUseCase>(),
          gh<_i812.CompleteCalendarOAuthUseCase>(),
        ));
    gh.factory<_i654.GetResourceAllocationUseCase>(() =>
        _i654.GetResourceAllocationUseCase(gh<_i42.WorkloadRepository>()));
    gh.factory<_i971.GetUserWorkloadUseCase>(
        () => _i971.GetUserWorkloadUseCase(gh<_i42.WorkloadRepository>()));
    gh.factory<_i353.GetWorkloadStatsUseCase>(
        () => _i353.GetWorkloadStatsUseCase(gh<_i42.WorkloadRepository>()));
    gh.factory<_i339.FinishTaskUseCase>(
        () => _i339.FinishTaskUseCase(gh<_i657.TimeLogRepository>()));
    gh.factory<_i987.GetActiveTimeLogUseCase>(
        () => _i987.GetActiveTimeLogUseCase(gh<_i657.TimeLogRepository>()));
    gh.factory<_i630.GetTimeLogsByTaskUseCase>(
        () => _i630.GetTimeLogsByTaskUseCase(gh<_i657.TimeLogRepository>()));
    gh.factory<_i137.StartTimerUseCase>(
        () => _i137.StartTimerUseCase(gh<_i657.TimeLogRepository>()));
    gh.factory<_i838.StopTimerUseCase>(
        () => _i838.StopTimerUseCase(gh<_i657.TimeLogRepository>()));
    gh.factory<_i808.TimeTrackingBloc>(() => _i808.TimeTrackingBloc(
          gh<_i137.StartTimerUseCase>(),
          gh<_i838.StopTimerUseCase>(),
          gh<_i339.FinishTaskUseCase>(),
          gh<_i630.GetTimeLogsByTaskUseCase>(),
          gh<_i987.GetActiveTimeLogUseCase>(),
        ));
    gh.lazySingleton<_i659.SyncNotificationService>(
        () => _i659.SyncNotificationService(gh<_i223.SyncManager>()));
    gh.factory<_i107.WorkloadBloc>(() => _i107.WorkloadBloc(
          gh<_i654.GetResourceAllocationUseCase>(),
          gh<_i971.GetUserWorkloadUseCase>(),
          gh<_i353.GetWorkloadStatsUseCase>(),
        ));
    return this;
  }
}
