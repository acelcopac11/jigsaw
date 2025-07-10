import 'package:flutter/material.dart';
import '../services/unsplash_service.dart'; // ajustați path-ul dacă nu e corect
import 'puzzle_game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  final String difficulty;
  const LevelSelectScreen({super.key, required this.difficulty});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final UnsplashService _unsplashService = UnsplashService();
  late Future<List<String>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture = _unsplashService.getRandomImages(count: 6, query: "puzzle");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Niveluri - ${widget.difficulty}'),
      ),
      body: FutureBuilder<List<String>>(
        future: _imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Eroare la încărcarea imaginilor!'));
          }
          final images = snapshot.data!;
          return GridView.count(
            crossAxisCount: 2,
            children: images
                .map((imgUrl) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  int gridSize;
                  switch (widget.difficulty) {
                    case 'Ușor (3x3)':
                      gridSize = 3;
                      break;
                    case 'Mediu (5x5)':
                      gridSize = 5;
                      break;
                    case 'Greu (8x8)':
                      gridSize = 8;
                      break;
                    default:
                      gridSize = 3;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PuzzleGameScreen(
                        imageUrl: imgUrl,
                        gridSize: gridSize,
                      ),
                    ),
                  );
                },
                child: Image.network(imgUrl, fit: BoxFit.cover),
              ),
            ))
                .toList(),
          );
        },
      ),
    );
  }
}