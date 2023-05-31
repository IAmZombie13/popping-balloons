import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'pin.dart';
import 'balloon.dart';
import 'bomb.dart';
import 'PoseDetect.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //sensitivity
  int hard = -1;

  //random class
  Random rng = new Random();

  //game Variables
  bool gameStart = false;
  int highScore = 0;
  int score = 0;

  //Pin variables
  double pinX = 0;
  double pinY = 0;

  //NOT SIZE OF LOONS AND BOMBS SHOULD BE THE SAME!!!!

  //balloons variable
  Map<String, List<double>> loons = {
    'x': [-1.0, -0.5, 0.0, 0.5, 1.0],
    'y': [-1.7, -1.7, -1.7, -1.7, -1.7, -1.7],
    'pop': [0, 0, 0, 0, 0, 0]
  };

  //bomb variables
  Map<String, List<double>> bombs = {
    'x': [-1.0, -0.5, 0.0, 0.5, 1.0],
    'y': [-2.2, -2.2, -2.2, -2.2, -2.2, -2.2],
    'pop': [0, 0, 0, 0, 0, 0]
  };

  //Baloon and bomb selected

  List<int> using = [0, 0, 0, 0, 0];

  //Modifying pin variables
  void move() {
    if (y == null && x == null) {
      pinY = 0;
    } else {
      pinY = -((y! / MediaQuery.of(context).size.height) * 2 - 1);
      pinX = -((x! / MediaQuery.of(context).size.width) * 2 - 1);
    }
  }

  //To Restart the game
  void restart() {
    gameStart = false;
    pinX = pinY = 0;
    for (int i = 0; i < loons['y']!.length; i++) {
      loons['y']![i] = -2.2;
      bombs['y']![i] = -2.2;
      loons['pop']![i] = 0;
      bombs['pop']![i] = 0;
      using[i] = 0;
    }
    setState(() {});
  }

  //IF game is Over
  void gameOver() {
    if (highScore < score) {
      highScore = score;
    }
    restart();
  }

  //to start game
  void start() {
    if (!gameStart) {
      setState(() {
        score = 0;
        gameStart = true;
      });
    }
  }

//for balloons bursting
  bool burst(int r) {
    double balloonTolerance = 0.2;

    if ((loons['x']![r] - balloonTolerance <= pinX &&
            pinX <= loons['x']![r] + balloonTolerance) &&
        (loons['y']![r] - balloonTolerance <= pinY &&
            pinY <= loons['y']![r] + balloonTolerance)) {
      return true;
    }

    return false;
  }

