class ApiConfig {
  // Url
  static const bool isABC = true;
  static const String baseUrl = isABC ? 'https://practice-test.abc-elearning.org' : 'https://3dcad279c0b4.ngrok-free.app';
  // static const String baseUrl = 'https://chatbot-flow-server.abc-elearning.org';
  // static const String baseUrl = 'http://localhost:8000';

  // Endpoints
  static const String getMessagesEndpoint = '/api/messages/get-messages';
  static const String markAsSeenEndpoint = '/api/messages/mark-as-seen';
  static const String healthEndpoint = '/api/messages/health';
}
