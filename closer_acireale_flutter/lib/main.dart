import 'package:closer_acireale_flutter/app_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza i dati locali per la lingua desiderata
  await initializeDateFormatting('it_IT', null);
  doWhenWindowReady(() {
    final initialSize = Size(800, 600); // puoi ignorarlo
    appWindow.size = initialSize;
    appWindow.maximize(); // <-- Questo manda la finestra a fullscreen
    appWindow.show();
  });
  runApp(const CloserAcirealeApp());
}

class CloserAcirealeApp extends StatelessWidget {
  const CloserAcirealeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppWrapper();
  }
}