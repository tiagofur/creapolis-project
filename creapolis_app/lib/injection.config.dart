// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import 'core/database/cache_manager.dart' as _i454;
import 'core/di/register_module.dart' as _i854;
import 'core/network/api_client.dart' as _i871;
import 'core/network/dio_client.dart' as _i45;
import 'core/network/interceptors/auth_interceptor.dart' as _i1023;
import 'core/services/connectivity_service.dart' as _i524;
import 'core/services/firebase_messaging_service.dart' as _i43;
import 'core/services/last_route_service.dart' as _i406;
import 'core/services/socket_service.dart' as _i848;
import 'core/services/sync_notification_service.dart' as _i659;
import 'core/sync/conflict_resolution_service.dart' as _i738;
import 'core/sync/sync_manager.dart' as _i223;
import 'core/sync/sync_operation_executor.dart' as _i203;
import 'data/datasources/audit_remote_datasource.dart' as _i993;
import 'data/datasources/auth_remote_datasource.dart' as _i127;
import 'data/datasources/automation_remote_datasource.dart' as _i568;
import 'data/datasources/calendar_remote_datasource.dart' as _i318;
import 'data/datasources/comment_remote_datasource.dart' as _i976;
import 'data/datasources/custom_field_remote_datasource.dart' as _i325;
import 'data/datasources/form_remote_datasource.dart' as _i1056;
import 'data/datasources/gamification_remote_datasource.dart' as _i1070;
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
import 'data/datasources/sprint_remote_datasource.dart' as _i747;
import 'data/datasources/sso_remote_datasource.dart' as _i918;
import 'data/datasources/task_remote_datasource.dart' as _i1007;
import 'data/datasources/time_log_remote_datasource.dart' as _i714;
import 'data/datasources/webhook_remote_datasource.dart' as _i871;
import 'data/datasources/workload_remote_datasource.dart' as _i233;
import 'data/datasources/workspace_local_datasource.dart' as _i268;
import 'data/datasources/workspace_remote_datasource.dart' as _i391;
import 'data/repositories/audit_repository_impl.dart' as _i71;
import 'data/repositories/auth_repository_impl.dart' as _i145;
import 'data/repositories/automation_repository_impl.dart' as _i590;
import 'data/repositories/calendar_repository_impl.dart' as _i365;
import 'data/repositories/category_repository_impl.dart' as _i1032;
import 'data/repositories/comment_repository_impl.dart' as _i329;
import 'data/repositories/custom_field_repository_impl.dart' as _i430;
import 'data/repositories/form_repository_impl.dart' as _i313;
import 'data/repositories/gamification_repository_impl.dart' as _i179;
import 'data/repositories/nlp_repository_impl.dart' as _i693;
import 'data/repositories/notification_repository_impl.dart' as _i704;
import 'data/repositories/project_member_repository_impl.dart' as _i788;
import 'data/repositories/project_repository_impl.dart' as _i40;
import 'data/repositories/search_repository_impl.dart' as _i409;
import 'data/repositories/sprint_repository_impl.dart' as _i1030;
import 'data/repositories/sso_repository_impl.dart' as _i449;
import 'data/repositories/task_repository_impl.dart' as _i221;
import 'data/repositories/time_log_repository_impl.dart' as _i384;
import 'data/repositories/webhook_repository_impl.dart' as _i633;
import 'data/repositories/workload_repository_impl.dart' as _i773;
import 'data/repositories/workspace_repository_impl.dart' as _i753;
import 'data/services/billing_service.dart' as _i867;
import 'data/services/gamification_service.dart' as _i309;
import 'data/services/wiki_service.dart' as _i644;
import 'domain/repositories/audit_repository.dart' as _i819;
import 'domain/repositories/auth_repository.dart' as _i716;
import 'domain/repositories/automation_repository.dart' as _i402;
import 'domain/repositories/calendar_repository.dart' as _i916;
import 'domain/repositories/category_repository.dart' as _i615;
import 'domain/repositories/comment_repository.dart' as _i60;
import 'domain/repositories/custom_field_repository.dart' as _i834;
import 'domain/repositories/form_repository.dart' as _i221;
import 'domain/repositories/gamification_repository.dart' as _i1019;
import 'domain/repositories/nlp_repository.dart' as _i511;
import 'domain/repositories/notification_repository.dart' as _i82;
import 'domain/repositories/project_member_repository.dart' as _i51;
import 'domain/repositories/project_repository.dart' as _i17;
import 'domain/repositories/search_repository.dart' as _i844;
import 'domain/repositories/sprint_repository.dart' as _i585;
import 'domain/repositories/sso_repository.dart' as _i602;
import 'domain/repositories/task_repository.dart' as _i449;
import 'domain/repositories/time_log_repository.dart' as _i657;
import 'domain/repositories/webhook_repository.dart' as _i967;
import 'domain/repositories/workload_repository.dart' as _i42;
import 'domain/repositories/workspace_repository.dart' as _i713;
import 'domain/usecases/category/apply_category_usecase.dart' as _i696;
import 'domain/usecases/category/get_category_metrics_usecase.dart' as _i766;
import 'domain/usecases/category/get_category_suggestion_usecase.dart' as _i494;
import 'domain/usecases/category/get_suggestions_history_usecase.dart' as _i424;
import 'domain/usecases/category/submit_category_feedback_usecase.dart'
    as _i597;
