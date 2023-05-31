import 'package:flutter/material.dart';

class Pin extends StatelessWidget {
  final double x;
  final double y;

  Pin(this.x, this.y);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(x, y),
      child: Container(
        child: Image(
          image: AssetImage("lib/Images/pin.png"),
        ),
        height: 70,
        width: 70,
      ),
    );
  }
}
