import 'package:flutter/material.dart';
import 'PoseDetect.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FutureBuilder(
          future: availableCameras(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final cameras = snapshot.data as List<CameraDescription>;
              return PoseDetectorCamera(cameras: cameras);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
