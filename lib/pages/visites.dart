import 'package:flutter/material.dart';

class Visites extends StatefulWidget {
  const Visites({super.key});

  @override
  State<Visites> createState() => _VisitesState();
}

class _VisitesState extends State<Visites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Visites'),
      ),
    );
  }
}