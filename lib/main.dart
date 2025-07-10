import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const JigsawPuzzleApp());
}

class JigsawPuzzleApp extends StatelessWidget {
  const JigsawPuzzleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jigsaw Puzzle Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}