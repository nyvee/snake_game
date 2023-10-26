import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      debugShowCheckedModeBanner: false,
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141414),
      body: Center(
        child: SnakeGameScreen(),
      ),
    );
  }
}

class SnakeGameScreen extends StatefulWidget {
  @override
  _SnakeGameScreenState createState() => _SnakeGameScreenState();
}

class Position {
  final int row;
  final int col;

  Position(this.row, this.col);
}

enum Direction { up, down, left, right }

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int rows = 40;
  static const int cols = 25;
  static const double gridSize = 15.0;

  List<Position> snake = [Position(5, 5)];
  Position food = Position(10, 10);
  Direction direction = Direction.down;
  bool isGameOver = false;
  bool isGameStarted = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
  }

  void startGameAfterTap() {
    if (!isGameStarted) {
      isGameStarted = true;
      startGame();
    }
  }

  void restartGame() {
    setState(() {
      snake = [Position(5, 5)];
      food = Position(10, 10);
      direction = Direction.down;
      isGameOver = false;
      score = 0;
    });
    startGame();
  }

  void startGame() {
    const duration = Duration(milliseconds: 300);
    Timer.periodic(duration, (timer) {
      if (!isGameOver) {
        updateSnake();
        if (checkCollision()) {
          timer.cancel();
          onGameOver();
        }
        setState(() {});
      }
    });
  }

  void updateSnake() {
    setState(() {
      switch (direction) {
        case Direction.up:
          snake.insert(0, Position(snake.first.row - 1, snake.first.col));
          break;
        case Direction.down:
          snake.insert(0, Position(snake.first.row + 1, snake.first.col));
          break;
        case Direction.left:
          snake.insert(0, Position(snake.first.row, snake.first.col - 1));
          break;
        case Direction.right:
          snake.insert(0, Position(snake.first.row, snake.first.col + 1));
          break;
      }
      if (snake.first.row == food.row && snake.first.col == food.col) {
        generateFood();
        score += 10;
      } else {
        snake.removeLast();
      }
    });
  }

  void generateFood() {
    final random = Random();
    int newRow, newCol;
    do {
      newRow = random.nextInt(rows - 2) + 1;
      newCol = random.nextInt(cols - 2) + 1;
    } while (snake.contains(Position(newRow, newCol)));
    food = Position(newRow, newCol);
  }

  bool checkCollision() {
    if (snake.first.row < 2 ||
        snake.first.row >= rows - 2 ||
        snake.first.col < 2 ||
        snake.first.col >= cols - 2 ||
        snake.skip(1).contains(snake.first)) {
      return true;
    }
    for (var i = 1; i < snake.length; i++) {
      if (snake[i].row == snake.first.row && snake[i].col == snake.first.col) {
        return true;
      }
    }
    return false;
  }

  void onGameOver() {
    setState(() {
      isGameOver = true;
    });
  }

  Widget drawSnake() {
    return Stack(
      children: snake
          .map((pos) => Positioned(
                left: pos.col * gridSize,
                top: pos.row * gridSize,
                child: Container(
                  width: gridSize,
                  height: gridSize,
                  decoration: BoxDecoration(
                    color: Color(0xFF437E44),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget drawFood() {
    return Positioned(
      left: food.col * gridSize,
      top: food.row * gridSize,
      child: Container(
        width: gridSize,
        height: gridSize,
        decoration: BoxDecoration(
          color: Color(0xFF975555),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget drawGameOver() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Game Over',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Score: $score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget drawWalls() {
    List<Widget> walls = [];

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if ((row == 0 || row == rows - 1) || (col == 0 || col == cols - 1)) {
          walls.add(Positioned(
            top: row * gridSize,
            left: col * gridSize,
            child: Container(
              width: gridSize,
              height: gridSize,
              color: Colors.white,
            ),
          ));
        }
      }
    }
    return Stack(children: walls);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isGameStarted) {
          isGameStarted = true;
          startGame();
        }
      },
      onVerticalDragUpdate: (details) {
        if (direction != Direction.up && details.delta.dy > 0) {
          direction = Direction.down;
        } else if (direction != Direction.down && details.delta.dy < 0) {
          direction = Direction.up;
        }
      },
      onHorizontalDragUpdate: (details) {
        if (direction != Direction.left && details.delta.dx > 0) {
          direction = Direction.right;
        } else if (direction != Direction.right && details.delta.dx < 0) {
          direction = Direction.left;
        }
      },
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(top: 80, bottom: 20, left: 20, right: 20),
              child: Column(
                children: [
                  Text(
                    'Snake Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Score: $score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                color: Color(0xFF141414),
                width: cols * gridSize,
                height: rows * gridSize,
                child: Stack(
                  children: <Widget>[
                    drawWalls(),
                    drawSnake(),
                    drawFood(),
                    if (isGameOver)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            drawGameOver(),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: restartGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Restart Game',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