import 'domain/usecases/change_password_usecase.dart' as _i825;
import 'domain/usecases/complete_calendar_oauth_usecase.dart' as _i812;
import 'domain/usecases/connect_calendar_usecase.dart' as _i913;
import 'domain/usecases/create_project_usecase.dart' as _i1015;
import 'domain/usecases/create_task_usecase.dart' as _i612;
import 'domain/usecases/delete_project_usecase.dart' as _i177;
import 'domain/usecases/delete_task_usecase.dart' as _i757;
import 'domain/usecases/disconnect_calendar_usecase.dart' as _i566;
import 'domain/usecases/finish_task_usecase.dart' as _i339;
import 'domain/usecases/gamification/get_gamification_stats_usecase.dart'
    as _i296;
import 'domain/usecases/gamification/get_leaderboard_usecase.dart' as _i447;
import 'domain/usecases/get_active_time_log_usecase.dart' as _i987;
import 'domain/usecases/get_calendar_connection_status_usecase.dart' as _i649;
import 'domain/usecases/get_calendar_events_usecase.dart' as _i587;
import 'domain/usecases/get_nlp_examples_usecase.dart' as _i764;
import 'domain/usecases/get_portfolio_stats_usecase.dart' as _i114;
import 'domain/usecases/get_productivity_heatmap_usecase.dart' as _i444;
import 'domain/usecases/get_profile_usecase.dart' as _i889;
import 'domain/usecases/get_project_by_id_usecase.dart' as _i356;
import 'domain/usecases/get_projects_usecase.dart' as _i32;
import 'domain/usecases/get_resource_allocation_usecase.dart' as _i654;
import 'domain/usecases/get_task_by_id_usecase.dart' as _i199;
import 'domain/usecases/get_tasks_by_project_usecase.dart' as _i725;
import 'domain/usecases/get_time_logs_by_task_usecase.dart' as _i630;
import 'domain/usecases/get_user_workload_usecase.dart' as _i971;
import 'domain/usecases/get_workload_stats_usecase.dart' as _i353;
import 'domain/usecases/get_workspace_tasks_usecase.dart' as _i666;
import 'domain/usecases/login_usecase.dart' as _i883;
import 'domain/usecases/logout_usecase.dart' as _i808;
import 'domain/usecases/parse_task_instruction_usecase.dart' as _i82;
import 'domain/usecases/register_usecase.dart' as _i784;
import 'domain/usecases/sprint/create_sprint_usecase.dart' as _i144;
import 'domain/usecases/sprint/get_backlog_usecase.dart' as _i408;
import 'domain/usecases/sprint/get_sprints_by_project_usecase.dart' as _i514;
import 'domain/usecases/sprint/manage_sprint_tasks_usecase.dart' as _i27;
import 'domain/usecases/sprint/manage_sprint_usecase.dart' as _i687;
import 'domain/usecases/start_timer_usecase.dart' as _i137;
import 'domain/usecases/stop_timer_usecase.dart' as _i838;
import 'domain/usecases/update_profile_usecase.dart' as _i567;
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
import 'domain/usecases/workspace/remove_member.dart' as _i37;
import 'domain/usecases/workspace/set_active_workspace.dart' as _i245;
import 'domain/usecases/workspace/update_member_role.dart' as _i905;
import 'domain/usecases/workspace/update_workspace.dart' as _i1066;
import 'features/chat/data/datasources/chat_remote_data_source.dart' as _i1000;
import 'features/chat/data/repositories/chat_repository_impl.dart' as _i382;
import 'features/chat/domain/repositories/chat_repository.dart' as _i453;
import 'features/chat/domain/usecases/get_channels.dart' as _i924;
import 'features/chat/domain/usecases/get_messages.dart' as _i537;
import 'features/chat/domain/usecases/send_message.dart' as _i422;
import 'features/chat/presentation/bloc/chat_bloc.dart' as _i1026;
import 'features/forms/data/datasources/form_remote_data_source.dart' as _i1005;
import 'features/forms/data/repositories/form_repository_impl.dart' as _i1001;
import 'features/forms/domain/repositories/form_repository.dart' as _i807;
import 'features/forms/domain/usecases/create_form.dart' as _i180;
import 'features/forms/domain/usecases/delete_form.dart' as _i60;
import 'features/forms/domain/usecases/get_form_by_id.dart' as _i753;
import 'features/forms/domain/usecases/get_forms_by_project.dart' as _i692;
import 'features/forms/domain/usecases/get_public_form.dart' as _i212;
import 'features/forms/domain/usecases/submit_public_form.dart' as _i881;
import 'features/forms/domain/usecases/update_form.dart' as _i985;
import 'features/forms/presentation/bloc/form_bloc.dart' as _i77;
import 'features/projects/presentation/blocs/project_bloc.dart' as _i328;
import 'features/projects/presentation/blocs/sprint/sprint_bloc.dart' as _i709;
import 'features/search/presentation/blocs/search_bloc.dart' as _i807;
import 'features/tasks/presentation/blocs/task_bloc.dart' as _i100;
import 'features/workspace/data/datasources/workspace_remote_datasource.dart'
    as _i398;
