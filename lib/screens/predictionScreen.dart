import 'package:flutter/material.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Screen"),
      ),
      body: const Center(
        child: Text("Prediction Functionality Coming Soon!"),
      ),
    );
  }
}