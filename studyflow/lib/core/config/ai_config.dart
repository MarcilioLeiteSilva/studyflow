class AIConfig {
  // Backend API URL
  // Utiliza http://127.0.0.1:3000 (funciona com adb reverse no dispositivo USB e web/desktop)
  // No emulador Android puro pode-se usar http://10.0.2.2:3000
  static const String defaultBackendUrl = 'http://127.0.0.1:3000';

  // Configurações para chave personalizada do usuário (BYOK)
  static const String openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String defaultModelId = 'google/gemini-2.0-flash-001';

  // App Identity
  static const String siteUrl = 'https://studyflow.app';
  static const String appName = 'StudyFlow';
}
