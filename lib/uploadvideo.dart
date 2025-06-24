import 'package:finalpro/coachordoctor.dart';
import 'package:finalpro/showtraining1.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert'; 
import 'dart:typed_data'; 
 
class UploadPage extends StatefulWidget {  
      final String exerciseName;

  const UploadPage({Key? key, required this.exerciseName}) : super(key: key);

  @override
  UploadPageState createState() => UploadPageState();
}

class UploadPageState extends State<UploadPage> {
  String? fileName;
  File? selectedFile;
  bool isUploading = false;
    // final String typeServerUrl = "https://a95b-156-176-130-202.ngrok-free.app/txt_input_model_type"; 
  final String serverUrl =  "https://6e96-196-137-162-44.ngrok-free.app/analyze_video" ;
  final String exerciseServerUrl = "https://6e96-196-137-162-44.ngrok-free.app/txt_input"; 
  String serverResponse = ''; 
  int uploadCount = 0;  
   bool _isExerciseInFitnessPlan(String name) {
  List<String> fitnessExercises = ['Squats', 'pull-up', 'Push-up', 'jumping-jacks ' , 'sit-up']; 
  
  return fitnessExercises.contains(name);  
  
  
  
}
 
Future<void> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

  if (result != null) {
    setState(() {
      fileName = result.files.single.name;
      selectedFile = File(result.files.single.path!);
    });

    // await sendExerciseType();    
    uploadFile();   
    uploadExerciseName();    
  }
}

     void _navigateToAchievementsPage(double score, String exerciseName) {
    final targetPage = _isExerciseInFitnessPlan(exerciseName)
        ? AchievementsPage3()
        : AchievementsPage5();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => targetPage,
        settings: RouteSettings(arguments: {'score': score, 'exerciseName': exerciseName}),
      ),
    );
  }
Future<void> uploadFile() async {
  if (selectedFile == null) return;

  setState(() {
    isUploading = true;
  });

  try {
    Dio dio = Dio();
    FormData formData = FormData.fromMap({
      "video": await MultipartFile.fromFile(selectedFile!.path, filename: fileName),
    });

    Response response = await dio.post(
      serverUrl,
      data: formData,
      options: Options(
        headers: {
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    if (response.statusCode == 200) {
  final List<dynamic> apiResponse = response.data;
final dynamic apiMessage = apiResponse[0];
final List<dynamic> list = apiResponse[1];
final double apiScore = (apiResponse[2] as num).toDouble();
final String? base64Image = apiResponse[3];
// إذا كانت base64Image ليست فارغة، فك تشفيرها
Uint8List? imageBytes;
if (base64Image != null && base64Image.isNotEmpty) {
  imageBytes = base64Decode(base64Image);
}
      setState(() {
          uploadCount++;  // زيادة عدد الرفع كل مرة
        });

        // إذا كانت هذه هي المرة الخامسة للرفع، اعرض التنبيه
        if (uploadCount == 5) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("هل تريد تقييم مدربك أو دكتورك؟"),
              content: Text("يرجى اختيار ما إذا كنت تريد تقييم المدرب أو الطبيب."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToPage('coach');  // إذا كان المدرب
                  },
                  child: Text("مدرب"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToPage('doctor');  // إذا كان الطبيب
                  },
                  child: Text("دكتور"),
                ),
              ],
            ),
          );
        } 
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("  success"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("result: $apiMessage \nerrors $list \nscore: $apiScore"),
                 SizedBox(height: 10),
            // عرض الصورة إذا كانت موجودة
            if (imageBytes != null) Image.memory(imageBytes),
               
                
              ],
            ),
          ),
          actions: [
            TextButton(
             onPressed: () async {
  Navigator.pop(context);
  if (response.statusCode == 200 && response.data is List) {
    final rawScore = response.data[2];
    final apiScore = (rawScore is int) ? rawScore.toDouble() : rawScore as double;
    final currentExercise = widget.exerciseName;
    _navigateToAchievementsPage(apiScore, currentExercise);
  }
},

              child: Text("ok"),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("خطأ"),
        content: Text("حدث خطأ أثناء تحميل الفيديو: $e"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("حسناً"),
          ),
        ],
      ),
    );
  } finally {
    setState(() {
      isUploading = false;
    });
  }
}
void _navigateToPage(String type) {
    if (type == 'coach') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CoachesPage(title: 'coaches',)), // اذهب إلى صفحة المدرب
      );
    } else if (type == 'doctor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => doctorPage(title: 'doctors',)), // اذهب إلى صفحة الدكتور
      );
    }
  }

Future<void> uploadExerciseName() async {
  if (widget.exerciseName.isEmpty) return;

  setState(() {
    isUploading = true;
  });

  try {
    Dio dio = Dio();
    Response response = await dio.post(
      exerciseServerUrl,
      data: {"exercise_name": widget.exerciseName},
      options: Options(
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );

    print("Response: ${response.data}");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("success"),
        content: Text("the video is success upload ${response.data}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ok"),
          ),
        ],
      ),
    );
  } catch (e) {
    if (e is DioException) {
      print("Error: ${e.response?.data}");
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("error"),
        content: Text("error when upload $e"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ok"),
          ),
        ],
      ),
    );
  } finally {
    setState(() {
      isUploading = false;
    });
  }
}


 @override
Widget build(BuildContext context) {
  return Scaffold( 
    appBar: AppBar(
      title: Text(widget.exerciseName),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
    backgroundColor: Colors.tealAccent.shade100,
    body: SingleChildScrollView( 
      child: Center(
        child: Container(  
          margin: EdgeInsets.only(top: 80),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(4, 4),
              ),
            ],
          ),
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Upload your video\nyou want to convert to AVI",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: pickFile,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: Radius.circular(10),
                  dashPattern: [6, 3],
                  color: Colors.grey,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.video_library, size: 50, color: Colors.grey.shade700),
                        SizedBox(height: 10),
                        Text("Drag and drop video file\nor", textAlign: TextAlign.center),
                        SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: pickFile,
                          child: Text("Browse"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              if (fileName != null)
                Text(
                  "Selected: $fileName",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              SizedBox(height: 15),
              if (isUploading) CircularProgressIndicator(),
              Text(
                "You can convert to AVI from various formats including MKV, MP4, FLV, MPEG, MOV, and WMV.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              // عرض الرد من السيرفر بعد رفع الفيديو
         if (serverResponse.isNotEmpty)
  Container(
    margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.green.shade400),
      boxShadow: [
        BoxShadow(
          color: Colors.green.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            serverResponse,
            style: TextStyle(
              fontSize: 16,
              color: Colors.green.shade800,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    ),
  ),
            ],
          ),
        ),
      ),
    ),
  );
} 
}