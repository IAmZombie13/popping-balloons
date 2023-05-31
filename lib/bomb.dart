import 'package:flutter/material.dart';

class Bomb extends StatelessWidget {
  final double x;
  final double y;
  final double pop; //to show if popped balloon or non popped one

  Bomb(this.x, this.y, this.pop);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(x, y),
      child: Container(
        width: 100,
        height: 100,
        child: OverflowBox(
          child: pop == 0
              ? Image.asset("lib/Images/bomb.png")
              : Image.asset("lib/Images/boom.png"),
        ),
      ),
    );
  }
}
