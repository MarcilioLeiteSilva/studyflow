import 'app_localizations.dart';

class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs() : super('es');

  @override
  String get calendarTitle => 'Calendario de Estudio';
  @override
  String get calendarNoTasks => 'No hay tareas para este día';
  
  @override
  String get navPlanner => 'Planificador';
  @override
  String get navFocus => 'Enfoque';
  @override
  String get navCards => 'Tarjetas';
  @override
  String get navStats => 'Estadísticas';
  @override
  String get navSettings => 'Ajustes';
  @override
  String get drawerSubjects => 'Materias de Estudio';
  @override
  String get drawerDownloadPlans => 'Descargar Planes de Estudio';
  @override
  String get drawerStats => 'Estadísticas';
  @override
  String get drawerSettings => 'Ajustes';
  @override
  String get subjectsTitle => 'Mis Materias';
  @override
  String get subjectsSubtitle => 'Sigue tu progreso por materia';
  @override
  String get subjectsAdd => 'Nueva Materia';

  @override
  String get dashboardMyTasks => 'Mis Tareas';
  @override
  String get dashboardPending => 'Pendiente';
  @override
  String get dashboardDone => 'Hecho';
  @override
  String get dashboardNoTasks => 'No hay tareas';
  @override
  String get dashboardCreateFirstTask => 'Crear primera tarea';
  @override
  String get dashboardTaskDeleted => 'Tarea eliminada';

  @override
  String get taskNewTask => 'Nueva Tarea';
  @override
  String get taskTitleHint => '¿Qué necesitas hacer?';
  @override
  String get taskCategory => 'Categoría';
  @override
  String get taskPriority => 'Prioridad';
  @override
  String get taskPriorityLow => 'Baja';
  @override
  String get taskPriorityMedium => 'Media';
  @override
  String get taskPriorityHigh => 'Alta';
  @override
  String get taskSetDeadline => 'Establecer fecha límite (Opcional)';
  @override
  String get taskCreate => 'Crear Tarea';
  @override
  String get taskDefaultCategory => 'General';
  @override
  String get taskStartFocus => 'Iniciar Sesión de Enfoque';
  @override
  String get taskEdit => 'Editar Tarea';
  @override
  String get taskUpdate => 'Actualizar Tarea';
  
  @override
  String get settingsTitle => 'Ajustes y Herramientas';
  @override
  String get settingsPremium => 'Funciones Premium';
  @override
  String get settingsAmbientSounds => 'Sonidos Ambientales';
  @override
  String get settingsAmbientSoundsSubtitle => 'Música de enfoque y ruido blanco';
  @override
  String get settingsAchievements => 'Logros';
  @override
  String get settingsAchievementsSubtitle => 'Insignias y Recompensas';
  @override
  String get settingsMotivation => 'Motivación Diaria';
  @override
  String get settingsMotivationSubtitle => 'Frases inspiradoras';
  @override
  String get settingsExport => 'Exportar Informes';
  @override
  String get settingsExportSubtitle => 'Descargar resumen de estudio en PDF';
  @override
  String get settingsApp => 'Ajustes de la Aplicación';
  @override
  String get settingsDarkMode => 'Modo Oscuro';
  @override
  String get settingsNotifications => 'Notificaciones';
  @override
  String get settingsLanguage => 'Idioma';
  @override
  String get settingsData => 'Datos';
  @override
  String get settingsResetData => 'Restablecer Datos';
  @override
  String get settingsResetDialogTitle => '¿Restablecer Datos?';
  @override
  String get settingsResetDialogContent => 'Esto eliminará todas las tareas y sesiones. Esta acción no se puede deshacer.';
  @override
  String get settingsCancel => 'Cancelar';
  @override
  String get settingsReset => 'Restablecer';
  @override
  String get settingsResetSuccess => 'Todos los datos restablecidos con éxito';
  @override
  String get settingsSelectLanguage => 'Seleccionar Idioma';
  
  @override
  String get tooltipAIAssistant => 'Asistente IA';
  @override
  String get tooltipCalendarView => 'Vista Calendario';
  @override
  String get btnAddTask => 'Añadir Tarea';
  @override
  String get btnAdd => 'Añadir';
  @override
  String get btnCancel => 'Cancelar';
  
  @override
  String get taskUpdated => 'Tarea actualizada con éxito';
  @override
  String get dialogDeleteTaskTitle => '¿Eliminar Tarea?';
  @override
  String get dialogDeleteTaskContent => '¿Estás seguro de que quieres eliminar esta tarea?';
  @override
  String get btnDelete => 'Eliminar';
  @override
  String get taskDetails => 'Detalles de la Tarea';
  @override
  String get labelDue => 'Vencimiento: ';
  @override
  String get sectionTaskInfo => 'Info de Tarea';
  @override
  String get labelTitle => 'Título';
  @override
  String get sectionDeadline => 'Fecha límite';
  @override
  String get noDeadline => 'Sin fecha límite';
  @override
  String get sectionNotes => 'Notas';
  @override
  String get hintNotes => 'Añadir notas aquí...';

  @override
  String get aiTitle => 'Asistente de Estudio IA';
  @override
  String get aiTabPremade => 'Planes Listos';
  @override
  String get aiTabCustom => 'Generador con IA';
  @override
  String get aiSectionEmbedded => 'Integrados en la App (100% Offline)';
  @override
  String get aiSectionDownloadable => 'Disponibles para Descarga (Nube)';
  @override
  String get aiBtnApplyPlan => 'Aplicar al Planificador';
  @override
  String get aiBtnDownloadPlan => 'Descargar y Aplicar';
  @override
  String get aiStatusCustomKey => 'Clave Personal Activa';
  @override
  String get aiStatusBackend => 'Backend Conectado';
  @override
  String get aiStatusOffline => 'Modo Offline (Heurístico)';
  @override
  String get aiDownloading => 'Descargando plan de la nube...';
  @override
  String get aiGenerateTitle => 'Genera tu Plan de Estudio';
  @override
  String get aiInputSubjects => 'Materias (separadas por coma)';
  @override
  String get aiInputSubjectsHint => 'ej. Matemáticas, Física, Historia';
  @override
  String get aiInputExamDate => 'Fecha del Examen';
  @override
  String get aiInputDateSelect => 'Seleccionar Fecha';
  @override
  String get aiBtnGenerate => 'Generar Plan con IA';
  @override
  String get aiResultTitle => 'Tu Rutina Personalizada';
  @override
  String get aiBtnAddAll => 'Añadir Todo al Planificador';
  @override
  String get snackEnterSubjects => 'Por favor ingresa materias y fecha del examen';
  
  @override
  String get analyticsTitle => 'Análisis de Productividad';
  @override
  String get analyticsGenerateReport => 'Generar Informe';
  @override
  String get analyticsTotalHours => 'Horas Totales';
  @override
  String get analyticsSessions => 'Sesiones';
  @override
  String get analyticsWeeklyFocus => 'Enfoque Semanal';
  
  @override
  String get pomoTitle => 'Temporizador Pomodoro';
  @override
  String get pomoFocusComplete => '¡Sesión de Enfoque Completa!';
  @override
  String get pomoBreakComplete => '¡Descanso Terminado!';
  @override
  String get pomoFocusMsg => '¡Buen trabajo! Toma un breve descanso.';
  @override
  String get pomoBreakMsg => '¿Listo para enfocarte de nuevo?';
  @override
  String get pomoBtnStartBreak => 'Iniciar Descanso';
  @override
  String get pomoBtnStartFocus => 'Iniciar Enfoque';
  @override
  String get pomoTooltipSwitch => 'Cambiar Modo';
  @override
  String get pomoStatusFocus => 'Tiempo de Enfoque';
  @override
  String get pomoStatusBreak => 'Tiempo de Descanso';
  
  @override
  String get focusTitle => 'ENFOQUE PROFUNDO';
  
  @override
  String get flashcardsTitle => 'Tarjetas Inteligentes';
  @override
  String get flashcardsMyDecks => 'Mis Mazos';
  @override
  String get flashcardsReviewNow => 'Repasar Ahora';
  @override
  String get flashcardsEmpty => 'No hay tarjetas aún';
  @override
  String get flashcardsCreate => 'Crea tu primera tarjeta';
  @override
  String get flashcardsAllCaughtUp => '¡Todo al día!';
  @override
  String get flashcardsComeBackLater => 'Vuelve más tarde para más repasos.';
  @override
  String get flashcardsAddTitle => 'Añadir Nueva Tarjeta';
  @override
  String get flashcardsSubjectHint => 'Materia (ej. Matemáticas)';
  @override
  String get flashcardsQuestion => 'Pregunta';
  @override
  String get flashcardsAnswer => 'Respuesta';
  @override
  String get flashcardsTapToShow => 'Toca para ver respuesta';
  @override
  String get flashcardsHard => 'Difícil';
  @override
  String get flashcardsGood => 'Bien';
  @override
  String get flashcardsEasy => 'Fácil';
  
  @override
  String get reportTitle => 'Exportar Informes';
  @override
  String get reportGenerate => 'Generar Informe de Estudio';
  @override
  String get reportDesc => 'Descarga un informe detallado en PDF de tus sesiones de estudio, tareas completadas y estadísticas de productividad.';
  @override
  String get reportExportPdf => 'Exportar PDF';
  @override
  String get reportPrint => 'Imprimir / Vista Previa';
  
  @override
  String get pdfTitle => 'StudyFlow - Informe de Progreso';
  @override
  String get pdfSummary => 'Resumen';
  @override
  String get pdfTotalTasks => 'Total de Tareas';
  @override
  String get pdfCompleted => 'Completadas';
  @override
  String get pdfPending => 'Pendientes';
  @override
  String get pdfStudyHours => 'Horas de Estudio';
  @override
  String get pdfRecentSessions => 'Sesiones de Estudio Recientes';
  @override
  String get pdfColDate => 'Fecha';
  @override
  String get pdfColDuration => 'Duración (mins)';
  @override
  String get pdfColTask => 'ID de Tarea';
  @override
  String get pdfFocusSession => 'Sesión de Enfoque';
  
  @override
  String get achievementsTitle => 'Logros';
  @override
  String get badgeFirstStep => 'Primer Paso';
  @override
  String get badgeFirstStepDesc => 'Completa tu primera tarea';
  @override
  String get badgeFocusMaster => 'Maestro del Enfoque';
  @override
  String get badgeFocusMasterDesc => 'Completa 10 sesiones Pomodoro';
  @override
  String get badgePlannerPro => 'Planificador Pro';
  @override
  String get badgePlannerProDesc => 'Crea 50 tareas';
  @override
  String get badgeEarlyBird => 'Madrugador';
  @override
  String get badgeEarlyBirdDesc => 'Completa una tarea antes de las 8 AM';
  @override
  String get badgeNightOwl => 'Noctámbulo';
  @override
  String get badgeNightOwlDesc => 'Completa una sesión después de las 10 PM';
  @override
  String get badgeStreakKing => 'Rey de la Racha';
  @override
  String get badgeStreakKingDesc => 'Racha de estudio de 7 días';
  
  @override
  String get quotesTitle => 'Motivación Diaria';
  @override
  String get quoteCopied => '¡Cita copiada al portapapeles!';
  @override
  String get quote1 => 'El secreto para salir adelante es comenzar.';
  @override
  String get quoteAuthor1 => 'Mark Twain';
  @override
  String get quote2 => 'Siempre parece imposible hasta que se hace.';
  @override
  String get quoteAuthor2 => 'Nelson Mandela';
  @override
  String get quote3 => 'No mires el reloj; haz lo que él hace. Sigue adelante.';
  @override
  String get quoteAuthor3 => 'Sam Levenson';
  @override
  String get quote4 => 'Cree que puedes y ya estás a medio camino.';
  @override
  String get quoteAuthor4 => 'Theodore Roosevelt';
  @override
  String get quote5 => 'El éxito es la suma de pequeños esfuerzos repetidos día tras día.';
  @override
  String get quoteAuthor5 => 'Robert Collier';
  @override
  String get quote6 => 'El futuro pertenece a quienes creen en la belleza de sus sueños.';
  @override
  String get quoteAuthor6 => 'Eleanor Roosevelt';
  @override
  String get quote7 => 'No tienes que ser grande para empezar, pero tienes que empezar para ser grande.';
  @override
  String get quoteAuthor7 => 'Zig Ziglar';
  
  @override
  String get soundsTitle => 'Sonidos de Enfoque';
  @override
  String get soundRain => 'Lluvia';
  @override
  String get soundForest => 'Bosque';
  @override
  String get soundFire => 'Fuego';
  @override
  String get soundStream => 'Arroyo';
  @override
  String get soundCafe => 'Café';
  @override
  String get soundWhiteNoise => 'Ruido Blanco';
  @override
  String get soundLibrary => 'Biblioteca';
  @override
  String get soundNight => 'Noche';
  
  @override
  String get onboardingTitle1 => 'Domina tu Horario';
  @override
  String get onboardingDesc1 => 'Crea planes de estudio personalizados y sigue tus fechas límite sin esfuerzo.';
  @override
  String get onboardingTitle2 => 'Modo de Enfoque Profundo';
  @override
  String get onboardingDesc2 => 'Elimina distracciones con nuestro temporizador amigable con AMOLED.';
  @override
  String get onboardingTitle3 => 'Gamifica tu Aprendizaje';
  @override
  String get onboardingDesc3 => 'Gana insignias, sigue rachas y visualiza tu progreso.';
  @override
  String get onboardingNext => 'Siguiente';
  @override
  String get onboardingGetStarted => 'Comenzar';
  
  @override
  String get langEnglish => 'Inglés';
  @override
  String get langSpanish => 'Español (Español)';
  @override
  String get langPortuguese => 'Portugués (Português)';
  
  @override
  String get prefAmbientSounds => 'Sonidos Ambientales';
  @override
  String get prefAmbientSoundsSubtitle => 'Música de enfoque y ruido blanco';
  @override
  String get prefAchievements => 'Logros';
  @override
  String get prefAchievementsSubtitle => 'Insignias y Recompensas';
  @override
  String get prefDailyMotivation => 'Motivación Diaria';
  @override
  String get prefDailyMotivationSubtitle => 'Frases inspiradoras';
  @override
  String get prefExportReports => 'Exportar Informes';
  @override
  String get prefExportReportsSubtitle => 'Descargar resumen de estudio en PDF';
  @override
  String get sectionAppSettings => 'Ajustes de la App';
  @override
  String get prefDarkMode => 'Modo Oscuro';
  @override
  String get prefNotifications => 'Notificaciones';
  @override
  String get prefLanguage => 'Idioma';
  @override
  String get prefApiKey => 'Clave de IA (Opcional)';
  @override
  String get prefApiKeySubtitle => 'Configurar API Key personal (Gemini u OpenRouter)';
  @override
  String get dialogApiKeyTitle => 'Clave de API de IA';
  @override
  String get dialogApiKeyHint => 'Pega tu clave (AIza... o sk-or-...)';
  @override
  String get dialogApiKeyDesc => 'Tu clave se guarda de forma segura solo en este dispositivo.';
  @override
  String get btnSave => 'Guardar';
  @override
  String get snackApiKeySaved => '¡Clave de IA guardada con éxito!';
  @override
  String get snackApiKeyCleared => '¡Clave de IA eliminada!';
  @override
  String get sectionData => 'Datos';
  @override
  String get prefResetData => 'Restablecer Datos';
  @override
  String get dialogResetTitle => '¿Restablecer Datos?';
  @override
  String get dialogResetContent => 'Esto eliminará todas las tareas y sesiones. Esta acción no se puede deshacer.';
  @override
  String get btnReset => 'Restablecer';
  @override
  String get snackDataReset => 'Todos los datos restablecidos con éxito';
  @override
  String get dialogLanguageTitle => 'Seleccionar Idioma';

  @override
  String snackAddedTask(String task) => 'Añadido "$task" al planificador';
  @override
  String snackAddedAll(int count) => 'Añadidas $count tareas al planificador';
  @override
  String aiError(Object error) => 'Fallo en Generación IA: $error';
  @override
  String soundPlaying(String sound) => 'Reproduciendo $sound...';
  @override
  String flashcardsCount(int count) => '$count tarjetas';
  @override
  String flashcardsDue(int count) => '$count pendientes';
  @override
  String reportError(Object error) => 'Error al exportar PDF: $error';
  @override
  String pdfGeneratedOn(String date) => 'Generado el: $date';
}
