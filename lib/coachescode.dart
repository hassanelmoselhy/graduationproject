import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CoachBookingPage extends StatefulWidget {
  @override
  _CoachBookingPageState createState() => _CoachBookingPageState();
}

class _CoachBookingPageState extends State<CoachBookingPage> {
  final TextEditingController coachCodeController = TextEditingController();
  final TextEditingController coachNameController = TextEditingController();
  List<Map<String, dynamic>> bookings = [];

  // متغير للتحقق من المدرب
  bool isValidCoach = false;
  String errorMessage = '';

  // جلب الحجوزات بناءً على الكود والاسم
  Future<void> _fetchBookings() async {
    final coachCode = coachCodeController.text.trim();
    final coachName = coachNameController.text.trim();

    if (coachCode.isEmpty || coachName.isEmpty) {
      setState(() {
        errorMessage = 'يرجى إدخال كود المدرب واسم المدرب.';
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('coachCode', isEqualTo: int.parse(coachCode))
          .where('coachName', isEqualTo: coachName)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'لا توجد حجوزات لهذا المدرب.';
          isValidCoach = false;
          bookings = [];
        });
      } else {
        setState(() {
          errorMessage = '';
          isValidCoach = true;
          bookings = snapshot.docs.map((doc) {
            return {
              'patientName': doc['patientName'],
              'date': doc['date'],
              'time': doc['time'],
              'paymentMethod': doc['paymentMethod'],
            };
          }).toList();
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ أثناء جلب البيانات: $e';
        isValidCoach = false;
        bookings = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('show_books'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: coachCodeController,
              decoration: InputDecoration(
                labelText: ' code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[800]!),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: coachNameController,
              decoration: InputDecoration(
                labelText: 'coache_name ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[800]!),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(' Show_Books', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),

            // إذا كانت هناك أخطاء
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 20),

            // عرض الحجوزات إذا كانت صحيحة
            if (isValidCoach && bookings.isNotEmpty) ...[
              Text(
                'books:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(' user name: ${booking['patientName']}'),
                      subtitle: Text(
                          'date: ${booking['date']}\ntime: ${booking['time']}\n payed_by: ${booking['paymentMethod']}'),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class DoctorPage extends StatefulWidget {
  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  List<Map<String, dynamic>> bookings = [];
  bool isCodeVerified = false;
  String errorMessage = '';

  Future<void> _fetchBookings() async {
    final doctorName = nameController.text.trim();
    final doctorCode = int.tryParse(codeController.text.trim());

    if (doctorName.isEmpty || doctorCode == null) {
      setState(() {
        errorMessage = 'يرجى إدخال اسم الطبيب وكود رقمي صحيح.';
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('doctorName', isEqualTo: doctorName)
          .where('doctorCode', isEqualTo: doctorCode)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'لا توجد حجوزات لهذا الطبيب.';
          bookings = [];
        });
      } else {
        setState(() {
          errorMessage = '';
          bookings = snapshot.docs.map((doc) {
            return {
              'patientName': doc['patientName'],
              'date': doc['date'],
              'time': doc['time'],
              'paymentMethod': doc['paymentMethod'],
            };
          }).toList();
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
        bookings = [];
      });
    }
  }

  void _verifyDoctor() async {
    final doctorName = nameController.text.trim();
    final doctorCode = int.tryParse(codeController.text.trim());

    if (doctorName.isEmpty || doctorCode == null) {
      setState(() {
        errorMessage = 'يرجى إدخال اسم الطبيب وكود رقمي صحيح.';
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('doctorName', isEqualTo: doctorName)
          .where('doctorCode', isEqualTo: doctorCode)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          isCodeVerified = true;
          errorMessage = '';
        });
        _fetchBookings();
      } else {
        setState(() {
          isCodeVerified = false;
          errorMessage = 'كود الطبيب غير صحيح أو الاسم غير متطابق!';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ أثناء التحقق: $e';
        isCodeVerified = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' show_books'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: ' doctor name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: ' code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyDoctor,
              child: Text(' show-books '),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 20),
            if (isCodeVerified && bookings.isNotEmpty) ...[
              Text(
                'Books:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(' user name: ${booking['patientName']}'),
                      subtitle: Text(
                        'date: ${booking['date']}\ntime: ${booking['time']}\npayed_by: ${booking['paymentMethod']}',
                      ),
                    ),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}


