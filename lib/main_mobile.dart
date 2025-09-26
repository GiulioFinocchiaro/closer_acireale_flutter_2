import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configura l'orientamento per mobile (solo portrait)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configura la status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Avvia l'applicazione principale
  runApp(const CloserAcirealeApp());
}