import 'features/workspace/presentation/bloc/workspace_bloc.dart' as _i207;
import 'presentation/bloc/audit/audit_bloc.dart' as _i977;
import 'presentation/bloc/auth/auth_bloc.dart' as _i605;
import 'presentation/bloc/automation/automation_bloc.dart' as _i157;
import 'presentation/bloc/calendar/calendar_bloc.dart' as _i659;
import 'presentation/bloc/category/category_bloc.dart' as _i116;
import 'presentation/bloc/comment/comment_bloc.dart' as _i462;
import 'presentation/bloc/conflict/conflict_bloc.dart' as _i774;
import 'presentation/bloc/custom_field/custom_field_bloc.dart' as _i404;
import 'presentation/bloc/gamification/gamification_bloc.dart' as _i589;
import 'presentation/bloc/notification/notification_bloc.dart' as _i571;
import 'presentation/bloc/sso/sso_bloc.dart' as _i66;
import 'presentation/bloc/task/task_bloc.dart' as _i944;
import 'presentation/bloc/time_tracking/time_tracking_bloc.dart' as _i808;
import 'presentation/bloc/webhook/webhook_bloc.dart' as _i890;
import 'presentation/bloc/workload/workload_bloc.dart' as _i107;
import 'presentation/bloc/workspace_invitation/workspace_invitation_bloc.dart'
    as _i953;
