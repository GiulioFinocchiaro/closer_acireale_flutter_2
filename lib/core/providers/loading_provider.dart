import 'package:flutter/foundation.dart';

class LoadingProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _loadingTitle = 'Caricamento...';
  String _loadingMessage = '';
  double? _progress;
  VoidCallback? _onCancel;

  // Getters
  bool get isLoading => _isLoading;
  String get loadingTitle => _loadingTitle;
  String get loadingMessage => _loadingMessage;
  double? get progress => _progress;
  VoidCallback? get onCancel => _onCancel;

  // Mostra loading generico
  void showLoading({
    String title = 'Caricamento...',
    String message = '',
    VoidCallback? onCancel,
  }) {
    _isLoading = true;
    _loadingTitle = title;
    _loadingMessage = message;
    _progress = null;
    _onCancel = onCancel;
    notifyListeners();
  }

  // Mostra loading con progresso
  void showLoadingWithProgress({
    String title = 'Caricamento...',
    String message = '',
    double progress = 0.0,
    VoidCallback? onCancel,
  }) {
    _isLoading = true;
    _loadingTitle = title;
    _loadingMessage = message;
    _progress = progress.clamp(0.0, 1.0);
    _onCancel = onCancel;
    notifyListeners();
  }

  // Aggiorna il progresso
  void updateProgress(double progress, {String? message}) {
    if (_isLoading) {
      _progress = progress.clamp(0.0, 1.0);
      if (message != null) {
        _loadingMessage = message;
      }
      notifyListeners();
    }
  }

  // Aggiorna il messaggio
  void updateMessage(String message) {
    if (_isLoading) {
      _loadingMessage = message;
      notifyListeners();
    }
  }

  // Nascondi loading
  void hideLoading() {
    _isLoading = false;
    _loadingTitle = 'Caricamento...';
    _loadingMessage = '';
    _progress = null;
    _onCancel = null;
    notifyListeners();
  }

  // Loading preconfigurati per operazioni comuni
  void showLoginLoading() {
    showLoading(
      title: 'Accesso in corso...',
      message: 'Verifica delle credenziali',
    );
  }

  void showLogoutLoading() {
    showLoading(
      title: 'Disconnessione...',
      message: 'Chiusura sessione in corso',
    );
  }

  void showSaveLoading() {
    showLoading(
      title: 'Salvataggio...',
      message: 'Salvataggio dati in corso',
    );
  }

  void showDeleteLoading() {
    showLoading(
      title: 'Eliminazione...',
      message: 'Eliminazione in corso',
    );
  }

  void showDataLoading() {
    showLoading(
      title: 'Caricamento Dati...',
      message: 'Recupero informazioni dal server',
    );
  }

  void showUploadLoading() {
    showLoadingWithProgress(
      title: 'Caricamento File...',
      message: 'Upload in corso',
      progress: 0.0,
    );
  }
}