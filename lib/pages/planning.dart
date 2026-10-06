import 'package:flutter/material.dart';

class Planning extends StatefulWidget {
  const Planning({super.key});

  @override
  State<Planning> createState() => _PlanningState();
}

class _PlanningState extends State<Planning> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Planning'),
      ),
    );
  }
}