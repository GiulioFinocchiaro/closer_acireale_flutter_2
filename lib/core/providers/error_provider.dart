import 'package:flutter/foundation.dart';

enum ErrorType {
  network,
  timeout,
  unauthorized,
  server,
  validation,
  general,
}

class ErrorProvider extends ChangeNotifier {
  bool _hasError = false;
  String _errorMessage = '';
  ErrorType _errorType = ErrorType.general;
  VoidCallback? _onRetry;
  VoidCallback? _onSecondaryAction;
  String? _secondaryActionText;

  // Getters
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  ErrorType get errorType => _errorType;
  VoidCallback? get onRetry => _onRetry;
  VoidCallback? get onSecondaryAction => _onSecondaryAction;
  String? get secondaryActionText => _secondaryActionText;

  // Mostra errore con tipo specifico
  void showError({
    required String message,
    ErrorType type = ErrorType.general,
    VoidCallback? onRetry,
    VoidCallback? onSecondaryAction,
    String? secondaryActionText,
  }) {
    _hasError = true;
    _errorMessage = message;
    _errorType = type;
    _onRetry = onRetry;
    _onSecondaryAction = onSecondaryAction;
    _secondaryActionText = secondaryActionText;
    notifyListeners();
  }

  // Errori specifici con messaggi predefiniti
  void showNetworkError({VoidCallback? onRetry}) {
    showError(
      message: 'Problema di connessione.\nVerifica la tua connessione internet e riprova.',
      type: ErrorType.network,
      onRetry: onRetry,
    );
  }

  void showTimeoutError({VoidCallback? onRetry}) {
    showError(
      message: 'La richiesta ha impiegato troppo tempo.\nRiprova più tardi.',
      type: ErrorType.timeout,
      onRetry: onRetry,
    );
  }

  void showUnauthorizedError({VoidCallback? onLogin}) {
    showError(
      message: 'Non sei autorizzato ad accedere a questa risorsa.\nEffettua nuovamente l\'accesso.',
      type: ErrorType.unauthorized,
      onRetry: onLogin,
    );
  }

  void showServerError({VoidCallback? onRetry}) {
    showError(
      message: 'Si è verificato un errore del server.\nRiprova più tardi.',
      type: ErrorType.server,
      onRetry: onRetry,
    );
  }

  void showValidationError(String message) {
    showError(
      message: message,
      type: ErrorType.validation,
    );
  }

  // Pulisci errore
  void clearError() {
    _hasError = false;
    _errorMessage = '';
    _errorType = ErrorType.general;
    _onRetry = null;
    _onSecondaryAction = null;
    _secondaryActionText = null;
    notifyListeners();
  }

  // Utility per gestire eccezioni comuni
  void handleException(dynamic exception, {VoidCallback? onRetry}) {
    String message = exception.toString();
    ErrorType type = ErrorType.general;

    if (message.contains('SocketException') || 
        message.contains('NetworkException') ||
        message.contains('Connection failed')) {
      type = ErrorType.network;
      message = 'Problema di connessione.\nVerifica la tua connessione internet e riprova.';
    } else if (message.contains('TimeoutException') || 
               message.contains('timeout')) {
      type = ErrorType.timeout;
      message = 'La richiesta ha impiegato troppo tempo.\nRiprova più tardi.';
    } else if (message.contains('401') || 
               message.contains('Unauthorized')) {
      type = ErrorType.unauthorized;
      message = 'Non sei autorizzato ad accedere a questa risorsa.\nEffettua nuovamente l\'accesso.';
    } else if (message.contains('5')) { // 5xx server errors
      type = ErrorType.server;
      message = 'Si è verificato un errore del server.\nRiprova più tardi.';
    } else {
      // Cerca di estrarre messaggio più user-friendly
      if (message.contains(':')) {
        String extracted = message.split(':').last.trim();
        if (extracted.isNotEmpty && extracted.length < 200) {
          message = extracted;
        } else {
          message = 'Si è verificato un errore imprevisto.\nRiprova più tardi.';
        }
      } else {
        message = 'Si è verificato un errore imprevisto.\nRiprova più tardi.';
      }
    }

    showError(
      message: message,
      type: type,
      onRetry: onRetry,
    );
  }
}