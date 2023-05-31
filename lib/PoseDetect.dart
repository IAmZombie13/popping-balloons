import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:typed_data';

import 'homepage.dart';

double? x;
double? y;

class PoseDetectorCamera extends StatefulWidget {
  final List<CameraDescription> cameras;

  PoseDetectorCamera({Key? key, required this.cameras}) : super(key: key);

  @override
  PoseDetectorCameraState createState() => PoseDetectorCameraState();
}

class PoseDetectorCameraState extends State<PoseDetectorCamera> {
  late CameraController _cameraController;
  bool _isDetecting = false;
  final PoseDetector _poseDetector = GoogleMlKit.vision.poseDetector();

  //double? x;
  //double? y;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      _cameraController.startImageStream((CameraImage image) {
        if (_isDetecting) return;
        _isDetecting = true;
        detectPose(image).then((_) => _isDetecting = false);
      });
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _poseDetector.close();
    super.dispose();
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    // We assume that all planes have the same row stride, so we only need to care about the
    // total number of bytes in each plane.
    int allBytes = 0;
    for (Plane plane in planes) {
      allBytes += plane.bytes.length;
    }

    // Allocate a new buffer and copy all plane buffers into it
    Uint8List concatenated = Uint8List(allBytes);
    int offset = 0;
    for (Plane plane in planes) {
      concatenated.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }

    return concatenated;
  }

  Future<void> detectPose(CameraImage image) async {
    InputImage inputImage = InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      inputImageData: InputImageData(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        imageRotation: InputImageRotation.rotation0deg,
        inputImageFormat: InputImageFormat.yuv_420_888,
        planeData: null,
      ),
    );

    List<Pose> poses = await _poseDetector.processImage(inputImage);
    for (Pose pose in poses) {
      PoseLandmark? landmark = pose.landmarks[PoseLandmarkType.rightWrist];

      setState(() {
        x = landmark?.x;
        y = landmark?.y;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Center(
        child: Text(
          "CAMERA NOT INITIALISED",
          style: TextStyle(fontSize: 50),
        ),
      );
    }

    //THE CODE BEFORE
    /*return Column(
      children: [
        AspectRatio(
          aspectRatio: _cameraController.value.aspectRatio,
          child: CameraPreview(_cameraController),
        ),
        Text(
          "type=$type\nx=$x\ny=$y",
        ),
      ],
    );*/

    //added code
    return Stack(
      children: [
        HomePage(),
        Container(
          alignment: const Alignment(1, 1),
          child: Text(
            "x=$x\ny=$y",
            style: const TextStyle(
              backgroundColor: Colors.black,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
