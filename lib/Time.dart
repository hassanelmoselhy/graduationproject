import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class ExerciseTimerPage extends StatefulWidget {
  final String exerciseName;
  final String duration;

  ExerciseTimerPage({required this.exerciseName, required this.duration});

  @override
  _ExerciseTimerPageState createState() => _ExerciseTimerPageState();
}

class _ExerciseTimerPageState extends State<ExerciseTimerPage> {
  int secondsRemaining = 0;
  Timer? _timer;
  final player = AudioPlayer();
  CameraController? _cameraController;
  bool isRecording = false;
  String? videoPath;

  @override
  void initState() {
    super.initState();
    secondsRemaining = parseDuration(widget.duration);
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first, 
    );

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
    startRecording();
    startTimer();
  }
  
  int parseDuration(String duration) {
    RegExp regex = RegExp(r'(\d+)m (\d+)s');
    Match? match = regex.firstMatch(duration);
    if (match != null) {
      int minutes = int.parse(match.group(1)!);
      int seconds = int.parse(match.group(2)!);
      return (minutes * 60) + seconds;
    }
    return 0;
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });

        if (secondsRemaining == 3) {
          playCompletionSound();
        }
      } else {
        timer.cancel();
        stopRecording();
      }
    });
  }

  Future<void> startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/exercise_video.mp4';

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        isRecording = true;
        videoPath = path;
      });
    } catch (e) {
      print("خطأ في تسجيل الفيديو: $e");
    }
  }

  Future<void> stopRecording() async {
    if (_cameraController == null || !_cameraController!.value.isRecordingVideo) {
      return;
    }
    try {
      await _cameraController!.stopVideoRecording();
      setState(() {
        isRecording = false;
      });
    } catch (e) {
      print("خطأ في إيقاف التسجيل: $e");
    }
  }

  void playCompletionSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource("audio/female-vocal-321-countdown-240912.mp3"));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.exerciseName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${(secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(secondsRemaining % 60).toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: _cameraController != null && _cameraController!.value.isInitialized
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  )
                : Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
          ),

          SizedBox(height: 20),

          // زر إنهاء التمرين
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                stopRecording();
                Navigator.pop(context);
              },
              icon: Icon(Icons.stop_circle, size: 32),
              label: Text("إنهاء التمرين", style: TextStyle(fontSize: 24)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                shadowColor: Colors.red.withOpacity(0.3),
                elevation: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
