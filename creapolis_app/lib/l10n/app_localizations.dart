import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Creapolis'**
  String get appName;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get notificationsSubtitle;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light/Dark mode'**
  String get themeSubtitle;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @helpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help center and support'**
  String get helpSubtitle;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacySubtitle;

  /// No description provided for @privacyContent.
  ///
  /// In en, this message translates to:
  /// **'We manage your data with best practices.\n- Data use limited to functionality.\n- No third-party sharing without consent.\n- You can manage preferences in Settings.\n\nFor details, see the official site.'**
  String get privacyContent;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @workspaceActive.
  ///
  /// In en, this message translates to:
  /// **'Active Workspace'**
  String get workspaceActive;

  /// No description provided for @workspaceRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace required'**
  String get workspaceRequiredTitle;

  /// No description provided for @workspaceRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'To create tasks, select or create a workspace first.'**
  String get workspaceRequiredMessage;

  /// No description provided for @createWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create Workspace'**
  String get createWorkspace;

  /// No description provided for @selectProject.
  ///
  /// In en, this message translates to:
  /// **'Select a project'**
  String get selectProject;

  /// No description provided for @addWidgetCreateProject.
  ///
  /// In en, this message translates to:
  /// **'Add Widget / Create Project'**
  String get addWidgetCreateProject;

  /// No description provided for @updatingProjectsSnack.
  ///
  /// In en, this message translates to:
  /// **'Updating project list...'**
  String get updatingProjectsSnack;

  /// No description provided for @newTaskTooltip.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTaskTooltip;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @taskCreatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Task \"{title}\" created'**
  String taskCreatedSnack(Object title);

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get viewMore;

  /// No description provided for @percentageCompleted.
  ///
  /// In en, this message translates to:
  /// **'{percent}% completed'**
  String percentageCompleted(Object percent);

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreTitle;

  /// No description provided for @managementSection.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get managementSection;

  /// No description provided for @infoSection.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get infoSection;

  /// No description provided for @workspacesTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspaces'**
  String get workspacesTitle;

  /// No description provided for @workspacesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage workspaces'**
  String get workspacesSubtitle;

  /// No description provided for @invitationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get invitationsTitle;

  /// No description provided for @invitationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View pending invitations'**
  String get invitationsSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Application settings'**
  String get settingsSubtitle;

  /// No description provided for @customizationMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Customization Metrics'**
  String get customizationMetricsTitle;

  /// No description provided for @customizationMetricsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'UI usage statistics'**
  String get customizationMetricsSubtitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Application information'**
  String get aboutSubtitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @helpContent.
  ///
  /// In en, this message translates to:
  /// **'Visit our help center for guides and support. Direct links from the app will be integrated soon.'**
  String get helpContent;

  /// No description provided for @recentActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivityTitle;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @activityCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get activityCompleted;

  /// No description provided for @activityUpdated.
  ///
  /// In en, this message translates to:
  /// **'Task updated'**
  String get activityUpdated;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(Object count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(Object count);

  /// No description provided for @myTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasksTitle;

  /// No description provided for @allClear.
  ///
  /// In en, this message translates to:
  /// **'All clear!'**
  String get allClear;

  /// No description provided for @myProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Projects'**
  String get myProjectsTitle;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @dailySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get dailySummaryTitle;

  /// No description provided for @tasksLabel.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksLabel;

  /// No description provided for @projectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsLabel;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabel;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overallProgress;

  /// No description provided for @upcomingTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Tasks'**
  String get upcomingTasksTitle;

  /// No description provided for @noPendingTasks.
  ///
  /// In en, this message translates to:
  /// **'No pending tasks! 🎉'**
  String get noPendingTasks;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @myTasksTab.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasksTab;

  /// No description provided for @allTasksTab.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTasksTab;

  /// No description provided for @createTaskTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get createTaskTooltip;

  /// No description provided for @searchTasksTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search tasks'**
  String get searchTasksTooltip;

  /// No description provided for @filtersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTooltip;

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'By date'**
  String get sortByDate;

  /// No description provided for @sortByPriority.
  ///
  /// In en, this message translates to:
  /// **'By priority'**
  String get sortByPriority;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'By name'**
  String get sortByName;

  /// No description provided for @selectWorkspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a workspace'**
  String get selectWorkspaceTitle;

  /// No description provided for @selectWorkspaceMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a workspace from the top switcher to view available tasks.'**
  String get selectWorkspaceMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loadTasksErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks could not be loaded'**
  String get loadTasksErrorTitle;

  /// No description provided for @loginRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to view your tasks'**
  String get loginRequiredTitle;

  /// No description provided for @loginRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to log in to see tasks assigned to you.'**
  String get loginRequiredMessage;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goToLogin;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @noDateGroup.
  ///
  /// In en, this message translates to:
  /// **'Overdue or no date'**
  String get noDateGroup;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @priorityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get priorityCritical;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResultsTitle;

  /// No description provided for @noResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find tasks with the current filters.'**
  String get noResultsMessage;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @noAssignedTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'No assigned tasks'**
  String get noAssignedTasksTitle;

  /// No description provided for @noAssignedTasksMessage.
  ///
  /// In en, this message translates to:
  /// **'You have no tasks assigned in this workspace.'**
  String get noAssignedTasksMessage;

  /// No description provided for @createTask.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get createTask;

  /// No description provided for @confirmCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Task'**
  String get confirmCompleteTitle;

  /// No description provided for @confirmCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Mark \"{title}\" as completed?'**
  String confirmCompleteMessage(Object title);

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?\n\nThis action cannot be undone.'**
  String confirmDeleteMessage(Object title);

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @tasksUpdatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Tasks updated'**
  String get tasksUpdatedSnack;

  /// No description provided for @tasksUpdateFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t update tasks. Please try again.'**
  String get tasksUpdateFailedSnack;

  /// No description provided for @taskAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task is already completed'**
  String get taskAlreadyCompleted;

  /// No description provided for @noPermissionsCreateTasks.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permissions to create tasks in this workspace.'**
  String get noPermissionsCreateTasks;

  /// No description provided for @updatingWorkspaceTasks.
  ///
  /// In en, this message translates to:
  /// **'We are updating workspace tasks. Please try again in a few seconds.'**
  String get updatingWorkspaceTasks;

  /// No description provided for @mustSelectWorkspaceMessage.
  ///
  /// In en, this message translates to:
  /// **'You must select an active workspace before creating tasks.'**
  String get mustSelectWorkspaceMessage;

  /// No description provided for @viewWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'View workspaces'**
  String get viewWorkspaces;

  /// No description provided for @needProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'A project is required'**
  String get needProjectTitle;

  /// No description provided for @needProjectMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a project first to register tasks in this workspace.'**
  String get needProjectMessage;

  /// No description provided for @goToProjects.
  ///
  /// In en, this message translates to:
  /// **'Go to projects'**
  String get goToProjects;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsTitle;

  /// No description provided for @createProject.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get createProject;

  /// No description provided for @inviteMember.
  ///
  /// In en, this message translates to:
  /// **'Invite Member'**
  String get inviteMember;

  /// No description provided for @loadDataError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get loadDataError;

  /// No description provided for @noTasksToShow.
  ///
  /// In en, this message translates to:
  /// **'No tasks to show'**
  String get noTasksToShow;

  /// No description provided for @noDataWithFilters.
  ///
  /// In en, this message translates to:
  /// **'No data with applied filters'**
  String get noDataWithFilters;

  /// No description provided for @priorityDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Priority Distribution'**
  String get priorityDistributionTitle;

  /// No description provided for @weeklyProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgressTitle;

  /// No description provided for @tasksCompletedPerDay.
  ///
  /// In en, this message translates to:
  /// **'Tasks completed per day'**
  String get tasksCompletedPerDay;

  /// No description provided for @tasksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tasks'**
  String tasksCount(Object count);

  /// No description provided for @taskMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Metrics'**
  String get taskMetricsTitle;

  /// No description provided for @filteredLabel.
  ///
  /// In en, this message translates to:
  /// **'Filtered'**
  String get filteredLabel;

  /// No description provided for @loadMetricsError.
  ///
  /// In en, this message translates to:
  /// **'Error loading metrics'**
  String get loadMetricsError;

  /// No description provided for @completedOfTotalTasks.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} tasks'**
  String completedOfTotalTasks(Object completed, Object total);

  /// No description provided for @tasksDelayedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} delayed'**
  String tasksDelayedCount(Object count);

  /// No description provided for @notificationPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferencesTitle;

  /// No description provided for @notificationChannels.
  ///
  /// In en, this message translates to:
  /// **'Notification Channels'**
  String get notificationChannels;

  /// No description provided for @pushNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotificationsTitle;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive real-time notifications on this device'**
  String get pushNotificationsSubtitle;

  /// No description provided for @emailNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotificationsTitle;

  /// No description provided for @emailNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive summaries and alerts by email'**
  String get emailNotificationsSubtitle;

  /// No description provided for @notificationTypes.
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// No description provided for @notificationTypesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select which events you want to be notified about'**
  String get notificationTypesSubtitle;

  /// No description provided for @mentionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Mentions'**
  String get mentionNotifications;

  /// No description provided for @mentionNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone mentions you in a comment'**
  String get mentionNotificationsSubtitle;

  /// No description provided for @commentReplyNotifications.
  ///
  /// In en, this message translates to:
  /// **'Comment replies'**
  String get commentReplyNotifications;

  /// No description provided for @commentReplyNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone replies to your comment'**
  String get commentReplyNotificationsSubtitle;

  /// No description provided for @taskAssignedNotifications.
  ///
  /// In en, this message translates to:
  /// **'Task assigned'**
  String get taskAssignedNotifications;

  /// No description provided for @taskAssignedNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When a new task is assigned to you'**
  String get taskAssignedNotificationsSubtitle;

  /// No description provided for @taskUpdatedNotifications.
  ///
  /// In en, this message translates to:
  /// **'Task updated'**
  String get taskUpdatedNotifications;

  /// No description provided for @taskUpdatedNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When a task you follow is updated'**
  String get taskUpdatedNotificationsSubtitle;

  /// No description provided for @projectUpdatedNotifications.
  ///
  /// In en, this message translates to:
  /// **'Project updated'**
  String get projectUpdatedNotifications;

  /// No description provided for @projectUpdatedNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When a project is updated'**
  String get projectUpdatedNotificationsSubtitle;

  /// No description provided for @systemNotifications.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemNotifications;

  /// No description provided for @systemNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Important updates and announcements'**
  String get systemNotificationsSubtitle;

  /// No description provided for @preferencesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Preferences updated'**
  String get preferencesUpdated;

  /// No description provided for @preferencesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading preferences: {error}'**
  String preferencesLoadError(Object error);

  /// No description provided for @preferencesUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating preferences: {error}'**
  String preferencesUpdateError(Object error);

  /// No description provided for @pushPermissionsHint.
  ///
  /// In en, this message translates to:
  /// **'Push notifications require system permissions. If you don\'t receive notifications, check your device settings.'**
  String get pushPermissionsHint;

  /// No description provided for @selectTimezoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Select time zone'**
  String get selectTimezoneTitle;

  /// No description provided for @timeTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Tracking'**
  String get timeTrackingTitle;

  /// No description provided for @workSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Work Sessions'**
  String get workSessionsTitle;

  /// No description provided for @noPermissionsTrackTime.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permissions to track time in this workspace'**
  String get noPermissionsTrackTime;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// No description provided for @stopLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopLabel;

  /// No description provided for @finishLabel.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishLabel;

  /// No description provided for @hoursProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours Progress'**
  String get hoursProgressLabel;

  /// No description provided for @overtimeHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Overtime hours'**
  String get overtimeHoursLabel;

  /// No description provided for @finishTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish Task'**
  String get finishTaskTitle;

  /// No description provided for @finishTaskMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish this task? This will stop any active timer and mark the task as completed.'**
  String get finishTaskMessage;

  /// No description provided for @taskFinishedSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Task finished successfully!'**
  String get taskFinishedSuccessSnack;

  /// No description provided for @taskDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Detail'**
  String get taskDetailTitle;

  /// No description provided for @overviewTab.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTab;

  /// No description provided for @timeTrackingTab.
  ///
  /// In en, this message translates to:
  /// **'Time Tracking'**
  String get timeTrackingTab;

  /// No description provided for @dependenciesTab.
  ///
  /// In en, this message translates to:
  /// **'Dependencies'**
  String get dependenciesTab;

  /// No description provided for @loadTaskErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error loading task'**
  String get loadTaskErrorTitle;

  /// No description provided for @dependenciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Dependencies'**
  String get dependenciesTitle;

  /// No description provided for @dependenciesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} dependencies'**
  String dependenciesCount(Object count);

  /// No description provided for @taskNumber.
  ///
  /// In en, this message translates to:
  /// **'Task #{id}'**
  String taskNumber(Object id);

  /// No description provided for @noDependencies.
  ///
  /// In en, this message translates to:
  /// **'No dependencies'**
  String get noDependencies;

  /// No description provided for @descriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionTitle;

  /// No description provided for @datesAndDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Dates and Duration'**
  String get datesAndDurationTitle;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endDateLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @durationInDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String durationInDays(Object count);

  /// No description provided for @assignedToLabel.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get assignedToLabel;

  /// No description provided for @pendingInvitationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Invitations'**
  String get pendingInvitationsTitle;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @joinedWorkspaceSnack.
  ///
  /// In en, this message translates to:
  /// **'You\'ve joined \"{workspace}\"'**
  String joinedWorkspaceSnack(Object workspace);

  /// No description provided for @invitationDeclinedSnack.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get invitationDeclinedSnack;

  /// No description provided for @noPendingInvitationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending invitations'**
  String get noPendingInvitationsTitle;

  /// No description provided for @noPendingInvitationsMessage.
  ///
  /// In en, this message translates to:
  /// **'When someone invites you to a workspace\nit will appear here'**
  String get noPendingInvitationsMessage;

  /// No description provided for @invitedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Invited by'**
  String get invitedByLabel;

  /// No description provided for @invitedAt.
  ///
  /// In en, this message translates to:
  /// **'Invited {value}'**
  String invitedAt(Object value);

  /// No description provided for @invitationExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get invitationExpired;

  /// No description provided for @expiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires {value}'**
  String expiresAt(Object value);

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @invitationExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This invitation has expired'**
  String get invitationExpiredMessage;

  /// No description provided for @acceptInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept Invitation'**
  String get acceptInvitationTitle;

  /// No description provided for @acceptInvitationMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to join \"{workspace}\" as {role}?'**
  String acceptInvitationMessage(Object role, Object workspace);

  /// No description provided for @declineInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline Invitation'**
  String get declineInvitationTitle;

  /// No description provided for @declineInvitationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to decline the invitation to \"{workspace}\"?'**
  String declineInvitationMessage(Object workspace);

  /// No description provided for @declineInvitationNote.
  ///
  /// In en, this message translates to:
  /// **'The administrator can send you a new invitation in the future.'**
  String get declineInvitationNote;

  /// No description provided for @confirmDeclineLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Decline'**
  String get confirmDeclineLabel;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get yesterday;

  /// No description provided for @inHours.
  ///
  /// In en, this message translates to:
  /// **'in {count} {unit}'**
  String inHours(Object count, Object unit);

  /// No description provided for @inMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {count} {unit}'**
  String inMinutes(Object count, Object unit);

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'in {count} {unit}'**
  String inDays(Object count, Object unit);

  /// No description provided for @workspaceMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace Members'**
  String get workspaceMembersTitle;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @filterByRole.
  ///
  /// In en, this message translates to:
  /// **'Filter by role'**
  String get filterByRole;

  /// No description provided for @ownersRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Owners'**
  String get ownersRoleLabel;

  /// No description provided for @adminsRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get adminsRoleLabel;

  /// No description provided for @membersRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersRoleLabel;

  /// No description provided for @guestsRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guestsRoleLabel;

  /// No description provided for @memberRoleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Role of {user} updated to {role}'**
  String memberRoleUpdated(Object role, Object user);

  /// No description provided for @memberRemovedSnack.
  ///
  /// In en, this message translates to:
  /// **'Member removed from workspace'**
  String get memberRemovedSnack;

  /// No description provided for @youChip.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youChip;

  /// No description provided for @activeChip.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeChip;

  /// No description provided for @changeRoleAction.
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get changeRoleAction;

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @noMembersWithRole.
  ///
  /// In en, this message translates to:
  /// **'No members with that role'**
  String get noMembersWithRole;

  /// No description provided for @noMembersInWorkspace.
  ///
  /// In en, this message translates to:
  /// **'No members in this workspace'**
  String get noMembersInWorkspace;

  /// No description provided for @tryAnotherFilter.
  ///
  /// In en, this message translates to:
  /// **'Try another filter'**
  String get tryAnotherFilter;

  /// No description provided for @invitePeopleToCollaborate.
  ///
  /// In en, this message translates to:
  /// **'Invite people to collaborate'**
  String get invitePeopleToCollaborate;

  /// No description provided for @changeRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Change role of {name}'**
  String changeRoleTitle(Object name);

  /// No description provided for @removeMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMemberTitle;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from the workspace?'**
  String removeMemberConfirm(Object name);

  /// No description provided for @removeMemberNote.
  ///
  /// In en, this message translates to:
  /// **'The user will lose access to all projects and tasks in this workspace.'**
  String get removeMemberNote;

  /// No description provided for @removeMemberInviteAgainNote.
  ///
  /// In en, this message translates to:
  /// **'You can invite them again in the future.'**
  String get removeMemberInviteAgainNote;

  /// No description provided for @confirmRemoveLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Remove'**
  String get confirmRemoveLabel;

  /// No description provided for @searchMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Search members...'**
  String get searchMembersHint;

  /// No description provided for @invitationSentTo.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent to {email}'**
  String invitationSentTo(Object email);

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String membersCount(Object count);

  /// No description provided for @inviteeEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Invitee email'**
  String get inviteeEmailLabel;

  /// No description provided for @inviteeEmailHint.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get inviteeEmailHint;

  /// No description provided for @enterEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get enterEmailMessage;

  /// No description provided for @enterValidEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmailMessage;

  /// No description provided for @workspaceRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Workspace role'**
  String get workspaceRoleLabel;

  /// No description provided for @rolePermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Role permissions'**
  String get rolePermissionsTitle;

  /// No description provided for @adminRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'Full management except deleting workspace'**
  String get adminRoleDesc;

  /// No description provided for @memberRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'Create and manage projects and tasks'**
  String get memberRoleDesc;

  /// No description provided for @guestRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'View-only access'**
  String get guestRoleDesc;

  /// No description provided for @sendInvitation.
  ///
  /// In en, this message translates to:
  /// **'Send Invitation'**
  String get sendInvitation;

  /// No description provided for @adminRoleCapability.
  ///
  /// In en, this message translates to:
  /// **'Can manage members and settings'**
  String get adminRoleCapability;

  /// No description provided for @memberRoleCapability.
  ///
  /// In en, this message translates to:
  /// **'Can create and manage projects'**
  String get memberRoleCapability;

  /// No description provided for @guestRoleCapability.
  ///
  /// In en, this message translates to:
  /// **'View-only access'**
  String get guestRoleCapability;

  /// No description provided for @ownerRoleCapability.
  ///
  /// In en, this message translates to:
  /// **'Full control of workspace'**
  String get ownerRoleCapability;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @loadRolePrefsError.
  ///
  /// In en, this message translates to:
  /// **'Error loading preferences: {error}'**
  String loadRolePrefsError(Object error);

  /// No description provided for @resetConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Configuration'**
  String get resetConfigTitle;

  /// No description provided for @resetConfigMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to reset all your configuration to your role defaults?\n\nThis will remove all your customizations.'**
  String get resetConfigMessage;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetConfigSuccess.
  ///
  /// In en, this message translates to:
  /// **'Configuration reset successfully'**
  String get resetConfigSuccess;

  /// No description provided for @resetConfigError.
  ///
  /// In en, this message translates to:
  /// **'Error resetting configuration'**
  String get resetConfigError;

  /// No description provided for @exportSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Successful'**
  String get exportSuccessTitle;

  /// No description provided for @exportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your preferences have been exported successfully.'**
  String get exportSuccessMessage;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareSubject.
  ///
  /// In en, this message translates to:
  /// **'My Creapolis preferences'**
  String get shareSubject;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Preferences file exported from Creapolis'**
  String get shareText;

  /// No description provided for @exportPrefsError.
  ///
  /// In en, this message translates to:
  /// **'Error exporting preferences: {error}'**
  String exportPrefsError(Object error);

  /// No description provided for @importPrefsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Preferences'**
  String get importPrefsTitle;

  /// No description provided for @importPrefsMessage.
  ///
  /// In en, this message translates to:
  /// **'Importing preferences will replace your current configuration.\n\nDo you want to continue?'**
  String get importPrefsMessage;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @selectPrefsFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Select preferences file'**
  String get selectPrefsFileTitle;

  /// No description provided for @filePathError.
  ///
  /// In en, this message translates to:
  /// **'Could not get file path'**
  String get filePathError;

  /// No description provided for @importPrefsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Preferences imported successfully'**
  String get importPrefsSuccess;

  /// No description provided for @importPrefsError.
  ///
  /// In en, this message translates to:
  /// **'Error importing preferences - Check the file'**
  String get importPrefsError;

  /// No description provided for @importPrefsErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Error importing preferences: {error}'**
  String importPrefsErrorDetail(Object error);

  /// No description provided for @rolePreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Role-based Preferences'**
  String get rolePreferencesTitle;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @resetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get resetToDefaults;

  /// No description provided for @exportPreferences.
  ///
  /// In en, this message translates to:
  /// **'Export preferences'**
  String get exportPreferences;

  /// No description provided for @importPreferences.
  ///
  /// In en, this message translates to:
  /// **'Import preferences'**
  String get importPreferences;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @currentThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Current theme: {theme}'**
  String currentThemeLabel(Object theme);

  /// No description provided for @usingCustomizationDefault.
  ///
  /// In en, this message translates to:
  /// **'You are using your customization (default: {defaultTheme})'**
  String usingCustomizationDefault(Object defaultTheme);

  /// No description provided for @usingRoleDefault.
  ///
  /// In en, this message translates to:
  /// **'Using your role default'**
  String get usingRoleDefault;

  /// No description provided for @revertToRoleDefault.
  ///
  /// In en, this message translates to:
  /// **'Revert to role default'**
  String get revertToRoleDefault;

  /// No description provided for @customizeTheme.
  ///
  /// In en, this message translates to:
  /// **'Customize theme'**
  String get customizeTheme;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @widgetsConfigured.
  ///
  /// In en, this message translates to:
  /// **'{count} widgets configured'**
  String widgetsConfigured(Object count);

  /// No description provided for @usingCustomization.
  ///
  /// In en, this message translates to:
  /// **'You are using your customization'**
  String get usingCustomization;

  /// No description provided for @usingRoleDashboardDefault.
  ///
  /// In en, this message translates to:
  /// **'Using your role default dashboard'**
  String get usingRoleDashboardDefault;

  /// No description provided for @customizeDashboard.
  ///
  /// In en, this message translates to:
  /// **'Customize dashboard'**
  String get customizeDashboard;

  /// No description provided for @exportImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export / Import'**
  String get exportImportTitle;

  /// No description provided for @exportImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Save or restore your full configuration. Useful to back up preferences or transfer them across devices.'**
  String get exportImportDescription;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @howItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorksTitle;

  /// No description provided for @howItWorksStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Base Configuration'**
  String get howItWorksStep1Title;

  /// No description provided for @howItWorksStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Each role has an optimized default configuration.'**
  String get howItWorksStep1Desc;

  /// No description provided for @howItWorksStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Customization'**
  String get howItWorksStep2Title;

  /// No description provided for @howItWorksStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'You can change any configuration according to your preferences.'**
  String get howItWorksStep2Desc;

  /// No description provided for @howItWorksStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Indicators'**
  String get howItWorksStep3Title;

  /// No description provided for @howItWorksStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Elements marked as \"Customized\" show what you have modified.'**
  String get howItWorksStep3Desc;

  /// No description provided for @howItWorksStep4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Reset'**
  String get howItWorksStep4Title;

  /// No description provided for @howItWorksStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Use the reset button to return to role defaults.'**
  String get howItWorksStep4Desc;

  /// No description provided for @howItWorksStep5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Export/Import'**
  String get howItWorksStep5Title;

  /// No description provided for @howItWorksStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'Back up your configuration or transfer it across devices.'**
  String get howItWorksStep5Desc;

  /// No description provided for @roleCustomizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Role Customization'**
  String get roleCustomizationTitle;

  /// No description provided for @roleCustomizationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your experience according to your role'**
  String get roleCustomizationSubtitle;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @navigationTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation type'**
  String get navigationTypeTitle;

  /// No description provided for @navigationTypeDescription.
  ///
  /// In en, this message translates to:
  /// **'Select how you prefer to navigate the app'**
  String get navigationTypeDescription;

  /// No description provided for @sidebarTitle.
  ///
  /// In en, this message translates to:
  /// **'Sidebar'**
  String get sidebarTitle;

  /// No description provided for @sidebarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation menu on the side'**
  String get sidebarSubtitle;

  /// No description provided for @bottomNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Bottom navigation'**
  String get bottomNavigationTitle;

  /// No description provided for @bottomNavigationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation menu at the bottom'**
  String get bottomNavigationSubtitle;

  /// No description provided for @integrationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get integrationsTitle;

  /// No description provided for @googleCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar'**
  String get googleCalendarTitle;

  /// No description provided for @googleCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync your events and availability'**
  String get googleCalendarSubtitle;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @connectGoogleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Calendar'**
  String get connectGoogleCalendar;

  /// No description provided for @connectedOn.
  ///
  /// In en, this message translates to:
  /// **'Connected on {date}'**
  String connectedOn(Object date);

  /// No description provided for @cannotOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Could not open browser'**
  String get cannotOpenBrowser;

  /// No description provided for @googleCalendarAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar Authorization'**
  String get googleCalendarAuthTitle;

  /// No description provided for @googleCalendarAuthInstructions.
  ///
  /// In en, this message translates to:
  /// **'The browser has been opened. Please authorize the application and copy the authorization code here:'**
  String get googleCalendarAuthInstructions;

  /// No description provided for @authorizationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Authorization code'**
  String get authorizationCodeLabel;

  /// No description provided for @authorizationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the code here'**
  String get authorizationCodeHint;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnectGoogleCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Google Calendar'**
  String get disconnectGoogleCalendarTitle;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications settings coming soon'**
  String get notificationsComingSoon;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile settings coming soon'**
  String get profileComingSoon;

  /// No description provided for @aboutComingSoon.
  ///
  /// In en, this message translates to:
  /// **'App information coming soon'**
  String get aboutComingSoon;

  /// No description provided for @googleCalendarConnected.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar connected successfully'**
  String get googleCalendarConnected;

  /// No description provided for @googleCalendarDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar disconnected'**
  String get googleCalendarDisconnected;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
