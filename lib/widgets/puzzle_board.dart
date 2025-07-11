import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';

class PuzzleBoard extends StatefulWidget {
  final String imageUrl;
  final int gridSize;
  const PuzzleBoard({super.key, required this.imageUrl, required this.gridSize});

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class FloatingPiece {
  int index;
  Offset position;
  FloatingPiece({required this.index, required this.position});
}

class _PuzzleBoardState extends State<PuzzleBoard> {
  ui.Image? image;
  late List<int?> shuffledPieces; // null = mutată pe boardul final sau ca floating
  late List<int?> solutionBoard;  // null = slot gol
  List<FloatingPiece> floatingPieces = [];
  final GlobalKey stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final shuffle = List.generate(widget.gridSize * widget.gridSize, (i) => i);
    shuffle.shuffle();
    shuffledPieces = List<int?>.from(shuffle);
    solutionBoard = List.filled(widget.gridSize * widget.gridSize, null);
    _loadImage();
  }

  Future<void> _loadImage() async {
    final networkImage = NetworkImage(widget.imageUrl);
    final completer = Completer<ui.Image>();
    networkImage.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );
    final img = await completer.future;
    setState(() {
      image = img;
    });
  }

  void checkSolved() {
    bool solved = true;
    for (int i = 0; i < solutionBoard.length; i++) {
      if (solutionBoard[i] != i) {
        solved = false;
        break;
      }
    }
    if (solved) {
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

  void _moveFloatingPiece(int idx, Offset newOffset) {
    setState(() {
      floatingPieces.firstWhere((fp) => fp.index == idx).position = newOffset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenSize = MediaQuery.of(context).size.shortestSide - 32;
    final double fullBoardSize = screenSize > 350 ? 350 : screenSize;
    final double boardSize = fullBoardSize;
    final double tileSize = boardSize / widget.gridSize;
    final double totalHeight = boardSize * 2 + 32; // 2 boarduri + margin

    if (image == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: SizedBox(
        width: boardSize,
        height: totalHeight,
        child: Stack(
          key: stackKey,
          children: [
            // Board final (sus)
            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                width: boardSize,
                height: boardSize,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.gridSize,
                  ),
                  itemCount: solutionBoard.length,
                  itemBuilder: (context, i) {
                    final pieceIndex = solutionBoard[i];
                    final x = i % widget.gridSize;
                    final y = i ~/ widget.gridSize;
                    return DragTarget<int>(
                      onWillAccept: (data) => pieceIndex == null && data == i,
                      onAccept: (data) {
                        setState(() {
                          solutionBoard[i] = data;
                          final idx = shuffledPieces.indexOf(data);
                          if (idx != -1) shuffledPieces[idx] = null;
                          floatingPieces.removeWhere((fp) => fp.index == data);
                        });
                        checkSolved();
                      },
                      builder: (context, candidateData, rejectedData) {
                        if (pieceIndex == null) {
                          return Container(
                            width: tileSize,
                            height: tileSize,
                            color: Colors.grey.shade200,
                          );
                        } else {
                          final px = pieceIndex % widget.gridSize;
                          final py = pieceIndex ~/ widget.gridSize;
                          return _buildTile(px, py, tileSize, 1.0);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            // Board piese amestecate (jos)
            Positioned(
              top: boardSize + 32,
              left: 0,
              child: SizedBox(
                width: boardSize,
                height: boardSize,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.gridSize,
                  ),
                  itemCount: shuffledPieces.length,
                  itemBuilder: (context, i) {
                    final pieceIndex = shuffledPieces[i];
                    if (pieceIndex == null) {
                      return Container(
                        width: tileSize,
                        height: tileSize,
                        color: Colors.transparent,
                      );
                    }
                    final px = pieceIndex % widget.gridSize;
                    final py = pieceIndex ~/ widget.gridSize;
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Draggable<int>(
                        data: pieceIndex,
                        feedback: _buildTile(px, py, tileSize, 0.7),
                        childWhenDragging: Container(
                          width: tileSize,
                          height: tileSize,
                          color: Colors.grey.shade300,
                        ),
                        child: _buildTile(px, py, tileSize, 1.0),
                        onDragEnd: (details) {
                          if (!details.wasAccepted) {
                            // Calculăm offset-ul local față de Stack
                            final RenderBox stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
                            final localOffset = stackBox.globalToLocal(details.offset);

                            setState(() {
                              floatingPieces.add(
                                FloatingPiece(index: pieceIndex, position: localOffset),
                              );
                              shuffledPieces[i] = null;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            // Zona liberă cu piesele floating
            ...floatingPieces.map((fp) {
              final px = fp.index % widget.gridSize;
              final py = fp.index ~/ widget.gridSize;
              return Positioned(
                left: fp.position.dx,
                top: fp.position.dy,
                child: Draggable<int>(
                  data: fp.index,
                  feedback: _buildTile(px, py, tileSize, 0.7),
                  childWhenDragging: Container(
                    width: tileSize,
                    height: tileSize,
                    color: Colors.grey.shade300,
                  ),
                  child: _buildTile(px, py, tileSize, 1.0),
                  onDragEnd: (details) {
                    if (!details.wasAccepted) {
                      final RenderBox stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
                      final localOffset = stackBox.globalToLocal(details.offset);
                      setState(() {
                        fp.position = localOffset;
                      });
                    } else {
                      setState(() {
                        floatingPieces.removeWhere((p) => p.index == fp.index);
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(int x, int y, double tileSize, double opacity) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: tileSize,
        height: tileSize,
        child: CustomPaint(
          painter: _TilePainter(
            image!,
            x,
            y,
            widget.gridSize,
            tileSize,
          ),
        ),
      ),
    );
  }
}

class _TilePainter extends CustomPainter {
  final ui.Image image;
  final int x, y, gridSize;
  final double tileSize;

  _TilePainter(this.image, this.x, this.y, this.gridSize, this.tileSize);

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      x * image.width / gridSize,
      y * image.height / gridSize,
      image.width / gridSize,
      image.height / gridSize,
    );
    final dst = Rect.fromLTWH(0, 0, tileSize, tileSize);
    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}