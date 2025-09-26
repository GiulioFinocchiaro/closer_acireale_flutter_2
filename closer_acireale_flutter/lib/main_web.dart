import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'main.dart';

void main() {
  // Rimuove il # dall'URL per una migliore SEO e UX
  usePathUrlStrategy();
  
  // Avvia l'applicazione principale
  runApp(const CloserAcirealeApp());
}