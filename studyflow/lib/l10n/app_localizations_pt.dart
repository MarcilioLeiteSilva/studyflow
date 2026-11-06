import 'app_localizations.dart';

class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt() : super('pt');

  @override
  String get calendarTitle => 'Calendário de Estudos';
  @override
  String get calendarNoTasks => 'Nenhuma tarefa para este dia';
  
  @override
  String get navPlanner => 'Planejador';
  @override
  String get navFocus => 'Foco';
  @override
  String get navCards => 'Cartões';
  @override
  String get navStats => 'Estatísticas';
  @override
  String get navSettings => 'Ajustes';
  @override
  String get drawerSubjects => 'Matérias de Estudo';
  @override
  String get drawerDownloadPlans => 'Baixar Planos de Estudo';
  @override
  String get drawerStats => 'Estatísticas';
  @override
  String get drawerSettings => 'Ajustes';
  @override
  String get subjectsTitle => 'Minhas Disciplinas';
  @override
  String get subjectsSubtitle => 'Acompanhe seu progresso por matéria';
  @override
  String get subjectsAdd => 'Nova Matéria';

  @override
  String get dashboardMyTasks => 'Minhas Tarefas';
  @override
  String get dashboardPending => 'Pendentes';
  @override
  String get dashboardDone => 'Concluídas';
  @override
  String get dashboardNoTasks => 'Nenhuma tarefa ainda';
  @override
  String get dashboardCreateFirstTask => 'Criar Primeira Tarefa';
  @override
  String get dashboardTaskDeleted => 'Tarefa excluída';

  @override
  String get taskNewTask => 'Nova Tarefa';
  @override
  String get taskTitleHint => 'O que precisa ser feito?';
  @override
  String get taskCategory => 'Categoria';
  @override
  String get taskPriority => 'Prioridade';
  @override
  String get taskPriorityLow => 'Baixa';
  @override
  String get taskPriorityMedium => 'Média';
  @override
  String get taskPriorityHigh => 'Alta';
  @override
  String get taskSetDeadline => 'Definir Prazo (Opcional)';
  @override
  String get taskCreate => 'Criar Tarefa';
  @override
  String get taskDefaultCategory => 'Geral';
  @override
  String get taskStartFocus => 'Iniciar Sessão de Foco';
  @override
  String get taskEdit => 'Editar Tarefa';
  @override
  String get taskUpdate => 'Atualizar Tarefa';
  
  @override
  String get settingsTitle => 'Ajustes & Ferramentas';
  @override
  String get settingsPremium => 'Recursos Premium';
  @override
  String get settingsAmbientSounds => 'Sons Ambientes';
  @override
  String get settingsAmbientSoundsSubtitle => 'Música de foco e ruído branco';
  @override
  String get settingsAchievements => 'Conquistas';
  @override
  String get settingsAchievementsSubtitle => 'Medalhas & Recompensas';
  @override
  String get settingsMotivation => 'Motivação Diária';
  @override
  String get settingsMotivationSubtitle => 'Frases inspiradoras';
  @override
  String get settingsExport => 'Exportar Relatórios';
  @override
  String get settingsExportSubtitle => 'Baixar resumo de estudos em PDF';
  @override
  String get settingsApp => 'Ajustes do App';
  @override
  String get settingsDarkMode => 'Modo Escuro';
  @override
  String get settingsNotifications => 'Notificações';
  @override
  String get settingsLanguage => 'Idioma';
  @override
  String get settingsData => 'Dados';
  @override
  String get settingsResetData => 'Redefinir Todos os Dados';
  @override
  String get settingsResetDialogTitle => 'Redefinir Dados?';
  @override
  String get settingsResetDialogContent => 'Isso excluirá todas as tarefas e sessões. Esta ação não pode ser desfeita.';
  @override
  String get settingsCancel => 'Cancelar';
  @override
  String get settingsReset => 'Redefinir';
  @override
  String get settingsResetSuccess => 'Todos os dados foram redefinidos com sucesso';
  @override
  String get settingsSelectLanguage => 'Selecionar Idioma';
  
  @override
  String get tooltipAIAssistant => 'Assistente de IA';
  @override
  String get tooltipCalendarView => 'Visualização em Calendário';
  @override
  String get btnAddTask => 'Adicionar Tarefa';
  @override
  String get btnAdd => 'Adicionar';
  @override
  String get btnCancel => 'Cancelar';
  
  @override
  String get taskUpdated => 'Tarefa atualizada com sucesso';
  @override
  String get dialogDeleteTaskTitle => 'Excluir Tarefa?';
  @override
  String get dialogDeleteTaskContent => 'Tem certeza de que deseja excluir esta tarefa?';
  @override
  String get btnDelete => 'Excluir';
  @override
  String get taskDetails => 'Detalhes da Tarefa';
  @override
  String get labelDue => 'Prazo: ';
  @override
  String get sectionTaskInfo => 'Informações da Tarefa';
  @override
  String get labelTitle => 'Título';
  @override
  String get sectionDeadline => 'Prazo';
  @override
  String get noDeadline => 'Sem Prazo Definido';
  @override
  String get sectionNotes => 'Anotações';
  @override
  String get hintNotes => 'Adicione anotações aqui...';

  @override
  String get aiTitle => 'Assistente de Estudos com IA';
  @override
  String get aiTabPremade => 'Planos Prontos';
  @override
  String get aiTabCustom => 'Gerador com IA';
  @override
  String get aiSectionEmbedded => 'Embarcados no App (100% Offline)';
  @override
  String get aiSectionDownloadable => 'Disponíveis para Download (Nuvem)';
  @override
  String get aiBtnApplyPlan => 'Aplicar ao Planejador';
  @override
  String get aiBtnDownloadPlan => 'Baixar & Aplicar';
  @override
  String get aiStatusCustomKey => 'Chave Pessoal Ativa';
  @override
  String get aiStatusBackend => 'Backend Conectado';
  @override
  String get aiStatusOffline => 'Modo Offline (Heurístico)';
  @override
  String get aiDownloading => 'Baixando plano da nuvem...';
  @override
  String get aiGenerateTitle => 'Gere Seu Plano de Estudos';
  @override
  String get aiInputSubjects => 'Matérias (separadas por vírgula)';
  @override
  String get aiInputSubjectsHint => 'Ex: Matemática, Física, História';
  @override
  String get aiInputExamDate => 'Data da Prova';
  @override
  String get aiInputDateSelect => 'Selecionar Data';
  @override
  String get aiBtnGenerate => 'Gerar Plano com IA';
  @override
  String get aiResultTitle => 'Sua Rotina Personalizada';
  @override
  String get aiBtnAddAll => 'Adicionar Tudo ao Planejador';
  @override
  String get snackEnterSubjects => 'Por favor, insira as matérias e a data da prova';
  
  @override
  String get analyticsTitle => 'Análise de Produtividade';
  @override
  String get analyticsGenerateReport => 'Gerar Relatório';
  @override
  String get analyticsTotalHours => 'Total de Horas';
  @override
  String get analyticsSessions => 'Sessões';
  @override
  String get analyticsWeeklyFocus => 'Foco Semanal';
  
  @override
  String get pomoTitle => 'Timer Pomodoro';
  @override
  String get pomoFocusComplete => 'Sessão de Foco Concluída!';
  @override
  String get pomoBreakComplete => 'Pausa Finalizada!';
  @override
  String get pomoFocusMsg => 'Excelente trabalho! Faça uma pausa curta.';
  @override
  String get pomoBreakMsg => 'Pronto para focar novamente?';
  @override
  String get pomoBtnStartBreak => 'Iniciar Pausa';
  @override
  String get pomoBtnStartFocus => 'Iniciar Foco';
  @override
  String get pomoTooltipSwitch => 'Alternar Modo';
  @override
  String get pomoStatusFocus => 'Tempo de Foco';
  @override
  String get pomoStatusBreak => 'Tempo de Pausa';
  
  @override
  String get focusTitle => 'FOCO PROFUNDO';
  
  @override
  String get flashcardsTitle => 'Cartões Inteligentes';
  @override
  String get flashcardsMyDecks => 'Meus Baralhos';
  @override
  String get flashcardsReviewNow => 'Revisar Agora';
  @override
  String get flashcardsEmpty => 'Nenhum cartão ainda';
  @override
  String get flashcardsCreate => 'Crie seu primeiro cartão';
  @override
  String get flashcardsAllCaughtUp => 'Tudo em dia!';
  @override
  String get flashcardsComeBackLater => 'Volte mais tarde para novas revisões.';
  @override
  String get flashcardsAddTitle => 'Adicionar Novo Cartão';
  @override
  String get flashcardsSubjectHint => 'Matéria (Ex: Matemática)';
  @override
  String get flashcardsQuestion => 'Pergunta';
  @override
  String get flashcardsAnswer => 'Resposta';
  @override
  String get flashcardsTapToShow => 'Toque para mostrar a resposta';
  @override
  String get flashcardsHard => 'Difícil';
  @override
  String get flashcardsGood => 'Bom';
  @override
  String get flashcardsEasy => 'Fácil';
  
  @override
  String get reportTitle => 'Exportar Relatórios';
  @override
  String get reportGenerate => 'Gerar Relatório de Estudo';
  @override
  String get reportDesc => 'Baixe um relatório detalhado em PDF de suas sessões de estudo, tarefas concluídas e estatísticas de produtividade.';
  @override
  String get reportExportPdf => 'Exportar PDF';
  @override
  String get reportPrint => 'Imprimir / Visualizar';
  
  @override
  String get pdfTitle => 'StudyFlow - Relatório de Progresso';
  @override
  String get pdfSummary => 'Resumo';
  @override
  String get pdfTotalTasks => 'Total de Tarefas';
  @override
  String get pdfCompleted => 'Concluídas';
  @override
  String get pdfPending => 'Pendentes';
  @override
  String get pdfStudyHours => 'Horas de Estudo';
  @override
  String get pdfRecentSessions => 'Sessões Recentes de Estudo';
  @override
  String get pdfColDate => 'Data';
  @override
  String get pdfColDuration => 'Duração (min)';
  @override
  String get pdfColTask => 'ID da Tarefa';
  @override
  String get pdfFocusSession => 'Sessão de Foco';
  
  @override
  String get achievementsTitle => 'Conquistas';
  @override
  String get badgeFirstStep => 'Primeiro Passo';
  @override
  String get badgeFirstStepDesc => 'Conclua sua primeira tarefa';
  @override
  String get badgeFocusMaster => 'Mestre do Foco';
  @override
  String get badgeFocusMasterDesc => 'Conclua 10 sessões Pomodoro';
  @override
  String get badgePlannerPro => 'Planejador Pro';
  @override
  String get badgePlannerProDesc => 'Crie 50 tarefas';
  @override
  String get badgeEarlyBird => 'Madrugador';
  @override
  String get badgeEarlyBirdDesc => 'Conclua uma tarefa antes das 8h';
  @override
  String get badgeNightOwl => 'Coruja Noturna';
  @override
  String get badgeNightOwlDesc => 'Conclua uma sessão após as 22h';
  @override
  String get badgeStreakKing => 'Rei da Sequência';
  @override
  String get badgeStreakKingDesc => 'Sequência de estudos de 7 dias';
  
  @override
  String get quotesTitle => 'Motivação Diária';
  @override
  String get quoteCopied => 'Frase copiada para a área de transferência!';
  @override
  String get quote1 => 'O segredo de progredir é começar.';
  @override
  String get quoteAuthor1 => 'Mark Twain';
  @override
  String get quote2 => 'Sempre parece impossível até que seja feito.';
  @override
  String get quoteAuthor2 => 'Nelson Mandela';
  @override
  String get quote3 => 'Não olhe para o relógio; faça como ele: continue em movimento.';
  @override
  String get quoteAuthor3 => 'Sam Levenson';
  @override
  String get quote4 => 'Acredite que você pode e você já está no meio do caminho.';
  @override
  String get quoteAuthor4 => 'Theodore Roosevelt';
  @override
  String get quote5 => 'O sucesso é a soma de pequenos esforços repetidos dia após dia.';
  @override
  String get quoteAuthor5 => 'Robert Collier';
  @override
  String get quote6 => 'O futuro pertence àqueles que acreditam na beleza de seus sonhos.';
  @override
  String get quoteAuthor6 => 'Eleanor Roosevelt';
  @override
  String get quote7 => 'Você não precisa ser ótimo para começar, mas precisa começar para ser ótimo.';
  @override
  String get quoteAuthor7 => 'Zig Ziglar';
  
  @override
  String get soundsTitle => 'Sons de Foco Ambiente';
  @override
  String get soundRain => 'Chuva';
  @override
  String get soundForest => 'Floresta';
  @override
  String get soundFire => 'Fogueira';
  @override
  String get soundStream => 'Riacho';
  @override
  String get soundCafe => 'Cafeteria';
  @override
  String get soundWhiteNoise => 'Ruído Branco';
  @override
  String get soundLibrary => 'Biblioteca';
  @override
  String get soundNight => 'Noite';
  
  @override
  String get onboardingTitle1 => 'Domine Seu Horário';
  @override
  String get onboardingDesc1 => 'Crie planos de estudo personalizados e acompanhe seus prazos com facilidade.';
  @override
  String get onboardingTitle2 => 'Modo Foco Profundo';
  @override
  String get onboardingDesc2 => 'Elimine distrações com nosso timer de foco otimizado para AMOLED.';
  @override
  String get onboardingTitle3 => 'Gamifique Seu Aprendizado';
  @override
  String get onboardingDesc3 => 'Ganhe medalhas, mantenha sequências e visualize seu progresso.';
  @override
  String get onboardingNext => 'Próximo';
  @override
  String get onboardingGetStarted => 'Começar';
  
  @override
  String get langEnglish => 'Inglês (English)';
  @override
  String get langSpanish => 'Espanhol (Español)';
  @override
  String get langPortuguese => 'Português (Português)';
  
  @override
  String get prefAmbientSounds => 'Sons Ambientes';
  @override
  String get prefAmbientSoundsSubtitle => 'Música de foco e ruído branco';
  @override
  String get prefAchievements => 'Conquistas';
  @override
  String get prefAchievementsSubtitle => 'Medalhas & Recompensas';
  @override
  String get prefDailyMotivation => 'Motivação Diária';
  @override
  String get prefDailyMotivationSubtitle => 'Frases inspiradoras';
  @override
  String get prefExportReports => 'Exportar Relatórios';
  @override
  String get prefExportReportsSubtitle => 'Baixar resumo de estudos em PDF';
  @override
  String get sectionAppSettings => 'Ajustes do App';
  @override
  String get prefDarkMode => 'Modo Escuro';
  @override
  String get prefNotifications => 'Notificações';
  @override
  String get prefLanguage => 'Idioma';
  @override
  String get prefApiKey => 'Chave de IA (Opcional)';
  @override
  String get prefApiKeySubtitle => 'Configurar API Key pessoal (Gemini ou OpenRouter)';
  @override
  String get dialogApiKeyTitle => 'Chave de API de IA';
  @override
  String get dialogApiKeyHint => 'Cole sua chave (AIza... ou sk-or-...)';
  @override
  String get dialogApiKeyDesc => 'Sua chave fica salva apenas na memória do seu celular de forma segura.';
  @override
  String get btnSave => 'Salvar';
  @override
  String get snackApiKeySaved => 'Chave de IA salva com sucesso!';
  @override
  String get snackApiKeyCleared => 'Chave de IA removida!';
  @override
  String get sectionData => 'Dados';
  @override
  String get prefResetData => 'Redefinir Todos os Dados';
  @override
  String get dialogResetTitle => 'Redefinir Dados?';
  @override
  String get dialogResetContent => 'Isso excluirá todas as tarefas e sessões. Esta ação não pode ser desfeita.';
  @override
  String get btnReset => 'Redefinir';
  @override
  String get snackDataReset => 'Todos os dados foram redefinidos com sucesso';
  @override
  String get dialogLanguageTitle => 'Selecionar Idioma';

  @override
  String snackAddedTask(String task) => 'Adicionado "$task" ao planejador';
  @override
  String snackAddedAll(int count) => 'Adicionadas $count tarefas ao planejador';
  @override
  String aiError(Object error) => 'Falha na Geração com IA: $error';
  @override
  String soundPlaying(String sound) => 'Tocando $sound...';
  @override
  String flashcardsCount(int count) => '$count cartões';
  @override
  String flashcardsDue(int count) => '$count para revisar';
  @override
  String reportError(Object error) => 'Erro ao exportar PDF: $error';
  @override
  String pdfGeneratedOn(String date) => 'Gerado em: $date';
}

