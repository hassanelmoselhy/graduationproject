import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
  final String serverUrl = "https://6e96-196-137-162-44.ngrok-free.app/process-frame"; // 🔹 عنوان الخادم لاستقبال الإطارات
  final String exerciseNameApiUrl = "https://6e96-196-137-162-44.ngrok-free.app/txt_input"; // 🆕 عدل هذا الرابط حسب API الخاص بك
  bool hasStarted = false;
  bool scoreFetched = false;
  int stopPressCount = 0;

   final List<Map<String, dynamic>> exercises = [
    {'name': 'Push-up', 'time': '1m 2s', },
    {'name': 'pull-up', 'time': '1m 30s', },
    {'name': 'Squats', 'time': '3m 10s', },
    {'name': 'jumping-jacks', 'time': '2m 15s',},
    {'name': 'sit-up', 'time': '4m 2s',},
    {'name': 'Straight leg raise', 'time': '2m 26s'},
    {'name': 'Bridging', 'time': '1m 30s'},
   
  ];





  @override
void initState() {
  super.initState();
  secondsRemaining = parseDuration(widget.duration);
  requestPermissions();
  initCamera();
  sendExerciseName(); // ممكن تفضل تبعتها هنا عادي
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

Future<void> sendExerciseName() async {
  try {
    Dio dio = Dio();
    Response response = await dio.post(
      exerciseNameApiUrl,
      data: {
        "exercise_name": widget.exerciseName,
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );

    debugPrint("📤 تم إرسال اسم التمرين إلى الخادم");

    // ✅ عرض رسالة نجاح
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم إرسال اسم التمرين بنجاح"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }

  } catch (e) {
    debugPrint("❌ خطأ أثناء إرسال اسم التمرين: $e");

    // ❗ عرض رسالة فشل
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ فشل في إرسال اسم التمرين"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

Future<void> fetchLiveScore() async {
  try {
    Dio dio = Dio();
    Response response = await dio.get(
      "https://6e96-196-137-162-44.ngrok-free.app/Live_score",
    );

    if (response.statusCode == 200 && response.data != null) {
      final score = response.data.toString();
      debugPrint("🎯 تم الحصول على السكور: $score");

      // 🆕 أضف السكور إلى Firebase
      await saveScoreToFirebase(widget.exerciseName, score);

      // ✅ عرض النتيجة
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("نتيجتك"),
            content: Text("🎯 Score: $score"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("حسناً"),
              ),
            ],
          ),
        );

        // ✅ ارجع بعد الإغلاق
        if (mounted) Navigator.pop(context);
      }
    } else {
      debugPrint("⚠️ لم يتم الحصول على score: ${response.data}");
    }
  } catch (e) {
    debugPrint("❌ خطأ في الحصول على score: $e");
  }
}

Future<void> saveScoreToFirebase(String exerciseName, String score) async {
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');

  if (email == null) {
    debugPrint("❌ لا يوجد مستخدم مسجل");
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('achievements')
        .add({
          'exercise': exerciseName,
          'score': score,
          'type': 'fitness', // يمكنك تغييرها إلى 'therapy' حسب النوع
          'timestamp': FieldValue.serverTimestamp(),
        });

    debugPrint("✅ تم حفظ السكور في Firebase داخل حساب المستخدم");
  } catch (e) {
    debugPrint("❌ خطأ في حفظ السكور: $e");
  }
}


Future<void> sendFrame() async {
  if (!isRecording || _cameraController == null) return;

  try {
    XFile image = await _cameraController!.takePicture();
    File file = File(image.path);
    List<int> imageBytes = await file.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    Dio dio = Dio();
    Response response = await dio.post(
      serverUrl,
      data: {
        "image": base64Image,
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );

    debugPrint("📤 تم إرسال الصورة بصيغة base64");
    debugPrint("📥 رد الخادم: ${response.data}");

    // ✅ الرد نص مباشر مش JSON
    String result = response.data.toString().toLowerCase();

    if (result.contains("incorrect work out")) {
      debugPrint("❗ الأداء غير صحيح - سيتم تشغيل صوت التنبيه");
      await player.play(AssetSource("wrong-47985.mp3")); // تأكد من المسار
    }

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

  final matchedExercise = exercises.firstWhere(
    (exercise) => exercise['name'].toString().toLowerCase() == widget.exerciseName.toLowerCase(),
    orElse: () => {},
  );

  if (matchedExercise.isNotEmpty && email != null) {
    int completedExercises = prefs.getInt('${email}_completedExercises') ?? 0;
    double score = prefs.getDouble('${email}_score') ?? 0;
    int totalExercises = prefs.getInt('${email}_totalExercises') ?? 5;

    completedExercises++;
    score += 20;

    await prefs.setInt('${email}_completedExercises', completedExercises);
    await prefs.setDouble('${email}_score', score);
    await prefs.setInt('${email}_totalExercises', totalExercises);

    debugPrint("✅ تم تحديث الإنجازات في SharedPreferences للمستخدم $email");
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
         Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    if (!hasStarted) // 👈 يظهر فقط قبل البدء
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        icon: const Icon(Icons.play_arrow),
        label: const Text("Start", style: TextStyle(fontSize: 18)),
        onPressed: () {
          setState(() {
            hasStarted = true;
          });
          startRecording();
          startTimer();
        },
      ),
    if (hasStarted) // 👈 يظهر فقط بعد البدء
    IconButton(
  onPressed: () async {
    stopPressCount++;

    if (stopPressCount % 2 == 1) {
      // ⏹️ إيقاف: timer و camera
      _timer?.cancel();
      await stopRecording(); // ✅ هيوقف isRecording = false
      debugPrint("📴 تم إيقاف إرسال الإطارات والمؤقت.");
    } else {
      // ▶️ استئناف: timer و camera
      startTimer();
      await startRecording(); // ✅ هيبدأ إرسال الإطارات من جديد
      debugPrint("▶️ تم استئناف المؤقت وإرسال الإطارات.");
    }

    // ✅ فقط في أول ضغطة
    if (stopPressCount == 1) {
      await updateAchievements();
      await fetchLiveScore();
    }
  },
  icon: Icon(
    stopPressCount % 2 == 1 ? Icons.stop_circle : Icons.play_circle,
    color: stopPressCount % 2 == 1 ? Colors.red : Colors.green,
    size: 80,
  ),
),


  ],
),

          const SizedBox(height: 32),
          
        ],
      ),
    );
  }
}
