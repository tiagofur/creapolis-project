// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Creapolis';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle => 'Manage notifications';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSubtitle => 'Light/Dark mode';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpSubtitle => 'Help center and support';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacySubtitle => 'Privacy policy';

  @override
  String get privacyContent => 'We manage your data with best practices.\n- Data use limited to functionality.\n- No third-party sharing without consent.\n- You can manage preferences in Settings.\n\nFor details, see the official site.';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get workspaceActive => 'Active Workspace';

  @override
  String get workspaceRequiredTitle => 'Workspace required';

  @override
  String get workspaceRequiredMessage => 'To create tasks, select or create a workspace first.';

  @override
  String get createWorkspace => 'Create Workspace';

  @override
  String get selectProject => 'Select a project';

  @override
  String get addWidgetCreateProject => 'Add Widget / Create Project';

  @override
  String get updatingProjectsSnack => 'Updating project list...';

  @override
  String get newTaskTooltip => 'New task';

  @override
  String get open => 'Open';

  @override
  String taskCreatedSnack(Object title) {
    return 'Task \"$title\" created';
  }

  @override
  String get viewMore => 'View more';

  @override
  String percentageCompleted(Object percent) {
    return '$percent% completed';
  }

  @override
  String get moreTitle => 'More options';

  @override
  String get managementSection => 'Management';

  @override
  String get infoSection => 'Information';

  @override
  String get workspacesTitle => 'Workspaces';

  @override
  String get workspacesSubtitle => 'Manage workspaces';

  @override
  String get invitationsTitle => 'Invitations';

  @override
  String get invitationsSubtitle => 'View pending invitations';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Application settings';

  @override
  String get customizationMetricsTitle => 'Customization Metrics';

  @override
  String get customizationMetricsSubtitle => 'UI usage statistics';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutSubtitle => 'Application information';

  @override
  String get logout => 'Log out';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get helpContent => 'Visit our help center for guides and support. Direct links from the app will be integrated soon.';

  @override
  String get recentActivityTitle => 'Recent Activity';

  @override
  String get viewAll => 'View all';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get activityCompleted => 'Task completed';

  @override
  String get activityUpdated => 'Task updated';

  @override
  String minutesAgo(Object count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(Object count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String get myTasksTitle => 'My Tasks';

  @override
  String get allClear => 'All clear!';

  @override
  String get myProjectsTitle => 'My Projects';

  @override
  String get progressLabel => 'Progress';

  @override
  String get dailySummaryTitle => 'Daily Summary';

  @override
  String get tasksLabel => 'Tasks';

  @override
  String get projectsLabel => 'Projects';

  @override
  String get completedLabel => 'Completed';

  @override
  String get overallProgress => 'Overall Progress';

  @override
  String get upcomingTasksTitle => 'Upcoming Tasks';

  @override
  String get noPendingTasks => 'No pending tasks! 🎉';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get myTasksTab => 'My Tasks';

  @override
  String get allTasksTab => 'All';

  @override
  String get createTaskTooltip => 'Create task';

  @override
  String get searchTasksTooltip => 'Search tasks';

  @override
  String get filtersTooltip => 'Filters';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get sortByDate => 'By date';

  @override
  String get sortByPriority => 'By priority';

  @override
  String get sortByName => 'By name';

  @override
  String get selectWorkspaceTitle => 'Select a workspace';

  @override
  String get selectWorkspaceMessage => 'Choose a workspace from the top switcher to view available tasks.';

  @override
  String get retry => 'Retry';

  @override
  String get loadTasksErrorTitle => 'Tasks could not be loaded';

  @override
  String get loginRequiredTitle => 'Log in to view your tasks';

  @override
  String get loginRequiredMessage => 'You need to log in to see tasks assigned to you.';

  @override
  String get goToLogin => 'Go to login';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get noDateGroup => 'Overdue or no date';

  @override
  String get all => 'All';

  @override
  String get inProgress => 'In progress';

  @override
  String get planned => 'Planned';

  @override
  String get completed => 'Completed';

  @override
  String get priorityCritical => 'Critical';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get search => 'Search';

  @override
  String get apply => 'Apply';

  @override
  String get clear => 'Clear';

  @override
  String get noResultsTitle => 'No results';

  @override
  String get noResultsMessage => 'We couldn\'t find tasks with the current filters.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noAssignedTasksTitle => 'No assigned tasks';

  @override
  String get noAssignedTasksMessage => 'You have no tasks assigned in this workspace.';

  @override
  String get createTask => 'Create task';

  @override
  String get confirmCompleteTitle => 'Complete Task';

  @override
  String confirmCompleteMessage(Object title) {
    return 'Mark \"$title\" as completed?';
  }

  @override
  String get confirmDeleteTitle => 'Delete Task';

  @override
  String confirmDeleteMessage(Object title) {
    return 'Delete \"$title\"?\n\nThis action cannot be undone.';
  }

  @override
  String get complete => 'Complete';

  @override
  String get delete => 'Delete';

  @override
  String get tasksUpdatedSnack => 'Tasks updated';

  @override
  String get tasksUpdateFailedSnack => 'We couldn\'t update tasks. Please try again.';

  @override
  String get taskAlreadyCompleted => 'Task is already completed';

  @override
  String get noPermissionsCreateTasks => 'You don\'t have permissions to create tasks in this workspace.';

  @override
  String get updatingWorkspaceTasks => 'We are updating workspace tasks. Please try again in a few seconds.';

  @override
  String get mustSelectWorkspaceMessage => 'You must select an active workspace before creating tasks.';

  @override
  String get viewWorkspaces => 'View workspaces';

  @override
  String get needProjectTitle => 'A project is required';

  @override
  String get needProjectMessage => 'Create a project first to register tasks in this workspace.';

  @override
  String get goToProjects => 'Go to projects';

  @override
  String get quickActionsTitle => 'Quick Actions';

  @override
  String get createProject => 'Create project';

  @override
  String get inviteMember => 'Invite Member';

  @override
  String get loadDataError => 'Error loading data';

  @override
  String get noTasksToShow => 'No tasks to show';

  @override
  String get noDataWithFilters => 'No data with applied filters';

  @override
  String get priorityDistributionTitle => 'Priority Distribution';

  @override
  String get weeklyProgressTitle => 'Weekly Progress';

  @override
  String get tasksCompletedPerDay => 'Tasks completed per day';

  @override
  String tasksCount(Object count) {
    return '$count tasks';
  }

  @override
  String get taskMetricsTitle => 'Task Metrics';

  @override
  String get filteredLabel => 'Filtered';

  @override
  String get loadMetricsError => 'Error loading metrics';

  @override
  String completedOfTotalTasks(Object completed, Object total) {
    return '$completed of $total tasks';
  }

  @override
  String tasksDelayedCount(Object count) {
    return '$count delayed';
  }

  @override
  String get notificationPreferencesTitle => 'Notification Preferences';

  @override
  String get notificationChannels => 'Notification Channels';

  @override
  String get pushNotificationsTitle => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle => 'Receive real-time notifications on this device';

  @override
  String get emailNotificationsTitle => 'Email Notifications';

  @override
  String get emailNotificationsSubtitle => 'Receive summaries and alerts by email';

  @override
  String get notificationTypes => 'Notification Types';

  @override
  String get notificationTypesSubtitle => 'Select which events you want to be notified about';

  @override
  String get mentionNotifications => 'Mentions';

  @override
  String get mentionNotificationsSubtitle => 'When someone mentions you in a comment';

  @override
  String get commentReplyNotifications => 'Comment replies';

  @override
  String get commentReplyNotificationsSubtitle => 'When someone replies to your comment';

  @override
  String get taskAssignedNotifications => 'Task assigned';

  @override
  String get taskAssignedNotificationsSubtitle => 'When a new task is assigned to you';

  @override
  String get taskUpdatedNotifications => 'Task updated';

  @override
  String get taskUpdatedNotificationsSubtitle => 'When a task you follow is updated';

  @override
  String get projectUpdatedNotifications => 'Project updated';

  @override
  String get projectUpdatedNotificationsSubtitle => 'When a project is updated';

  @override
  String get systemNotifications => 'System';

  @override
  String get systemNotificationsSubtitle => 'Important updates and announcements';

  @override
  String get preferencesUpdated => 'Preferences updated';

  @override
  String preferencesLoadError(Object error) {
    return 'Error loading preferences: $error';
  }

  @override
  String preferencesUpdateError(Object error) {
    return 'Error updating preferences: $error';
  }

  @override
  String get pushPermissionsHint => 'Push notifications require system permissions. If you don\'t receive notifications, check your device settings.';

  @override
  String get selectTimezoneTitle => 'Select time zone';

  @override
  String get timeTrackingTitle => 'Time Tracking';

  @override
  String get workSessionsTitle => 'Work Sessions';

  @override
  String get noPermissionsTrackTime => 'You don\'t have permissions to track time in this workspace';

  @override
  String get startLabel => 'Start';

  @override
  String get stopLabel => 'Stop';

  @override
  String get finishLabel => 'Finish';

  @override
  String get hoursProgressLabel => 'Hours Progress';

  @override
  String get overtimeHoursLabel => 'Overtime hours';

  @override
  String get finishTaskTitle => 'Finish Task';

  @override
  String get finishTaskMessage => 'Are you sure you want to finish this task? This will stop any active timer and mark the task as completed.';

  @override
  String get taskFinishedSuccessSnack => 'Task finished successfully!';

  @override
  String get taskDetailTitle => 'Task Detail';

  @override
  String get overviewTab => 'Overview';

  @override
  String get timeTrackingTab => 'Time Tracking';

  @override
  String get dependenciesTab => 'Dependencies';

  @override
  String get loadTaskErrorTitle => 'Error loading task';

  @override
  String get dependenciesTitle => 'Dependencies';

  @override
  String dependenciesCount(Object count) {
    return '$count dependencies';
  }

  @override
  String taskNumber(Object id) {
    return 'Task #$id';
  }

  @override
  String get noDependencies => 'No dependencies';

  @override
  String get descriptionTitle => 'Description';

  @override
  String get datesAndDurationTitle => 'Dates and Duration';

  @override
  String get startDateLabel => 'Start';

  @override
  String get endDateLabel => 'End';

  @override
  String get durationLabel => 'Duration';

  @override
  String durationInDays(Object count) {
    return '$count days';
  }

  @override
  String get assignedToLabel => 'Assigned to';

  @override
  String get pendingInvitationsTitle => 'Pending Invitations';

  @override
  String get refresh => 'Refresh';

  @override
  String joinedWorkspaceSnack(Object workspace) {
    return 'You\'ve joined \"$workspace\"';
  }

  @override
  String get invitationDeclinedSnack => 'Invitation declined';

  @override
  String get noPendingInvitationsTitle => 'No pending invitations';

  @override
  String get noPendingInvitationsMessage => 'When someone invites you to a workspace\nit will appear here';

  @override
  String get invitedByLabel => 'Invited by';

  @override
  String invitedAt(Object value) {
    return 'Invited $value';
  }

  @override
  String get invitationExpired => 'Expired';

  @override
  String expiresAt(Object value) {
    return 'Expires $value';
  }

  @override
  String get reject => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get invitationExpiredMessage => 'This invitation has expired';

  @override
  String get acceptInvitationTitle => 'Accept Invitation';

  @override
  String acceptInvitationMessage(Object role, Object workspace) {
    return 'Do you want to join \"$workspace\" as $role?';
  }

  @override
  String get declineInvitationTitle => 'Decline Invitation';

  @override
  String declineInvitationMessage(Object workspace) {
    return 'Are you sure you want to decline the invitation to \"$workspace\"?';
  }

  @override
  String get declineInvitationNote => 'The administrator can send you a new invitation in the future.';

  @override
  String get confirmDeclineLabel => 'Yes, Decline';

  @override
  String get tomorrow => 'tomorrow';

  @override
  String get yesterday => 'yesterday';

  @override
  String inHours(Object count, Object unit) {
    return 'in $count $unit';
  }

  @override
  String inMinutes(Object count, Object unit) {
    return 'in $count $unit';
  }

  @override
  String inDays(Object count, Object unit) {
    return 'in $count $unit';
  }

  @override
  String get workspaceMembersTitle => 'Workspace Members';

  @override
  String get closeSearch => 'Close search';

  @override
  String get filterByRole => 'Filter by role';

  @override
  String get ownersRoleLabel => 'Owners';

  @override
  String get adminsRoleLabel => 'Admins';

  @override
  String get membersRoleLabel => 'Members';

  @override
  String get guestsRoleLabel => 'Guests';

  @override
  String memberRoleUpdated(Object role, Object user) {
    return 'Role of $user updated to $role';
  }

  @override
  String get memberRemovedSnack => 'Member removed from workspace';

  @override
  String get youChip => 'You';

  @override
  String get activeChip => 'Active';

  @override
  String get changeRoleAction => 'Change Role';

  @override
  String get removeAction => 'Remove';

  @override
  String get noMembersWithRole => 'No members with that role';

  @override
  String get noMembersInWorkspace => 'No members in this workspace';

  @override
  String get tryAnotherFilter => 'Try another filter';

  @override
  String get invitePeopleToCollaborate => 'Invite people to collaborate';

  @override
  String changeRoleTitle(Object name) {
    return 'Change role of $name';
  }

  @override
  String get removeMemberTitle => 'Remove Member';

  @override
  String removeMemberConfirm(Object name) {
    return 'Are you sure you want to remove $name from the workspace?';
  }

  @override
  String get removeMemberNote => 'The user will lose access to all projects and tasks in this workspace.';

  @override
  String get removeMemberInviteAgainNote => 'You can invite them again in the future.';

  @override
  String get confirmRemoveLabel => 'Yes, Remove';

  @override
  String get searchMembersHint => 'Search members...';

  @override
  String invitationSentTo(Object email) {
    return 'Invitation sent to $email';
  }

  @override
  String membersCount(Object count) {
    return '$count members';
  }

  @override
  String get inviteeEmailLabel => 'Invitee email';

  @override
  String get inviteeEmailHint => 'example@email.com';

  @override
  String get enterEmailMessage => 'Please enter an email';

  @override
  String get enterValidEmailMessage => 'Please enter a valid email';

  @override
  String get workspaceRoleLabel => 'Workspace role';

  @override
  String get rolePermissionsTitle => 'Role permissions';

  @override
  String get adminRoleDesc => 'Full management except deleting workspace';

  @override
  String get memberRoleDesc => 'Create and manage projects and tasks';

  @override
  String get guestRoleDesc => 'View-only access';

  @override
  String get sendInvitation => 'Send Invitation';

  @override
  String get adminRoleCapability => 'Can manage members and settings';

  @override
  String get memberRoleCapability => 'Can create and manage projects';

  @override
  String get guestRoleCapability => 'View-only access';

  @override
  String get ownerRoleCapability => 'Full control of workspace';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get roleLabel => 'Role';

  @override
  String loadRolePrefsError(Object error) {
    return 'Error loading preferences: $error';
  }

  @override
  String get resetConfigTitle => 'Reset Configuration';

  @override
  String get resetConfigMessage => 'Do you want to reset all your configuration to your role defaults?\n\nThis will remove all your customizations.';

  @override
  String get reset => 'Reset';

  @override
  String get resetConfigSuccess => 'Configuration reset successfully';

  @override
  String get resetConfigError => 'Error resetting configuration';

  @override
  String get exportSuccessTitle => 'Export Successful';

  @override
  String get exportSuccessMessage => 'Your preferences have been exported successfully.';

  @override
  String get share => 'Share';

  @override
  String get shareSubject => 'My Creapolis preferences';

  @override
  String get shareText => 'Preferences file exported from Creapolis';

  @override
  String exportPrefsError(Object error) {
    return 'Error exporting preferences: $error';
  }

  @override
  String get importPrefsTitle => 'Import Preferences';

  @override
  String get importPrefsMessage => 'Importing preferences will replace your current configuration.\n\nDo you want to continue?';

  @override
  String get continueLabel => 'Continue';

  @override
  String get selectPrefsFileTitle => 'Select preferences file';

  @override
  String get filePathError => 'Could not get file path';

  @override
  String get importPrefsSuccess => 'Preferences imported successfully';

  @override
  String get importPrefsError => 'Error importing preferences - Check the file';

  @override
  String importPrefsErrorDetail(Object error) {
    return 'Error importing preferences: $error';
  }

  @override
  String get rolePreferencesTitle => 'Role-based Preferences';

  @override
  String get moreOptions => 'More options';

  @override
  String get resetToDefaults => 'Reset to defaults';

  @override
  String get exportPreferences => 'Export preferences';

  @override
  String get importPreferences => 'Import preferences';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String currentThemeLabel(Object theme) {
    return 'Current theme: $theme';
  }

  @override
  String usingCustomizationDefault(Object defaultTheme) {
    return 'You are using your customization (default: $defaultTheme)';
  }

  @override
  String get usingRoleDefault => 'Using your role default';

  @override
  String get revertToRoleDefault => 'Revert to role default';

  @override
  String get customizeTheme => 'Customize theme';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String widgetsConfigured(Object count) {
    return '$count widgets configured';
  }

  @override
  String get usingCustomization => 'You are using your customization';

  @override
  String get usingRoleDashboardDefault => 'Using your role default dashboard';

  @override
  String get customizeDashboard => 'Customize dashboard';

  @override
  String get exportImportTitle => 'Export / Import';

  @override
  String get exportImportDescription => 'Save or restore your full configuration. Useful to back up preferences or transfer them across devices.';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get howItWorksTitle => 'How it works';

  @override
  String get howItWorksStep1Title => '1. Base Configuration';

  @override
  String get howItWorksStep1Desc => 'Each role has an optimized default configuration.';

  @override
  String get howItWorksStep2Title => '2. Customization';

  @override
  String get howItWorksStep2Desc => 'You can change any configuration according to your preferences.';

  @override
  String get howItWorksStep3Title => '3. Indicators';

  @override
  String get howItWorksStep3Desc => 'Elements marked as \"Customized\" show what you have modified.';

  @override
  String get howItWorksStep4Title => '4. Reset';

  @override
  String get howItWorksStep4Desc => 'Use the reset button to return to role defaults.';

  @override
  String get howItWorksStep5Title => '5. Export/Import';

  @override
  String get howItWorksStep5Desc => 'Back up your configuration or transfer it across devices.';

  @override
  String get applicationLegalese => '© 2025 Creapolis. All rights reserved.';

  @override
  String get aboutContent => 'Creapolis is a project and task management tool designed to help teams collaborate effectively.';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to log out?';

  @override
  String get roleCustomizationTitle => 'Role Customization';

  @override
  String get roleCustomizationSubtitle => 'Customize your experience according to your role';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get navigationTypeTitle => 'Navigation type';

  @override
  String get navigationTypeDescription => 'Select how you prefer to navigate the app';

  @override
  String get sidebarTitle => 'Sidebar';

  @override
  String get sidebarSubtitle => 'Navigation menu on the side';

  @override
  String get bottomNavigationTitle => 'Bottom navigation';

  @override
  String get bottomNavigationSubtitle => 'Navigation menu at the bottom';

  @override
  String get integrationsTitle => 'Integrations';

  @override
  String get googleCalendarTitle => 'Google Calendar';

  @override
  String get googleCalendarSubtitle => 'Sync your events and availability';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connectGoogleCalendar => 'Connect Google Calendar';

  @override
  String connectedOn(Object date) {
    return 'Connected on $date';
  }

  @override
  String get cannotOpenBrowser => 'Could not open browser';

  @override
  String get googleCalendarAuthTitle => 'Google Calendar Authorization';

  @override
  String get googleCalendarAuthInstructions => 'The browser has been opened. Please authorize the application and copy the authorization code here:';

  @override
  String get authorizationCodeLabel => 'Authorization code';

  @override
  String get authorizationCodeHint => 'Paste the code here';

  @override
  String get connect => 'Connect';

  @override
  String get disconnectGoogleCalendarTitle => 'Disconnect Google Calendar';

  @override
  String get notificationsComingSoon => 'Notifications settings coming soon';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileComingSoon => 'Profile settings coming soon';

  @override
  String get aboutComingSoon => 'App information coming soon';

  @override
  String get googleCalendarConnected => 'Google Calendar connected successfully';

  @override
  String get googleCalendarDisconnected => 'Google Calendar disconnected';

  @override
  String get profileUserTitle => 'User Profile';

  @override
  String get languageTitle => 'Language';

  @override
  String get selectLanguageTitle => 'Select language';

  @override
  String get systemLanguageLabel => 'System default';

  @override
  String get spanishLabel => 'Spanish';

  @override
  String get englishLabel => 'English';
}
