import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

abstract class AppLocalizations {
  AppLocalizations(this.localeName);

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  // Common getters
  String get calendarTitle;
  String get calendarNoTasks;
  
  String get navPlanner;
  String get navFocus;
  String get navCards;
  String get navStats;
  String get navSettings;
  String get drawerSubjects;
  String get drawerDownloadPlans;
  String get drawerStats;
  String get drawerSettings;
  String get subjectsTitle;
  String get subjectsSubtitle;
  String get subjectsAdd;

  String get dashboardMyTasks;
  String get dashboardPending;
  String get dashboardDone;
  String get dashboardNoTasks;
  String get dashboardCreateFirstTask;
  String get dashboardTaskDeleted;

  String get taskNewTask;
  String get taskTitleHint;
  String get taskCategory;
  String get taskPriority;
  String get taskPriorityLow;
  String get taskPriorityMedium;
  String get taskPriorityHigh;
  String get taskSetDeadline;
  String get taskCreate;
  String get taskDefaultCategory;
  String get taskStartFocus;
  String get taskEdit;
  String get taskUpdate;
  
  String get settingsTitle;
  String get settingsPremium;
  String get settingsAmbientSounds;
  String get settingsAmbientSoundsSubtitle;
  String get settingsAchievements;
  String get settingsAchievementsSubtitle;
  String get settingsMotivation;
  String get settingsMotivationSubtitle;
  String get settingsExport;
  String get settingsExportSubtitle;
  String get settingsApp;
  String get settingsDarkMode;
  String get settingsNotifications;
  String get settingsLanguage;
  String get settingsData;
  String get settingsResetData;
  String get settingsResetDialogTitle;
  String get settingsResetDialogContent;
  String get settingsCancel;
  String get settingsReset;
  String get settingsResetSuccess;
  String get settingsSelectLanguage;
  
  String get tooltipAIAssistant;
  String get tooltipCalendarView;
  String get btnAddTask;
  String get btnAdd;
  String get btnCancel;
  
  String get taskUpdated;
  String get dialogDeleteTaskTitle;
  String get dialogDeleteTaskContent;
  String get btnDelete;
  String get taskDetails;
  String get labelDue;
  String get sectionTaskInfo;
  String get labelTitle;
  String get sectionDeadline;
  String get noDeadline;
  String get sectionNotes;
  String get hintNotes;

  String get aiTitle;
  String get aiTabPremade;
  String get aiTabCustom;
  String get aiSectionEmbedded;
  String get aiSectionDownloadable;
  String get aiBtnApplyPlan;
  String get aiBtnDownloadPlan;
  String get aiStatusCustomKey;
  String get aiStatusBackend;
  String get aiStatusOffline;
  String get aiDownloading;
  String get aiGenerateTitle;
  String get aiInputSubjects;
  String get aiInputSubjectsHint;
  String get aiInputExamDate;
  String get aiInputDateSelect;
  String get aiBtnGenerate;
  String get aiResultTitle;
  String get aiBtnAddAll;
  String get snackEnterSubjects;
  
  String get analyticsTitle;
  String get analyticsGenerateReport;
  String get analyticsTotalHours;
  String get analyticsSessions;
  String get analyticsWeeklyFocus;
  
  String get pomoTitle;
  String get pomoFocusComplete;
  String get pomoBreakComplete;
  String get pomoFocusMsg;
  String get pomoBreakMsg;
  String get pomoBtnStartBreak;
  String get pomoBtnStartFocus;
  String get pomoTooltipSwitch;
  String get pomoStatusFocus;
  String get pomoStatusBreak;
  
  String get focusTitle;
  
  String get flashcardsTitle;
  String get flashcardsMyDecks;
  String get flashcardsReviewNow;
  String get flashcardsEmpty;
  String get flashcardsCreate;
  String get flashcardsAllCaughtUp;
  String get flashcardsComeBackLater;
  String get flashcardsAddTitle;
  String get flashcardsSubjectHint;
  String get flashcardsQuestion;
  String get flashcardsAnswer;
  String get flashcardsTapToShow;
  String get flashcardsHard;
  String get flashcardsGood;
  String get flashcardsEasy;
  
  String get reportTitle;
  String get reportGenerate;
  String get reportDesc;
  String get reportExportPdf;
  String get reportPrint;
  
  String get pdfTitle;
  String get pdfSummary;
  String get pdfTotalTasks;
  String get pdfCompleted;
  String get pdfPending;
  String get pdfStudyHours;
  String get pdfRecentSessions;
  String get pdfColDate;
  String get pdfColDuration;
  String get pdfColTask;
  String get pdfFocusSession;
  
  String get achievementsTitle;
  String get badgeFirstStep;
  String get badgeFirstStepDesc;
  String get badgeFocusMaster;
  String get badgeFocusMasterDesc;
  String get badgePlannerPro;
  String get badgePlannerProDesc;
  String get badgeEarlyBird;
  String get badgeEarlyBirdDesc;
  String get badgeNightOwl;
  String get badgeNightOwlDesc;
  String get badgeStreakKing;
  String get badgeStreakKingDesc;
  
  String get quotesTitle;
  String get quoteCopied;
  String get quote1;
  String get quoteAuthor1;
  String get quote2;
  String get quoteAuthor2;
  String get quote3;
  String get quoteAuthor3;
  String get quote4;
  String get quoteAuthor4;
  String get quote5;
  String get quoteAuthor5;
  String get quote6;
  String get quoteAuthor6;
  String get quote7;
  String get quoteAuthor7;
  
  String get soundsTitle;
  String get soundRain;
  String get soundForest;
  String get soundFire;
  String get soundStream;
  String get soundCafe;
  String get soundWhiteNoise;
  String get soundLibrary;
  String get soundNight;
  
  String get onboardingTitle1;
  String get onboardingDesc1;
  String get onboardingTitle2;
  String get onboardingDesc2;
  String get onboardingTitle3;
  String get onboardingDesc3;
  String get onboardingNext;
  String get onboardingGetStarted;
  
  String get langEnglish;
  String get langSpanish;
  String get langPortuguese;
  
  String get prefAmbientSounds;
  String get prefAmbientSoundsSubtitle;
  String get prefAchievements;
  String get prefAchievementsSubtitle;
  String get prefDailyMotivation;
  String get prefDailyMotivationSubtitle;
  String get prefExportReports;
  String get prefExportReportsSubtitle;
  String get sectionAppSettings;
  String get prefDarkMode;
  String get prefNotifications;
  String get prefLanguage;
  String get prefApiKey;
  String get prefApiKeySubtitle;
  String get dialogApiKeyTitle;
  String get dialogApiKeyHint;
  String get dialogApiKeyDesc;
  String get btnSave;
  String get snackApiKeySaved;
  String get snackApiKeyCleared;
  String get sectionData;
  String get prefResetData;
  String get dialogResetTitle;
  String get dialogResetContent;
  String get btnReset;
  String get snackDataReset;
  String get dialogLanguageTitle;

  // Parameterized methods
  String snackAddedTask(String task);
  String snackAddedAll(int count);
  String aiError(Object error);
  String soundPlaying(String sound);
  String flashcardsCount(int count);
  String flashcardsDue(int count);
  String reportError(Object error);
  String pdfGeneratedOn(String date);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
    default:
      return AppLocalizationsEn();
  }
}
