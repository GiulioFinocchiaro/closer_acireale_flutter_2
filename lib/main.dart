import 'package:closer_acireale_flutter/app_wrapper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CloserAcirealeApp());
}

class CloserAcirealeApp extends StatelessWidget {
  const CloserAcirealeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppWrapper();
  }
}