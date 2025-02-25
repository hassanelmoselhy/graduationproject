import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' ;
import 'package:permission_handler/permission_handler.dart';

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
Future<void> requestPermissions() async {
  await Permission.storage.request();
  await Permission.manageExternalStorage.request();
  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.storage.request();
}
  @override
  void initState() {
    super.initState();
    secondsRemaining = parseDuration(widget.duration);
    requestPermissions();
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

  // 🔹 طلب الأذونات قبل بدء التسجيل
  await requestPermissions();

  // 🔹 الحصول على مسار التخزين
  final directory = Directory('/storage/emulated/0/DCIM/MyAppVideos');

  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  // 🔹 تحديد اسم الملف
  final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

  // 🔹 بدء التسجيل
  await _cameraController!.startVideoRecording();
  
  setState(() {
    isRecording = true;
    videoPath = filePath;
  });

  print("📁 سيتم حفظ الفيديو في: $filePath");
}

Future<void> stopRecording() async {
  if (_cameraController == null || !_cameraController!.value.isRecordingVideo) return;

  // 🔹 إيقاف التسجيل
  final videoFile = await _cameraController!.stopVideoRecording();

  // 🔹 نقل الفيديو إلى المسار الصحيح
  final savedVideo = File(videoFile.path);
  final newVideoPath = File(videoPath!);
  savedVideo.renameSync(newVideoPath.path);

  setState(() {
    isRecording = false;
    videoPath = newVideoPath.path;
  });

  print("✅ تم حفظ الفيديو في: $videoPath");

  // 🔹 حفظ الفيديو في المعرض باستخدام `gallery_saver_plus`
  
}
 Future<void> updateAchievements() async {
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail'); // استرجاع البريد الإلكتروني

  if (email != null) {
    int completedExercises = prefs.getInt('${email}_completedExercises') ?? 0;
    double score = prefs.getDouble('${email}_score') ?? 0;

    completedExercises++;
    score += 20;

    await prefs.setInt('${email}_completedExercises', completedExercises);
    await prefs.setDouble('${email}_score', score);
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
            Text(widget.exerciseName, style: TextStyle(color: Colors.white, fontSize: 18)),
            Text("$secondsRemaining ثانية", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                  : Center(child: CircularProgressIndicator()),
            ),
          ),
          SizedBox(height: 16),
          IconButton(
            onPressed: () async {
              await stopRecording();
              await updateAchievements();
              Navigator.pop(context);
            },
            icon: Icon(Icons.stop_circle, color: Colors.red, size: 80),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
