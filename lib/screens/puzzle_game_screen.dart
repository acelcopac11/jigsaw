import 'package:flutter/material.dart';
import '../widgets/puzzle_board.dart';

class PuzzleGameScreen extends StatelessWidget {
  final String imageUrl;
  final int gridSize;

  const PuzzleGameScreen({
    super.key,
    required this.imageUrl,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle $gridSize x $gridSize'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text('Puzzle de dificultate $gridSize x $gridSize', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            PuzzleBoard(
              imageUrl: imageUrl,
              gridSize: gridSize,
            ),
          ],
        ),
      ),
    );
  }
}