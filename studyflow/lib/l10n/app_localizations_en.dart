import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super('en');

  @override
  String get calendarTitle => 'Study Calendar';
  @override
  String get calendarNoTasks => 'No tasks for this day';
  
  @override
  String get navPlanner => 'Planner';
  @override
  String get navFocus => 'Focus';
  @override
  String get navCards => 'Cards';
  @override
  String get navStats => 'Stats';
  @override
  String get navSettings => 'Settings';
  @override
  String get drawerSubjects => 'Study Subjects';
  @override
  String get drawerDownloadPlans => 'Download Study Plans';
  @override
  String get drawerStats => 'Statistics';
  @override
  String get drawerSettings => 'Settings';
  @override
  String get subjectsTitle => 'My Subjects';
  @override
  String get subjectsSubtitle => 'Track your progress by subject';
  @override
  String get subjectsAdd => 'New Subject';

  @override
  String get dashboardMyTasks => 'My Tasks';
  @override
  String get dashboardPending => 'Pending';
  @override
  String get dashboardDone => 'Done';
  @override
  String get dashboardNoTasks => 'No tasks yet';
  @override
  String get dashboardCreateFirstTask => 'Create First Task';
  @override
  String get dashboardTaskDeleted => 'Task deleted';

  @override
  String get taskNewTask => 'New Task';
  @override
  String get taskTitleHint => 'What needs to be done?';
  @override
  String get taskCategory => 'Category';
  @override
  String get taskPriority => 'Priority';
  @override
  String get taskPriorityLow => 'Low';
  @override
  String get taskPriorityMedium => 'Medium';
  @override
  String get taskPriorityHigh => 'High';
  @override
  String get taskSetDeadline => 'Set Deadline (Optional)';
  @override
  String get taskCreate => 'Create Task';
  @override
  String get taskDefaultCategory => 'General';
  @override
  String get taskStartFocus => 'Start Focus Session';
  @override
  String get taskEdit => 'Edit Task';
  @override
  String get taskUpdate => 'Update Task';
  
  @override
  String get settingsTitle => 'Settings & Tools';
  @override
  String get settingsPremium => 'Premium Features';
  @override
  String get settingsAmbientSounds => 'Ambient Sounds';
  @override
  String get settingsAmbientSoundsSubtitle => 'Focus music & white noise';
  @override
  String get settingsAchievements => 'Achievements';
  @override
  String get settingsAchievementsSubtitle => 'Badges & Rewards';
  @override
  String get settingsMotivation => 'Daily Motivation';
  @override
  String get settingsMotivationSubtitle => 'Inspirational quotes';
  @override
  String get settingsExport => 'Export Reports';
  @override
  String get settingsExportSubtitle => 'Download PDF study summary';
  @override
  String get settingsApp => 'App Settings';
  @override
  String get settingsDarkMode => 'Dark Mode';
  @override
  String get settingsNotifications => 'Notifications';
  @override
  String get settingsLanguage => 'Language';
  @override
  String get settingsData => 'Data';
  @override
  String get settingsResetData => 'Reset All Data';
  @override
  String get settingsResetDialogTitle => 'Reset Data?';
  @override
  String get settingsResetDialogContent => 'This will delete all tasks and sessions. This action cannot be undone.';
  @override
  String get settingsCancel => 'Cancel';
  @override
  String get settingsReset => 'Reset';
  @override
  String get settingsResetSuccess => 'All data reset successfully';
  @override
  String get settingsSelectLanguage => 'Select Language';
  
  @override
  String get tooltipAIAssistant => 'AI Assistant';
  @override
  String get tooltipCalendarView => 'Calendar View';
  @override
  String get btnAddTask => 'Add Task';
  @override
  String get btnAdd => 'Add';
  @override
  String get btnCancel => 'Cancel';
  
  @override
  String get taskUpdated => 'Task updated successfully';
  @override
  String get dialogDeleteTaskTitle => 'Delete Task?';
  @override
  String get dialogDeleteTaskContent => 'Are you sure you want to delete this task?';
  @override
  String get btnDelete => 'Delete';
  @override
  String get taskDetails => 'Task Details';
  @override
  String get labelDue => 'Due: ';
  @override
  String get sectionTaskInfo => 'Task Info';
  @override
  String get labelTitle => 'Title';
  @override
  String get sectionDeadline => 'Deadline';
  @override
  String get noDeadline => 'No Deadline Set';
  @override
  String get sectionNotes => 'Notes';
  @override
  String get hintNotes => 'Add notes here...';

  @override
  String get aiTitle => 'AI Study Assistant';
  @override
  String get aiTabPremade => 'Premade Plans';
  @override
  String get aiTabCustom => 'AI Generator';
  @override
  String get aiSectionEmbedded => 'Built-in App Plans (100% Offline)';
  @override
  String get aiSectionDownloadable => 'Downloadable Plans (Cloud)';
  @override
  String get aiBtnApplyPlan => 'Apply to Planner';
  @override
  String get aiBtnDownloadPlan => 'Download & Apply';
  @override
  String get aiStatusCustomKey => 'Personal Key Active';
  @override
  String get aiStatusBackend => 'Backend Connected';
  @override
  String get aiStatusOffline => 'Offline Mode (Heuristic)';
  @override
  String get aiDownloading => 'Downloading plan from cloud...';
  @override
  String get aiGenerateTitle => 'Generate Your Study Plan';
  @override
  String get aiInputSubjects => 'Subjects (comma separated)';
  @override
  String get aiInputSubjectsHint => 'e.g. Math, Physics, History';
  @override
  String get aiInputExamDate => 'Exam Date';
  @override
  String get aiInputDateSelect => 'Select Date';
  @override
  String get aiBtnGenerate => 'Generate Plan with AI';
  @override
  String get aiResultTitle => 'Your Personalized Routine';
  @override
  String get aiBtnAddAll => 'Add All to Planner';
  @override
  String get snackEnterSubjects => 'Please enter subjects and exam date';
  
  @override
  String get analyticsTitle => 'Productivity Analytics';
  @override
  String get analyticsGenerateReport => 'Generate Report';
  @override
  String get analyticsTotalHours => 'Total Hours';
  @override
  String get analyticsSessions => 'Sessions';
  @override
  String get analyticsWeeklyFocus => 'Weekly Focus';
  
  @override
  String get pomoTitle => 'Pomodoro Timer';
  @override
  String get pomoFocusComplete => 'Focus Session Complete!';
  @override
  String get pomoBreakComplete => 'Break Over!';
  @override
  String get pomoFocusMsg => 'Great job! Take a short break.';
  @override
  String get pomoBreakMsg => 'Ready to focus again?';
  @override
  String get pomoBtnStartBreak => 'Start Break';
  @override
  String get pomoBtnStartFocus => 'Start Focus';
  @override
  String get pomoTooltipSwitch => 'Switch Mode';
  @override
  String get pomoStatusFocus => 'Focus Time';
  @override
  String get pomoStatusBreak => 'Break Time';
  
  @override
  String get focusTitle => 'DEEP FOCUS';
  
  @override
  String get flashcardsTitle => 'Smart Flashcards';
  @override
  String get flashcardsMyDecks => 'My Decks';
  @override
  String get flashcardsReviewNow => 'Review Now';
  @override
  String get flashcardsEmpty => 'No flashcards yet';
  @override
  String get flashcardsCreate => 'Create your first card';
  @override
  String get flashcardsAllCaughtUp => 'All caught up!';
  @override
  String get flashcardsComeBackLater => 'Come back later for more reviews.';
  @override
  String get flashcardsAddTitle => 'Add New Flashcard';
  @override
  String get flashcardsSubjectHint => 'Subject (e.g., Math)';
  @override
  String get flashcardsQuestion => 'Question';
  @override
  String get flashcardsAnswer => 'Answer';
  @override
  String get flashcardsTapToShow => 'Tap to show answer';
  @override
  String get flashcardsHard => 'Hard';
  @override
  String get flashcardsGood => 'Good';
  @override
  String get flashcardsEasy => 'Easy';
  
  @override
  String get reportTitle => 'Export Reports';
  @override
  String get reportGenerate => 'Generate Study Report';
  @override
  String get reportDesc => 'Download a detailed PDF report of your study sessions, completed tasks, and productivity stats.';
  @override
  String get reportExportPdf => 'Export PDF';
  @override
  String get reportPrint => 'Print / Preview';
  
  @override
  String get pdfTitle => 'StudyFlow - Progress Report';
  @override
  String get pdfSummary => 'Summary';
  @override
  String get pdfTotalTasks => 'Total Tasks';
  @override
  String get pdfCompleted => 'Completed';
  @override
  String get pdfPending => 'Pending';
  @override
  String get pdfStudyHours => 'Study Hours';
  @override
  String get pdfRecentSessions => 'Recent Study Sessions';
  @override
  String get pdfColDate => 'Date';
  @override
  String get pdfColDuration => 'Duration (mins)';
  @override
  String get pdfColTask => 'Task ID';
  @override
  String get pdfFocusSession => 'Focus Session';
  
  @override
  String get achievementsTitle => 'Achievements';
  @override
  String get badgeFirstStep => 'First Step';
  @override
  String get badgeFirstStepDesc => 'Complete your first task';
  @override
  String get badgeFocusMaster => 'Focus Master';
  @override
  String get badgeFocusMasterDesc => 'Complete 10 Pomodoro sessions';
  @override
  String get badgePlannerPro => 'Planner Pro';
  @override
  String get badgePlannerProDesc => 'Create 50 tasks';
  @override
  String get badgeEarlyBird => 'Early Bird';
  @override
  String get badgeEarlyBirdDesc => 'Complete a task before 8 AM';
  @override
  String get badgeNightOwl => 'Night Owl';
  @override
  String get badgeNightOwlDesc => 'Complete a session after 10 PM';
  @override
  String get badgeStreakKing => 'Streak King';
  @override
  String get badgeStreakKingDesc => '7-day study streak';
  
  @override
  String get quotesTitle => 'Daily Motivation';
  @override
  String get quoteCopied => 'Quote copied to clipboard!';
  @override
  String get quote1 => 'The secret of getting ahead is getting started.';
  @override
  String get quoteAuthor1 => 'Mark Twain';
  @override
  String get quote2 => 'It always seems impossible until it’s done.';
  @override
  String get quoteAuthor2 => 'Nelson Mandela';
  @override
  String get quote3 => 'Don’t watch the clock; do what it does. Keep going.';
  @override
  String get quoteAuthor3 => 'Sam Levenson';
  @override
  String get quote4 => 'Believe you can and you’re halfway there.';
  @override
  String get quoteAuthor4 => 'Theodore Roosevelt';
  @override
  String get quote5 => 'Success is the sum of small efforts, repeated day in and day out.';
  @override
  String get quoteAuthor5 => 'Robert Collier';
  @override
  String get quote6 => 'The future belongs to those who believe in the beauty of their dreams.';
  @override
  String get quoteAuthor6 => 'Eleanor Roosevelt';
  @override
  String get quote7 => 'You don’t have to be great to start, but you have to start to be great.';
  @override
  String get quoteAuthor7 => 'Zig Ziglar';
  
  @override
  String get soundsTitle => 'Ambient Focus Sounds';
  @override
  String get soundRain => 'Rain';
  @override
  String get soundForest => 'Forest';
  @override
  String get soundFire => 'Fire';
  @override
  String get soundStream => 'Stream';
  @override
  String get soundCafe => 'Cafe';
  @override
  String get soundWhiteNoise => 'White Noise';
  @override
  String get soundLibrary => 'Library';
  @override
  String get soundNight => 'Night';
  
  @override
  String get onboardingTitle1 => 'Master Your Schedule';
  @override
  String get onboardingDesc1 => 'Create custom study plans and track your deadlines effortlessly.';
  @override
  String get onboardingTitle2 => 'Deep Focus Mode';
  @override
  String get onboardingDesc2 => 'Eliminate distractions with our AMOLED-friendly focus timer.';
  @override
  String get onboardingTitle3 => 'Gamify Your Learning';
  @override
  String get onboardingDesc3 => 'Earn badges, track streaks, and visualize your progress.';
  @override
  String get onboardingNext => 'Next';
  @override
  String get onboardingGetStarted => 'Get Started';
  
  @override
  String get langEnglish => 'English';
  @override
  String get langSpanish => 'Spanish (Español)';
  @override
  String get langPortuguese => 'Portuguese (Português)';
  
  @override
  String get prefAmbientSounds => 'Ambient Sounds';
  @override
  String get prefAmbientSoundsSubtitle => 'Focus music & white noise';
  @override
  String get prefAchievements => 'Achievements';
  @override
  String get prefAchievementsSubtitle => 'Badges & Rewards';
  @override
  String get prefDailyMotivation => 'Daily Motivation';
  @override
  String get prefDailyMotivationSubtitle => 'Inspirational quotes';
  @override
  String get prefExportReports => 'Export Reports';
  @override
  String get prefExportReportsSubtitle => 'Download PDF study summary';
  @override
  String get sectionAppSettings => 'App Settings';
  @override
  String get prefDarkMode => 'Dark Mode';
  @override
  String get prefNotifications => 'Notifications';
  @override
  String get prefLanguage => 'Language';
  @override
  String get prefApiKey => 'AI API Key (Optional)';
  @override
  String get prefApiKeySubtitle => 'Set personal API Key (Gemini or OpenRouter)';
  @override
  String get dialogApiKeyTitle => 'AI API Key';
  @override
  String get dialogApiKeyHint => 'Paste your key (AIza... or sk-or-...)';
  @override
  String get dialogApiKeyDesc => 'Your key is stored securely only on your local device.';
  @override
  String get btnSave => 'Save';
  @override
  String get snackApiKeySaved => 'AI API Key saved successfully!';
  @override
  String get snackApiKeyCleared => 'AI API Key removed!';
  @override
  String get sectionData => 'Data';
  @override
  String get prefResetData => 'Reset All Data';
  @override
  String get dialogResetTitle => 'Reset Data?';
  @override
  String get dialogResetContent => 'This will delete all tasks and sessions. This action cannot be undone.';
  @override
  String get btnReset => 'Reset';
  @override
  String get snackDataReset => 'All data reset successfully';
  @override
  String get dialogLanguageTitle => 'Select Language';

  @override
  String snackAddedTask(String task) => 'Added "$task" to planner';
  @override
  String snackAddedAll(int count) => 'Added $count tasks to planner';
  @override
  String aiError(Object error) => 'AI Generation Failed: $error';
  @override
  String soundPlaying(String sound) => 'Playing $sound...';
  @override
  String flashcardsCount(int count) => '$count cards';
  @override
  String flashcardsDue(int count) => '$count due';
  @override
  String reportError(Object error) => 'Error exporting PDF: $error';
  @override
  String pdfGeneratedOn(String date) => 'Generated on: $date';
}
