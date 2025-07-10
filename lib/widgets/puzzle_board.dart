import 'package:flutter/material.dart';

class PuzzleBoard extends StatefulWidget {
  final String imageUrl;
  final int gridSize;
  const PuzzleBoard({super.key, required this.imageUrl, required this.gridSize});

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard> {
  late List<int> positions;

  @override
  void initState() {
    super.initState();
    positions = List.generate(widget.gridSize * widget.gridSize, (i) => i);
    positions.shuffle();
  }

  void swapTiles(int i, int j) {
    setState(() {
      final temp = positions[i];
      positions[i] = positions[j];
      positions[j] = temp;
    });
    if (_isSolved()) {
      Future.delayed(const Duration(milliseconds: 200), () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Bravo!'),
            content: const Text('Ai rezolvat puzzle-ul!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  bool _isSolved() {
    for (int i = 0; i < positions.length; i++) {
      if (positions[i] != i) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Folosește cel mai mic dintre lățime și înălțime pentru a forța pătrat
    final double screenSize = MediaQuery.of(context).size.shortestSide - 32;
    final double boardSize = screenSize > 350 ? 350 : screenSize;
    final double tileSize = boardSize / widget.gridSize;

    return Center(
      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridSize,
          ),
          itemCount: positions.length,
          itemBuilder: (context, i) {
            final pos = positions[i];
            final x = pos % widget.gridSize;
            final y = pos ~/ widget.gridSize;
            return DragTarget<int>(
              onWillAcceptWithDetails: (details) => details.data != i,
              onAcceptWithDetails: (details) {
                swapTiles(details.data, i);
              },
              builder: (context, candidateData, rejectedData) {
                return Draggable<int>(
                  data: i,
                  feedback: _buildTile(x, y, tileSize, boardSize, 0.7),
                  childWhenDragging: Container(
                    width: tileSize,
                    height: tileSize,
                    color: Colors.grey.shade200,
                  ),
                  child: _buildTile(x, y, tileSize, boardSize, 1.0),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTile(int x, int y, double tileSize, double boardSize, double opacity) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: tileSize,
        height: tileSize,
        child: ClipRect(
          child: Align(
            alignment: Alignment(
              -1.0 + 2.0 * x / (widget.gridSize - 1),
              -1.0 + 2.0 * y / (widget.gridSize - 1),
            ),
            widthFactor: 1 / widget.gridSize,
            heightFactor: 1 / widget.gridSize,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: boardSize,
                height: boardSize,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Note: This widget assumes that the image at `widget.imageUrl` is large enough
// to be split into the required grid size. The image must be accessible over the network.