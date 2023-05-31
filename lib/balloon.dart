import 'package:flutter/material.dart';

class Balloons extends StatelessWidget {
  final double x;
  final double y;
  final double pop; //to show if popped balloon or non popped one

  Balloons(this.x, this.y, this.pop);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(x, y),
      child: Container(
        width: 150,
        height: 150,
        child: OverflowBox(
          child: pop == 0
              ? Image.asset("lib/Images/balloon1.png")
              : Image.asset("lib/Images/popped.png"),
        ),
      ),
    );
  }
}
