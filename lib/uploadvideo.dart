import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dio/dio.dart';
import 'dart:io';

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
  final String serverUrl = "https://033b-154-177-231-177.ngrok-free.app/analyze_video";  
  final String exerciseServerUrl = "https://033b-154-177-231-177.ngrok-free.app/txt_input"; 
  

  Future<void> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);
    
    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
        selectedFile = File(result.files.single.path!);
      });

      // بعد اختيار الملف، أرسل الفيديو إلى السيرفر
      uploadFile();
        uploadExerciseName(); 
    }
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

    print("Response: ${response.data}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Upload successful! ${response.data}")),
    );
  } catch (e) {
    if (e is DioException) {
      print("Error: ${e.response?.data}");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() {
      isUploading = false;
    });
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
      data: {"exercise_name": widget.exerciseName}, // 🔹 إرسال البيانات كـ JSON
      options: Options(
        headers: {
          "Content-Type": "application/json", // 🔹 تحديد نوع البيانات JSON
        },
      ),
    );

    print("Response: ${response.data}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Exercise name uploaded successfully! ${response.data}")),
    );
  } catch (e) {
    if (e is DioException) {
      print("Error: ${e.response?.data}");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
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
       appBar: AppBar( // 🟢 إضافة AppBar
        title: Text(widget.exerciseName), // 🟢 عرض اسم التمرين
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // الرجوع للخلف
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
              ],
            ),
          ),
        ),
      ),
    );
  }
} 