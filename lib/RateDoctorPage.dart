import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateDoctorPage extends StatefulWidget {
  final String name;
  final double currentRating;
  final String imagePath;
  final String location;
  final int age;
  final int experience;
  final String qualification;
  final List<String> workplaces;
  final String specialty;
  final String bio;

  RateDoctorPage({
    required this.name,
    required this.currentRating,
    required this.imagePath,
    required this.location,
    required this.age,
    required this.experience,
    required this.qualification,
    required this.workplaces,
    required this.specialty,
    required this.bio,
  });

  @override
  _RateDoctorPageState createState() => _RateDoctorPageState();
}

class _RateDoctorPageState extends State<RateDoctorPage> {
  double newRating = 0;

  @override
  void initState() {
    super.initState();
    newRating = widget.currentRating;
  }

 Future<void> _submitRating() async {
  try {
    final docRef = FirebaseFirestore.instance.collection('doctor_ratings').doc(widget.name);
    final docSnapshot = await docRef.get();

    double sum = 0;
    int count = 0;

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      sum = (data['sum'] ?? 0).toDouble();
      count = (data['count'] ?? 0).toInt();
    }

    sum += newRating;
    count += 1;
    double average = sum / count;

    await docRef.set({
      'sum': sum,
      'count': count,
      'average': average,
    });

    Navigator.pop(context, average); // إرسال المتوسط لتحديث الواجهة الأم
  } catch (e) {
    print("❌ خطأ أثناء حفظ التقييم: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate ${widget.name}'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(widget.imagePath),
            ),
            SizedBox(height: 16),
            Text(
              widget.name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text("⭐ ${widget.currentRating.toStringAsFixed(1)}"),
            SizedBox(height: 8),
            Text("${widget.age} years old | ${widget.experience} years experience"),
            Text(widget.location),
            Divider(height: 32, thickness: 1),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🎓 Qualification:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.qualification),
                  SizedBox(height: 12),
                  Text("🏥 Workplaces:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...widget.workplaces.map((w) => Text("• $w")),
                  SizedBox(height: 12),
                  Text("🧠 Specialty:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.specialty),
                  SizedBox(height: 12),
                  Text("📝 About:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.bio),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text("Give your rating:"),
            RatingBar.builder(
              initialRating: newRating,
              minRating: 1,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  newRating = rating;
                });
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitRating,
              child: Text("Submit"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
