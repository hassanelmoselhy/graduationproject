import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseTimerPage extends StatefulWidget {
  final String exerciseName;
  final String duration;

  const ExerciseTimerPage({Key? key, required this.exerciseName, required this.duration}) : super(key: key);

  @override
  State<ExerciseTimerPage> createState() => _ExerciseTimerPageState();
}

class _ExerciseTimerPageState extends State<ExerciseTimerPage> {
  int secondsRemaining = 0;
  Timer? _timer;
  final player = AudioPlayer();
  CameraController? _cameraController;
  bool isRecording = false;
  final String serverUrl = "https://your-server.com/upload_frame"; // 🔹 عنوان الخادم لاستقبال الإطارات

  @override
  void initState() {
    super.initState();
    secondsRemaining = parseDuration(widget.duration);
    requestPermissions();
    initCamera();
  }

  Future<void> requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();
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

    startRecording(); // 🔹 بدء التسجيل فورًا
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });

        if (secondsRemaining == 2) {
          playCompletionSound();
        }
      } else {
        timer.cancel();
        stopRecording();
      }
    });
  }

  Future<void> startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    isRecording = true;
    while (isRecording) {
      await sendFrame();
      await Future.delayed(const Duration(milliseconds: 300)); // 🔹 إرسال إطار كل 300 مللي ثانية
    }
  }

  Future<void> sendFrame() async {
    if (!isRecording || _cameraController == null) return;

    try {
      XFile image = await _cameraController!.takePicture();
      File file = File(image.path);

      FormData formData = FormData.fromMap({
        "frame": await MultipartFile.fromFile(file.path, filename: "frame_${DateTime.now().millisecondsSinceEpoch}.jpg"),
      });

      Dio dio = Dio();
      await dio.post(serverUrl, data: formData);
      debugPrint("📤 تم إرسال إطار إلى الخادم");
    } catch (e) {
      debugPrint("❌ خطأ أثناء إرسال الإطار: $e");
    }
  }

  Future<void> stopRecording() async {
    isRecording = false;
    debugPrint("⏹️ تم إيقاف إرسال الإطارات.");
  }
 Future<void> updateAchievements() async {
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');

  if (email != null) {
    int completedExercises = prefs.getInt('${email}_completedExercises') ?? 0;
    double score = prefs.getDouble('${email}_score') ?? 0;
    int totalExercises = prefs.getInt('${email}_totalExercises') ?? 5; // 🔹 تحميل عدد التمارين الديناميكي

    completedExercises++;
    score += 20;

    await prefs.setInt('${email}_completedExercises', completedExercises);
    await prefs.setDouble('${email}_score', score);
    await prefs.setInt('${email}_totalExercises', totalExercises); // 🔹 حفظ العدد الجديد للتمارين
  }
}
  void playCompletionSound() async {
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.exerciseName, style: const TextStyle(color: Colors.white, fontSize: 18)),
            Text("$secondsRemaining ثانية", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: _cameraController != null && _cameraController!.value.isInitialized
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 16),
          IconButton(
            onPressed: () async {
              await stopRecording();
                await updateAchievements();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.stop_circle, color: Colors.red, size: 80),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