import 'presentation/bloc/workspace_member/workspace_member_bloc.dart' as _i53;
import 'presentation/blocs/project_member/project_member_bloc.dart' as _i124;
import 'presentation/providers/theme_provider.dart' as _i971;
import 'presentation/providers/workspace_context.dart' as _i34;
import 'presentation/services/report_service.dart' as _i123;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i454.CacheManager>(() => _i454.CacheManager());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => registerModule.secureStorage);
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i892.FirebaseMessaging>(
        () => registerModule.firebaseMessaging);
    gh.lazySingleton<_i738.ConflictResolutionService>(
        () => _i738.ConflictResolutionService());
    gh.lazySingleton<_i618.WorkspaceCacheDataSource>(
        () => _i618.WorkspaceCacheDataSourceImpl(gh<_i454.CacheManager>()));
    gh.factory<_i971.ThemeProvider>(
        () => _i971.ThemeProvider(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i255.ProjectCacheDataSource>(
        () => _i255.ProjectCacheDataSourceImpl(gh<_i454.CacheManager>()));
    gh.factory<_i774.ConflictBloc>(
        () => _i774.ConflictBloc(gh<_i738.ConflictResolutionService>()));
    gh.lazySingleton<_i314.TaskCacheDataSource>(
        () => _i314.TaskCacheDataSourceImpl(gh<_i454.CacheManager>()));
    gh.lazySingleton<_i268.WorkspaceLocalDataSource>(() =>
        _i268.WorkspaceLocalDataSourceImpl(gh<_i460.SharedPreferences>()));
    gh.singleton<_i45.DioClient>(
        () => _i45.DioClient(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i391.WorkspaceRemoteDataSource>(
        () => _i391.WorkspaceRemoteDataSourceImpl(gh<_i45.DioClient>()));
    gh.lazySingleton<_i127.AuthRemoteDataSource>(
        () => _i127.AuthRemoteDataSourceImpl(gh<_i45.DioClient>()));
    gh.singleton<_i1023.AuthInterceptor>(
        () => registerModule.authInterceptor(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i406.LastRouteService>(() =>
        registerModule.lastRouteService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i848.SocketService>(
        () => registerModule.socketService(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i524.ConnectivityService>(
        () => _i524.ConnectivityService(gh<_i895.Connectivity>()));
    gh.factory<_i867.BillingService>(
        () => _i867.BillingService(gh<InvalidType>()));
    gh.factory<_i309.GamificationService>(
        () => _i309.GamificationService(gh<InvalidType>()));
    gh.factory<_i644.WikiService>(() => _i644.WikiService(gh<InvalidType>()));
    gh.factory<_i318.CalendarRemoteDataSource>(
        () => _i318.CalendarRemoteDataSource(gh<_i45.DioClient>()));
    gh.factory<_i1070.GamificationRemoteDataSource>(
        () => _i1070.GamificationRemoteDataSource(gh<_i45.DioClient>()));
    gh.factory<_i233.WorkloadRemoteDataSource>(
        () => _i233.WorkloadRemoteDataSource(gh<_i45.DioClient>()));
    gh.lazySingleton<_i1019.GamificationRepository>(() =>
        _i179.GamificationRepositoryImpl(
            gh<_i1070.GamificationRemoteDataSource>()));
    gh.lazySingleton<_i716.AuthRepository>(() => _i145.AuthRepositoryImpl(
          gh<_i127.AuthRemoteDataSource>(),
          gh<_i558.FlutterSecureStorage>(),
          gh<_i460.SharedPreferences>(),
        ));
    gh.lazySingleton<_i714.TimeLogRemoteDataSource>(
        () => _i714.TimeLogRemoteDataSourceImpl(gh<_i45.DioClient>()));
    gh.factory<_i916.CalendarRepository>(() =>
        _i365.CalendarRepositoryImpl(gh<_i318.CalendarRemoteDataSource>()));
    gh.factory<_i889.GetProfileUseCase>(
        () => _i889.GetProfileUseCase(gh<_i716.AuthRepository>()));
    gh.factory<_i883.LoginUseCase>(
        () => _i883.LoginUseCase(gh<_i716.AuthRepository>()));
    gh.factory<_i808.LogoutUseCase>(
        () => _i808.LogoutUseCase(gh<_i716.AuthRepository>()));
    gh.factory<_i784.RegisterUseCase>(
        () => _i784.RegisterUseCase(gh<_i716.AuthRepository>()));
    gh.factory<_i296.GetGamificationStatsUseCase>(() =>
        _i296.GetGamificationStatsUseCase(gh<_i1019.GamificationRepository>()));
    gh.factory<_i447.GetLeaderboardUseCase>(
        () => _i447.GetLeaderboardUseCase(gh<_i1019.GamificationRepository>()));
    gh.singleton<_i871.ApiClient>(() => registerModule.apiClient(
          gh<_i1023.AuthInterceptor>(),
          gh<_i558.FlutterSecureStorage>(),
          gh<_i406.LastRouteService>(),
        ));
    gh.lazySingleton<_i657.TimeLogRepository>(
        () => _i384.TimeLogRepositoryImpl(gh<_i714.TimeLogRemoteDataSource>()));
    gh.factory<_i589.GamificationBloc>(() => _i589.GamificationBloc(
          getGamificationStats: gh<_i296.GetGamificationStatsUseCase>(),
          getLeaderboard: gh<_i447.GetLeaderboardUseCase>(),
        ));
    gh.factory<_i42.WorkloadRepository>(() =>
        _i773.WorkloadRepositoryImpl(gh<_i233.WorkloadRemoteDataSource>()));
    gh.lazySingleton<_i1000.ChatRemoteDataSource>(() =>
        _i1000.ChatRemoteDataSourceImpl(apiClient: gh<_i871.ApiClient>()));
    gh.lazySingleton<_i747.SprintRemoteDataSource>(
        () => _i747.SprintRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.singleton<_i361.Dio>(() => registerModule.dio(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i993.AuditRemoteDataSource>(
        () => _i993.AuditRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i825.ChangePasswordUseCase>(
        () => _i825.ChangePasswordUseCase(gh<_i716.AuthRepository>()));
    gh.lazySingleton<_i567.UpdateProfileUseCase>(
        () => _i567.UpdateProfileUseCase(gh<_i716.AuthRepository>()));
    gh.lazySingleton<_i1005.FormRemoteDataSource>(
        () => _i1005.FormRemoteDataSourceImpl(gh<_i871.ApiClient>()));
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
    gh.lazySingleton<_i31.ProjectMemberRemoteDataSource>(
        () => _i31.ProjectMemberRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i232.SearchRemoteDataSource>(
        () => _i232.SearchRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i819.AuditRepository>(
        () => _i71.AuditRepositoryImpl(gh<_i993.AuditRemoteDataSource>()));
    gh.lazySingleton<_i325.CustomFieldRemoteDataSource>(
        () => _i325.CustomFieldRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i959.PushNotificationRemoteDataSource>(() =>
        _i959.PushNotificationRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i871.WebhookRemoteDataSource>(
        () => _i871.WebhookRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i568.AutomationRemoteDataSource>(
        () => _i568.AutomationRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i976.CommentRemoteDataSource>(
        () => _i976.CommentRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.factory<_i605.AuthBloc>(() => _i605.AuthBloc(
          gh<_i883.LoginUseCase>(),
          gh<_i784.RegisterUseCase>(),
          gh<_i889.GetProfileUseCase>(),
          gh<_i808.LogoutUseCase>(),
          gh<_i567.UpdateProfileUseCase>(),
          gh<_i825.ChangePasswordUseCase>(),
        ));
    gh.lazySingleton<_i922.ProjectRemoteDataSource>(
        () => _i922.ProjectRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i1007.TaskRemoteDataSource>(
        () => _i1007.TaskRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i918.SsoRemoteDataSource>(
        () => _i918.SsoRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i1050.CategoryRemoteDataSource>(
        () => _i1050.CategoryRemoteDataSource(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i398.WorkspaceRemoteDataSource>(
        () => _i398.WorkspaceRemoteDataSource(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i123.ReportService>(
        () => _i123.ReportService(gh<_i361.Dio>()));
    gh.lazySingleton<_i23.NLPRemoteDataSource>(
        () => _i23.NLPRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i585.SprintRepository>(
        () => _i1030.SprintRepositoryImpl(gh<_i747.SprintRemoteDataSource>()));
    gh.lazySingleton<_i888.NotificationRemoteDataSource>(
        () => _i888.NotificationRemoteDataSourceImpl(gh<_i871.ApiClient>()));
    gh.lazySingleton<_i60.CommentRepository>(
        () => _i329.CommentRepositoryImpl(gh<_i976.CommentRemoteDataSource>()));
    gh.factory<_i659.CalendarBloc>(() => _i659.CalendarBloc(
          gh<_i913.ConnectCalendarUseCase>(),
          gh<_i566.DisconnectCalendarUseCase>(),
          gh<_i649.GetCalendarConnectionStatusUseCase>(),
          gh<_i587.GetCalendarEventsUseCase>(),
          gh<_i812.CompleteCalendarOAuthUseCase>(),
        ));
    gh.lazySingleton<_i615.CategoryRepository>(() =>
        _i1032.CategoryRepositoryImpl(gh<_i1050.CategoryRemoteDataSource>()));
    gh.lazySingleton<_i1056.FormRemoteDataSource>(
        () => _i1056.FormRemoteDataSourceImpl(dio: gh<_i361.Dio>()));
    gh.lazySingleton<_i844.SearchRepository>(
        () => _i409.SearchRepositoryImpl(gh<_i232.SearchRemoteDataSource>()));
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
    gh.lazySingleton<_i444.GetProductivityHeatmapUseCase>(() =>
        _i444.GetProductivityHeatmapUseCase(gh<_i657.TimeLogRepository>()));
    gh.lazySingleton<_i43.FirebaseMessagingService>(
        () => _i43.FirebaseMessagingService(
              gh<_i892.FirebaseMessaging>(),
              gh<_i959.PushNotificationRemoteDataSource>(),
            ));
    gh.factory<_i808.TimeTrackingBloc>(() => _i808.TimeTrackingBloc(
          gh<_i137.StartTimerUseCase>(),
          gh<_i838.StopTimerUseCase>(),
          gh<_i339.FinishTaskUseCase>(),
          gh<_i630.GetTimeLogsByTaskUseCase>(),
          gh<_i987.GetActiveTimeLogUseCase>(),
        ));
    gh.lazySingleton<_i221.FormRepository>(() => _i313.FormRepositoryImpl(
        remoteDataSource: gh<_i1056.FormRemoteDataSource>()));
    gh.factory<_i462.CommentBloc>(
        () => _i462.CommentBloc(gh<_i60.CommentRepository>()));
    gh.lazySingleton<_i807.FormRepository>(
        () => _i1001.FormRepositoryImpl(gh<_i1005.FormRemoteDataSource>()));
    gh.factory<_i977.AuditBloc>(
        () => _i977.AuditBloc(repository: gh<_i819.AuditRepository>()));
    gh.lazySingleton<_i51.ProjectMemberRepository>(() =>
        _i788.ProjectMemberRepositoryImpl(
            gh<_i31.ProjectMemberRemoteDataSource>()));
    gh.lazySingleton<_i453.ChatRepository>(() => _i382.ChatRepositoryImpl(
        remoteDataSource: gh<_i1000.ChatRemoteDataSource>()));
    gh.lazySingleton<_i82.NotificationRepository>(() =>
        _i704.NotificationRepositoryImpl(
            gh<_i888.NotificationRemoteDataSource>()));
    gh.lazySingleton<_i602.SsoRepository>(
        () => _i449.SsoRepositoryImpl(gh<_i918.SsoRemoteDataSource>()));
    gh.lazySingleton<_i834.CustomFieldRepository>(
        () => _i430.CustomFieldRepositoryImpl(
              gh<_i325.CustomFieldRemoteDataSource>(),
              gh<_i524.ConnectivityService>(),
            ));
    gh.lazySingleton<_i402.AutomationRepository>(
        () => _i590.AutomationRepositoryImpl(
              gh<_i568.AutomationRemoteDataSource>(),
              gh<_i524.ConnectivityService>(),
            ));
    gh.lazySingleton<_i203.SyncOperationExecutor>(
        () => _i203.SyncOperationExecutor(
              gh<_i391.WorkspaceRemoteDataSource>(),
              gh<_i922.ProjectRemoteDataSource>(),
              gh<_i1007.TaskRemoteDataSource>(),
            ));
    gh.factory<_i66.SsoBloc>(() => _i66.SsoBloc(gh<_i602.SsoRepository>()));
    gh.factory<_i807.SearchBloc>(
        () => _i807.SearchBloc(gh<_i844.SearchRepository>()));
    gh.lazySingleton<_i180.CreateForm>(
        () => _i180.CreateForm(gh<_i807.FormRepository>()));
    gh.lazySingleton<_i60.DeleteForm>(
        () => _i60.DeleteForm(gh<_i807.FormRepository>()));
    gh.lazySingleton<_i692.GetFormsByProject>(
        () => _i692.GetFormsByProject(gh<_i807.FormRepository>()));
    gh.lazySingleton<_i753.GetFormById>(
        () => _i753.GetFormById(gh<_i807.FormRepository>()));
    gh.lazySingleton<_i212.GetPublicForm>(
        () => _i212.GetPublicForm(gh<_i807.FormRepository>()));
    gh.lazySingleton<_i881.SubmitPublicForm>(
        () => _i881.SubmitPublicForm(gh<_i807.FormRepository>()));
    gh.lazySingleton<_i985.UpdateForm>(
        () => _i985.UpdateForm(gh<_i807.FormRepository>()));
    gh.lazySingleton<_i967.WebhookRepository>(() => _i633.WebhookRepositoryImpl(
          gh<_i871.WebhookRemoteDataSource>(),
          gh<_i524.ConnectivityService>(),
        ));
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
    gh.factory<_i144.CreateSprintUseCase>(
        () => _i144.CreateSprintUseCase(gh<_i585.SprintRepository>()));
    gh.factory<_i408.GetBacklogUseCase>(
        () => _i408.GetBacklogUseCase(gh<_i585.SprintRepository>()));
    gh.factory<_i514.GetSprintsByProjectUseCase>(
        () => _i514.GetSprintsByProjectUseCase(gh<_i585.SprintRepository>()));
    gh.factory<_i27.ManageSprintTasksUseCase>(
        () => _i27.ManageSprintTasksUseCase(gh<_i585.SprintRepository>()));
    gh.factory<_i687.ManageSprintUseCase>(
        () => _i687.ManageSprintUseCase(gh<_i585.SprintRepository>()));
    gh.factory<_i571.NotificationBloc>(
        () => _i571.NotificationBloc(gh<_i82.NotificationRepository>()));
    gh.factory<_i77.FormBloc>(() => _i77.FormBloc(
          getFormsByProject: gh<_i692.GetFormsByProject>(),
          getFormById: gh<_i753.GetFormById>(),
          createForm: gh<_i180.CreateForm>(),
          updateForm: gh<_i985.UpdateForm>(),
          deleteForm: gh<_i60.DeleteForm>(),
          getPublicForm: gh<_i212.GetPublicForm>(),
          submitPublicForm: gh<_i881.SubmitPublicForm>(),
        ));
    gh.lazySingleton<_i924.GetChannelsUseCase>(
        () => _i924.GetChannelsUseCase(gh<_i453.ChatRepository>()));
    gh.lazySingleton<_i537.GetMessagesUseCase>(
        () => _i537.GetMessagesUseCase(gh<_i453.ChatRepository>()));
    gh.lazySingleton<_i422.SendMessageUseCase>(
        () => _i422.SendMessageUseCase(gh<_i453.ChatRepository>()));
    gh.factory<_i1026.ChatBloc>(() => _i1026.ChatBloc(
          gh<_i924.GetChannelsUseCase>(),
          gh<_i537.GetMessagesUseCase>(),
          gh<_i422.SendMessageUseCase>(),
          gh<_i848.SocketService>(),
        ));
    gh.factory<_i404.CustomFieldBloc>(
        () => _i404.CustomFieldBloc(gh<_i834.CustomFieldRepository>()));
    gh.factory<_i124.ProjectMemberBloc>(
        () => _i124.ProjectMemberBloc(gh<_i51.ProjectMemberRepository>()));
    gh.lazySingleton<_i511.NLPRepository>(() => _i693.NLPRepositoryImpl(
          gh<_i23.NLPRemoteDataSource>(),
          gh<_i524.ConnectivityService>(),
        ));
    gh.factory<_i764.GetNLPExamplesUseCase>(
        () => _i764.GetNLPExamplesUseCase(gh<_i511.NLPRepository>()));
    gh.factory<_i82.ParseTaskInstructionUseCase>(
        () => _i82.ParseTaskInstructionUseCase(gh<_i511.NLPRepository>()));
    gh.factory<_i107.WorkloadBloc>(() => _i107.WorkloadBloc(
          gh<_i654.GetResourceAllocationUseCase>(),
          gh<_i971.GetUserWorkloadUseCase>(),
          gh<_i353.GetWorkloadStatsUseCase>(),
        ));
    gh.lazySingleton<_i223.SyncManager>(() => _i223.SyncManager(
          gh<_i524.ConnectivityService>(),
          gh<_i203.SyncOperationExecutor>(),
        ));
    gh.factory<_i890.WebhookBloc>(
        () => _i890.WebhookBloc(gh<_i967.WebhookRepository>()));
    gh.factory<_i157.AutomationBloc>(
        () => _i157.AutomationBloc(gh<_i402.AutomationRepository>()));
    gh.lazySingleton<_i449.TaskRepository>(() => _i221.TaskRepositoryImpl(
          gh<_i1007.TaskRemoteDataSource>(),
          gh<_i314.TaskCacheDataSource>(),
          gh<_i524.ConnectivityService>(),
          gh<_i223.SyncManager>(),
        ));
    gh.lazySingleton<_i659.SyncNotificationService>(
        () => _i659.SyncNotificationService(gh<_i223.SyncManager>()));
    gh.factory<_i100.TaskBloc>(
        () => _i100.TaskBloc(taskRepository: gh<_i449.TaskRepository>()));
    gh.factory<_i116.CategoryBloc>(() => _i116.CategoryBloc(
          gh<_i494.GetCategorySuggestionUseCase>(),
          gh<_i696.ApplyCategoryUseCase>(),
          gh<_i597.SubmitCategoryFeedbackUseCase>(),
          gh<_i766.GetCategoryMetricsUseCase>(),
          gh<_i424.GetSuggestionsHistoryUseCase>(),
        ));
    gh.factory<_i709.SprintBloc>(() => _i709.SprintBloc(
          getSprints: gh<_i514.GetSprintsByProjectUseCase>(),
          createSprint: gh<_i144.CreateSprintUseCase>(),
          manageSprint: gh<_i687.ManageSprintUseCase>(),
          manageSprintTasks: gh<_i27.ManageSprintTasksUseCase>(),
          getBacklog: gh<_i408.GetBacklogUseCase>(),
        ));
    gh.lazySingleton<_i17.ProjectRepository>(() => _i40.ProjectRepositoryImpl(
          gh<_i922.ProjectRemoteDataSource>(),
          gh<_i255.ProjectCacheDataSource>(),
          gh<_i524.ConnectivityService>(),
          gh<_i223.SyncManager>(),
        ));
    gh.lazySingleton<_i713.WorkspaceRepository>(
        () => _i753.WorkspaceRepositoryImpl(
              gh<_i391.WorkspaceRemoteDataSource>(),
              gh<_i268.WorkspaceLocalDataSource>(),
              gh<_i618.WorkspaceCacheDataSource>(),
              gh<_i524.ConnectivityService>(),
              gh<_i223.SyncManager>(),
            ));
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
    gh.lazySingleton<_i114.GetPortfolioStatsUseCase>(
        () => _i114.GetPortfolioStatsUseCase(gh<_i17.ProjectRepository>()));
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
    gh.factory<_i37.RemoveMemberUseCase>(
        () => _i37.RemoveMemberUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i245.SetActiveWorkspaceUseCase>(
        () => _i245.SetActiveWorkspaceUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i905.UpdateMemberRoleUseCase>(
        () => _i905.UpdateMemberRoleUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i1066.UpdateWorkspaceUseCase>(
        () => _i1066.UpdateWorkspaceUseCase(gh<_i713.WorkspaceRepository>()));
    gh.factory<_i53.WorkspaceMemberBloc>(
        () => _i53.WorkspaceMemberBloc(gh<_i517.GetWorkspaceMembersUseCase>()));
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
    gh.factory<_i666.GetWorkspaceTasksUseCase>(
        () => _i666.GetWorkspaceTasksUseCase(
              gh<_i32.GetProjectsUseCase>(),
              gh<_i725.GetTasksByProjectUseCase>(),
            ));
    gh.factory<_i328.ProjectBloc>(() => _i328.ProjectBloc(
          gh<_i32.GetProjectsUseCase>(),
          gh<_i356.GetProjectByIdUseCase>(),
          gh<_i1015.CreateProjectUseCase>(),
          gh<_i589.UpdateProjectUseCase>(),
          gh<_i177.DeleteProjectUseCase>(),
          gh<_i114.GetPortfolioStatsUseCase>(),
        ));
    gh.factory<_i953.WorkspaceInvitationBloc>(
        () => _i953.WorkspaceInvitationBloc(
              gh<_i591.GetPendingInvitationsUseCase>(),
              gh<_i359.CreateInvitationUseCase>(),
              gh<_i927.AcceptInvitationUseCase>(),
              gh<_i9.DeclineInvitationUseCase>(),
            ));
    gh.factory<_i944.TaskBloc>(() => _i944.TaskBloc(
          gh<_i725.GetTasksByProjectUseCase>(),
          gh<_i666.GetWorkspaceTasksUseCase>(),
          gh<_i199.GetTaskByIdUseCase>(),
          gh<_i612.CreateTaskUseCase>(),
          gh<_i1018.UpdateTaskUseCase>(),
          gh<_i757.DeleteTaskUseCase>(),
          gh<_i449.TaskRepository>(),
        ));
    gh.lazySingleton<_i207.WorkspaceBloc>(() => _i207.WorkspaceBloc(
          dataSource: gh<_i398.WorkspaceRemoteDataSource>(),
          getUserWorkspaces: gh<_i820.GetUserWorkspacesUseCase>(),
          createWorkspace: gh<_i225.CreateWorkspaceUseCase>(),
          setActiveWorkspace: gh<_i245.SetActiveWorkspaceUseCase>(),
          getActiveWorkspace: gh<_i890.GetActiveWorkspaceUseCase>(),
        ));
    gh.singleton<_i34.WorkspaceContext>(
        () => _i34.WorkspaceContext(gh<_i207.WorkspaceBloc>()));
    return this;
  }
}

class _$RegisterModule extends _i854.RegisterModule {}