//for bombs bursting
  bool boom(int r) {
    double boomTolerance = 0.2;

    if ((bombs['x']![r] - boomTolerance <= pinX &&
            pinX <= bombs['x']![r] + boomTolerance) &&
        (bombs['y']![r] - boomTolerance <= pinY &&
            pinY <= bombs['y']![r] + boomTolerance)) {
      return true;
    }

    return false;
  }

  //for changing balloons or bombs values
  void change(int r, int c) {
    if (c != 0) {
      //ballon change
      //if loons goes out of bounds its reset
      if (loons['y']![r] > 2.2) {
        using[r] = 0;
        loons['y']![r] = -2.2;
      } else {
        loons['y']![r] += 0.025;
      }
    } else {
      //bomb change
      //IF Bombs GOES OUT OF BOUNDS IT RESETS IT
      if (bombs['y']![r] > 2.2) {
        using[r] = 0;
        bombs['y']![r] = -2.2;
      } else {
        bombs['y']![r] += 0.025;
      }
    }
  }

  //for balloons and bombs falling
  void falling(int stop) async {
    //additional variables used at the start for the delay
    int first = stop;
    int f1 = 0, f2 = 0;

    //Starts the timer for pin modification
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      move();
      if (!gameStart) {
        pinX = pinY = 0;
        timer.cancel();
      }
    });

    //selects a random variable for balloon and bomb
    //where r is balloon of choice and i tells which r
    int random(int r, int i) {
      if (using[r] != i + 1) {
        do {
          r = rng.nextInt(loons['x']!.length);
        } while (using[r] > 0 || using[r] == -1);

        using[r] = i + 1;
      }

      return r;
    }

    List<int> r = [0, 0, 0, 0];

    List<int> c = [
      rng.nextInt(2),
      rng.nextInt(2),
      rng.nextInt(2),
      rng.nextInt(2)
    ];

    //checks through r and c
    void check(int i) {
      if (using[r[i]] != -1) {
        r[i] = random(r[i], i);
        change(r[i], c[i]);

        if (using[r[i]] == 0) {
          r[i] = random(r[i], i);
          c[i] = rng.nextInt(2);
        }
      }
    }

    do {
      await Future.delayed(const Duration(milliseconds: 50));
      switch (stop) {
        case 2:
          check(2);
          if (first == 2) {
            if (f2 == 0) {
              f2 = 1;
              Timer(const Duration(seconds: 1), () {
                first--;
              });
            }
            break;
          } else {
            continue cas1;
          }
        cas1:
        case 1:
          check(1);
          if (first == 1) {
            if (f1 == 0) {
              f1 = 1;
              Timer(const Duration(seconds: 1), () {
                first--;
              });
            }
            break;
          } else {
            continue cas0;
          }
        cas0:
        case 0:
          check(0);
      }

      //checks if pin touchs the balloon or bomb
      for (int i = 0, j = loons['x']!.length - 1; i <= j; i++, j--) {
        //checks for popping or bursting
        if (using[i] != -1) {
          if (burst(i)) {
            setState(() {
              loons['pop']![i] = 1;
              using[i] = -1;
              score++;
            });

            Timer(const Duration(seconds: 1), () {
              setState(() {
                loons['pop']![i] = 0;
                loons['y']![i] = -2.2;
                using[i] = 0;
                c[i] = rng.nextInt(2);
                r[i] = random(r[i], i);
              });
            });
          }

          if (boom(i)) {
            setState(() {
              bombs['pop']![i] = 1;
              using[i] = -1;
            });

            Timer(const Duration(seconds: 1), () {
              setState(() {
                bombs['pop']![i] = 0;
                bombs['y']![i] = -2.2;
                using[i] = 0;
                gameOver();
              });
            });
          }
        }

        //Checks for popping or bursting from back
        if (using[j] != -1) {
          if (burst(j)) {
            setState(() {
              loons['pop']![j] = 1;
              using[j] = -1;
              score++;
            });

            Timer(const Duration(seconds: 1), () {
              setState(() {
                loons['pop']![j] = 0;
                loons['y']![j] = -2.2;
                using[j] = 0;
                c[j] = rng.nextInt(2);
                r[j] = random(r[j], j);
              });
            });
          }

          if (boom(j)) {
            setState(() {
              bombs['pop']![j] = 1;
              using[j] = -1;
            });

            Timer(const Duration(seconds: 1), () {
              setState(() {
                bombs['pop']![j] = 0;
                bombs['y']![j] = -2.2;
                using[j] = 0;
                gameOver();
              });
            });
          }
        }
      }

      setState(() {});

      if (!gameStart) {
        break;
      }
    } while (true);
  }

  //Show dialog option
  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown,
          title: const Center(
            child: Text(
              'Select difficulty',
              style: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            Row(
              children: [
                //LRVRL 0 BUTTON
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    hard = 0;
                    start();
                    falling(0);
                  },
                  child: const Text("level 0"),
                ),
                //LEVEL 1 BUTTON
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    hard = 1;
                    start();
                    falling(1);
                  },
                  child: const Text("level 1"),
                ),
                //LEVEL 2 BUTTON
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    hard = 2;
                    start();
                    falling(2);
                  },
                  child: const Text("level 2"),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !gameStart ? _showDialog : null /*restart*/,
      onLongPressDown: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Size size = box.size;
        setState(() {
          pinX = (details.localPosition.dx / size.width * 2) - 1;
          pinY = (details.localPosition.dy / size.height * 2) - 1;
        });
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue,
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0, -0.5),
              child: Text(!gameStart ? "Tap to play" : ""),
            ),
            Align(
              alignment: const Alignment(1, -0.8),
              child: Text(
                !gameStart ? "High Score: $highScore" : "Score: $score",
                style: const TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Pin(pinX, pinY),
            for (int i = 0;
                i < loons['x']!.length && i < loons['y']!.length;
                i++)
              Balloons(loons['x']![i], loons['y']![i], loons['pop']![i]),
            for (int i = 0;
                i < bombs['x']!.length && i < bombs['y']!.length;
                i++)
              Bomb(bombs['x']![i], bombs['y']![i], bombs['pop']![i]),
          ],
        ),
      ),
    );
  }
}
