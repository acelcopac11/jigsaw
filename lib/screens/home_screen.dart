import 'package:flutter/material.dart';
import 'level_select_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void goToLevels(BuildContext context, String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelSelectScreen(difficulty: difficulty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jigsaw Puzzle'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Alege dificultatea',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => goToLevels(context, 'Ușor (3x3)'),
              child: const Text('Ușor (3x3)'),
            ),
            ElevatedButton(
              onPressed: () => goToLevels(context, 'Mediu (5x5)'),
              child: const Text('Mediu (5x5)'),
            ),
            ElevatedButton(
              onPressed: () => goToLevels(context, 'Greu (8x8)'),
              child: const Text('Greu (8x8)'),
            ),
          ],
        ),
      ),
    );
  }
}