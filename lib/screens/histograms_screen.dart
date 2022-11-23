import 'package:flutter/material.dart';

class HistogramsScreen extends StatefulWidget {
  static String route = "HistogramsScreen";
  const HistogramsScreen({super.key});

  @override
  State<HistogramsScreen> createState() => _HistogramsScreenState();
}

class _HistogramsScreenState extends State<HistogramsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text("Histograms"),
      ),
    );
  }
}
