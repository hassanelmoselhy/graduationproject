import 'package:finalpro/video.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data'; // للتعامل مع البيانات الثنائية
//import 'package:web_socket_channel/web_socket_channel.dart'; // تعليق لاستيراد WebSocket
class CameraScreen extends StatefulWidget {
  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? cameraController;
  late List<CameraDescription> cameras;
  bool _isRecording = false;
//  WebSocketChannel? _webSocketChannel; // تعليق على WebSocketChannel

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    //_initializeWebSocket(); // تعليق على WebSocket initialization
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      _initializeCamera();
    } else {
      print('Camera permission denied');
    }
  }

//  void _initializeWebSocket() { // تعليق على WebSocket initialization
//    try {
//      _webSocketChannel = WebSocketChannel.connect(
//        Uri.parse('ws://your-server-address/ws'), // عنوان خادم WebSocket
//      );
//      print('WebSocket connected');
//    } catch (e) {
//      print('Error initializing WebSocket: $e');
//    }
//  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await cameraController?.initialize();
      setState(() {});

      cameraController?.startImageStream((CameraImage image) async {
        try {
          var processedImage = await processCameraImage(image);
          //sendFrameToServer(processedImage); // تعليق على إرسال الصورة عبر WebSocket
        } catch (e) {
          print('Error processing image: $e');
        }
      });
    } catch (e) {
      print("Error initializing camera: $e");
      setState(() {
        cameraController = null; // لضمان التعامل مع الخطأ
      });
    }
  }

  Future<Uint8List> processCameraImage(CameraImage image) async {
    return Uint8List.fromList(image.planes[0].bytes);
  }

//  void sendFrameToServer(Uint8List imageBytes) { // تعليق على إرسال الصورة عبر WebSocket
//    try {
//      _webSocketChannel?.sink.add(imageBytes);
//      print('Frame sent via WebSocket');
//    } catch (e) {
//      print('Error sending frame via WebSocket: $e');
//    }
//  }

  @override
  void dispose() {
    cameraController?.dispose();
    //_webSocketChannel?.sink.close(); // تعليق على WebSocketChannel disposal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الكاميرا")),
      body: cameraController != null && cameraController!.value.isInitialized
          ? CameraPreview(cameraController!)
          : Center(
              child: Text(
                "جارٍ تهيئة الكاميرا أو حدثت مشكلة.",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
      floatingActionButton: cameraController != null &&
              cameraController!.value.isInitialized
          ? FloatingActionButton(
              onPressed: () async {
                if (_isRecording) {
                  final videoPath = await cameraController!.stopVideoRecording();
                  setState(() => _isRecording = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(videoPath: videoPath.path),
                    ),
                  );
                } else {
                  await cameraController!.startVideoRecording();
                  setState(() => _isRecording = true);
                }
              },
              child: Icon(_isRecording ? Icons.stop : Icons.videocam),
            )
          : null,
    );
  }
} 

