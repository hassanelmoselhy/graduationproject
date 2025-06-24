import 'package:finalpro/RateCoachPage.dart';
import 'package:finalpro/RateDoctorPage.dart';
import 'package:finalpro/chooseuploadorlive.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';


class CoachesPage extends StatefulWidget {
  final String title;


  CoachesPage({required this.title});

  @override
  _CoachesPageState createState() => _CoachesPageState();
}

class _CoachesPageState extends State<CoachesPage> {
  String searchQuery = ""; // متغير لتخزين نص البحث
double rating = 0;


 final List<Map<String, dynamic>> allCoaches = [
  {
    'name': 'Coach Hassan',
    'location': 'Maadi',
    'age': 36,
    'experience': 14,
    'rating': 4.5,
    'image': 'assets/images/OIP.jpg',
    'phone': '+201550598053',
    'qualification': 'Certified Personal Trainer (ISSA)',
    'workplaces': ['Gold\'s Gym Maadi', 'FitZone Egypt'],
    'specialty': 'Strength & Conditioning',
    'bio': 'Coach Hassan helps clients achieve fitness goals through strength and conditioning. Over 14 years of hands-on experience with various training programs.',
  },
  {
    'name': 'Coach Hossam',
    'location': 'Nasr City',
    'age': 40,
    'experience': 18,
    'rating': 4.7,
    'image': 'assets/images/OIP.jpg',
    'phone': '+201550598053',
    'qualification': 'Bachelor in Physical Education',
    'workplaces': ['Body Masters Club', 'Fitness Pro Center'],
    'specialty': 'Bodybuilding & Muscle Gain',
    'bio': 'Coach Hossam is a specialist in bodybuilding programs and muscle hypertrophy. He has coached more than 500 athletes in his career.',
  },
  {
    'name': 'Coach Ahmed',
    'location': 'Zamalek',
    'age': 29,
    'experience': 8,
    'rating': 4.3,
    'image': 'assets/images/OIP.jpg',
    'phone': '+201550598053',
    'qualification': 'ACE Certified Personal Trainer',
    'workplaces': ['Zamalek Fit Club', 'PowerHouse Gym'],
    'specialty': 'HIIT & Fat Loss',
    'bio': 'Ahmed uses modern fat-loss techniques like HIIT and metabolic training to help clients transform quickly and safely.',
  },
  {
    'name': 'Coach Mona',
    'location': 'Heliopolis',
    'age': 35,
    'experience': 12,
    'rating': 4.6,
    'image': 'assets/images/OIP.jpg',
    'phone': '+201550598053',
    'qualification': 'Certified Group Fitness Instructor',
    'workplaces': ['Lady Gym', 'Wellness Studio'],
    'specialty': 'Group Training & Yoga',
    'bio': 'Coach Mona delivers engaging group sessions in yoga, flexibility, and full-body workouts for women of all ages.',
  },
  {
    'name': 'Coach Sara',
    'location': 'Dokki',
    'age': 32,
    'experience': 10,
    'rating': 4.4,
    'image': 'assets/images/OIP.jpg',
    'phone': '+201550598053',
    'qualification': 'Certified Pilates & Rehab Trainer',
    'workplaces': ['Balance Studio Dokki'],
    'specialty': 'Pilates & Injury Recovery',
    'bio': 'Sara is known for her gentle and effective approach in post-injury recovery, flexibility training, and core stabilization.',
  },
  {
    'name': 'Coach Khaled',
    'location': 'Giza',
    'age': 38,
    'experience': 16,
    'rating': 4.8,
    'image': 'assets/images/OIP.jpg',
    'phone': '+201550598053',
    'qualification': 'Master Trainer (NSCA)',
    'workplaces': ['Giza CrossFit Box'],
    'specialty': 'CrossFit & Functional Training',
    'bio': 'Khaled trains elite athletes and regular trainees in high-intensity CrossFit, building strength, endurance, and mobility.',
  },
];


  List<Map<String, dynamic>> filteredCoaches = [];
  

  @override
  void initState() {
    super.initState();
    filteredCoaches = allCoaches;
    _loadCoachRatings();
  } 
Future<void> _loadCoachRatings() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('coach_ratings').get();
    setState(() {
      for (var doc in snapshot.docs) {
        final coachName = doc.id;
        final rating = doc.data()['average'] ?? 0.0; // ✅ استخدم [] بدل ?[]

        for (var coach in allCoaches) {
          if (coach['name'] == coachName) {
            coach['rating'] = rating;
          }
        }
      }
    });
  } catch (e) {
    print("❌ خطأ في تحميل التقييمات من Firebase: $e");
  }
}



  // دالة لتحديث البحث
  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredCoaches = allCoaches
          .where((coach) => coach['name'].toLowerCase().contains(query.toLowerCase()) ||
                            coach['location'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // شريط البحث
            Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: updateSearch,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, color: Colors.green),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // شبكة المدربين بعد البحث
            Expanded(
              child: filteredCoaches.isEmpty
                  ? Center(child: Text('No results found'))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: filteredCoaches.length,
                      itemBuilder: (context, index) {
                        final person = filteredCoaches[index];
                     return CoachDoctorCard(
  name: person['name'],
  rating: person['rating'],
  location: person['location'],
  age: person['age'],
  experience: person['experience'],
  imagePath: person['image'],
  phoneNumber: person['phone'],
  qualification: person['qualification'],
  workplaces: List<String>.from(person['workplaces']),
  specialty: person['specialty'],
  bio: person['bio'],
  onRatingChanged: (newRating) {
    setState(() {
      person['rating'] = newRating;
    });
  },
);

                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


// بطاقة تمثل دكتور أو مدرب
class CoachDoctorCard extends StatelessWidget {
  final String name;
  final double rating;
  final String location;
  final int age;
  final int experience;
  final String imagePath;
  final String phoneNumber;
  final String qualification;
  final List<String> workplaces;
  final String specialty;
  final String bio;
  final Function(double) onRatingChanged;

  CoachDoctorCard({
    required this.name,
    required this.rating,
    required this.location,
    required this.age,
    required this.experience,
    required this.imagePath,
    required this.phoneNumber,
    required this.qualification,
    required this.workplaces,
    required this.specialty,
    required this.bio,
    required this.onRatingChanged,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
     onTap: () {
  showModalBottomSheet(
    context: context,
    builder: (context) => CoachDoctorDetails(
      name: name,
      rating: rating,
      location: location,
      age: age,
      experience: experience,
      phoneNumber: phoneNumber,
      imagePath: imagePath,
      qualification: qualification,
      workplaces: workplaces,
      specialty: specialty,
      bio: bio,
      onRatingChanged: onRatingChanged,
    ),
  );
},

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(imagePath), // عرض الصورة هنا
            ),
            SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text("⭐ ${rating.toStringAsFixed(1)}"),
            Text(location),
          ],
        ),
      ),
    );
  }
}
//..
class CoachDoctorDetails extends StatelessWidget {
  final String name;
  final double rating;
  final String location;
  final int age;
  final int experience;
  final String phoneNumber;
  final String imagePath;
  final String qualification;
  final List<String> workplaces;
  final String specialty;
  final String bio;
  final Function(double) onRatingChanged;

  CoachDoctorDetails({
    required this.name,
    required this.rating,
    required this.location,
    required this.age,
    required this.experience,
    required this.phoneNumber,
    required this.imagePath,
    required this.qualification,
    required this.workplaces,
    required this.specialty,
    required this.bio,
    required this.onRatingChanged,
  });


  // دالة للاتصال
  void _callPhone(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print("لا يمكن إجراء الاتصال");
    }
  }
Future<void> saveCoachRatingToFirestore(String coachName, double rating) async {
   print("📤 بدأ حفظ التقييم لـ $coachName");
  try {
    final docRef = FirebaseFirestore.instance.collection('coach_ratings').doc(coachName);
    final docSnapshot = await docRef.get();

    double sum = 0;
    int count = 0;

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      sum = (data['sum'] ?? 0).toDouble();
      count = (data['count'] ?? 0).toInt();
    }

    // تحديث القيم
    sum += rating;
    count += 1;
    double average = sum / count;

    // حفظ البيانات الجديدة
    await docRef.set({
      'sum': sum,
      'count': count,
      'average': average,
    });

    print("✅ تم حفظ التقييم الجديد. المتوسط الحالي: $average");
  } catch (e) {
    print("❌ خطأ في حفظ التقييم: $e");
  }
}


  // دالة لإرسال رسالة واتساب
  void _sendWhatsAppMessage(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      print("لا يمكن فتح واتساب");
    }
  } 
    // دالة للتقييم
 
    
  void _navigateToBooking(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BookingPage1( // تأكد من أن BookingPage موجودة
        coachName: name,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/OIP.jpg'), 
          ),
          SizedBox(height: 3),
          Text(
            name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text("⭐ ${rating.toStringAsFixed(1)}"),
          Text("$age years old | $experience years experience"),
          Text(location),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton( 
                padding: EdgeInsets.only(bottom: 28),
                icon: Icon(Icons.phone, color: Colors.green
               
                ),
                onPressed: () => _callPhone(phoneNumber), // إجراء اتصال
              ),
               IconButton( 
                  padding: EdgeInsets.only(bottom: 28),
             icon: Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
              onPressed: () => _sendWhatsAppMessage(phoneNumber),
              ), 
              IconButton(
  padding: EdgeInsets.only(bottom: 28),
  icon: Icon(Icons.calendar_month, color: Colors.green),
  onPressed: () => _navigateToBooking(context),
),
IconButton(
  padding: EdgeInsets.only(bottom: 28),
  icon: Icon(Icons.star, color: Colors.green),
  onPressed: () async {
    final updatedAverage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RateCoachPage(
          name: name,
          currentRating: rating,
          imagePath: imagePath,
          location: location,
          age: age,
          experience: experience,
          qualification: qualification,
          workplaces: workplaces,
          specialty: specialty,
          bio: bio,
        ),
      ),
    );
    if (updatedAverage != null) {
      onRatingChanged(updatedAverage);
    }
  },
),

              IconButton( 
                  padding: EdgeInsets.only(bottom: 28),
  icon: Icon( FontAwesomeIcons.dumbbell, color: Colors.green),
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Choose(), // Ensure 'Plan' is a defined widget
      ),
    );
  },
),
            ],
          )
        ],
      ),
    );
  }
}

class doctorPage  extends StatefulWidget {
  final String title;

  doctorPage ({required this.title});

  @override
  _DoctorPageState createState() => _DoctorPageState();
}
 
class _DoctorPageState extends State<doctorPage > {
  TextEditingController searchController = TextEditingController();
 final List<Map<String, dynamic>> data = [
  {
    'name': 'Dr Hassan',
    'location': 'Maadi',
    'age': 36,
    'experience': 14,
    'rating': 4.5,
    'image': 'assets/images/search_doc_2.png',
    'phone': '+201550598053',
    'qualification': 'PhD in Physiotherapy',
    'workplaces': ['Cairo Medical Center', 'Maadi Clinic'],
    'specialty': 'Neurological Rehabilitation',
    'bio': 'Dr. Hassan is a neurologic physiotherapy expert, helping patients with stroke, MS, and spinal cord injuries regain their mobility and independence.',
  },
  {
    'name': 'Dr Hossam',
    'location': 'Nasr City',
    'age': 40,
    'experience': 18,
    'rating': 4.7,
    'image': 'assets/images/search_doc_3.png',
    'phone': '+201551704101',
    'qualification': 'MSc in Orthopedic Physiotherapy',
    'workplaces': ['El Salam Hospital', 'Nasr PT Clinic'],
    'specialty': 'Orthopedic & Sports Injuries',
    'bio': 'With years of experience in treating joint and spine issues, Dr. Hossam offers advanced recovery programs for athletes and post-surgery patients.',
  },
  {
    'name': 'Dr Ahmed',
    'location': 'Zamalek',
    'age': 29,
    'experience': 8,
    'rating': 4.3,
    'image': 'assets/images/search_doc_4.png',
    'phone': '+201152452727',
    'qualification': 'Bachelor in Physiotherapy',
    'workplaces': ['Zamalek Care Center'],
    'specialty': 'Manual Therapy & Pain Management',
    'bio': 'Dr. Ahmed uses manual therapy, dry needling, and soft tissue techniques to relieve pain and improve mobility quickly.',
  },
  {
    'name': 'Dr Mona',
    'location': 'Heliopolis',
    'age': 35,
    'experience': 12,
    'rating': 4.6,
    'image': 'assets/images/search_doc_1.png',
    'phone': '+201550598053',
    'qualification': 'Certified Women’s Health Therapist',
    'workplaces': ['Heliopolis Wellness Center'],
    'specialty': 'Women’s Health & Postnatal Therapy',
    'bio': 'Focused on female patients, Dr. Mona helps with postpartum recovery, pelvic floor rehabilitation, and hormonal balance treatment.',
  },
  {
    'name': 'Dr Sara',
    'location': 'Dokki',
    'age': 32,
    'experience': 10,
    'rating': 4.4,
    'image': 'assets/images/Asma_Khan.png',
    'phone': '+201550598053',
    'qualification': 'MSc in Pediatric Physiotherapy',
    'workplaces': ['Children’s Rehab Center'],
    'specialty': 'Pediatric Therapy & Motor Skills',
    'bio': 'Sara works with children who have motor or neurological delays, using play-based therapy and parental guidance.',
  },
  {
    'name': 'Dr Khaled',
    'location': 'Giza',
    'age': 38,
    'experience': 16,
    'rating': 4.8,
    'image': 'assets/images/Johir_Raihan.png',
    'phone': '+201550598053',
    'qualification': 'Certified Sports Physiotherapist',
    'workplaces': ['Giza Sports Rehab'],
    'specialty': 'Sports Rehabilitation & Performance',
    'bio': 'Dr. Khaled rehabilitates sports injuries and helps professional athletes return to top form through tailored physical programs.',
  },
];


  List<Map<String, dynamic>> filteredData = [];

  @override
  void initState() {
    super.initState();
    loadRatings();
    filteredData = List.from(data); // تعيين القائمة الافتراضية عند بدء الصفحة
  }

//   void loadRatings() async {
//   final prefs = await SharedPreferences.getInstance();

//   for (var doctor in data) {
//     final savedRating = prefs.getDouble('${doctor['name']}_rating');
//     if (savedRating != null) {
//       doctor['rating'] = savedRating;
//     }
//   }

//   setState(() {
//     filteredData = List.from(data);
//   });
// }
Future<void> loadRatings() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('doctor_ratings').get();
    setState(() {
      for (var doc in snapshot.docs) {
        final doctorName = doc.id;
        final average = doc.data()['average'];
        for (var doctor in data) {
          if (doctor['name'] == doctorName) {
            doctor['rating'] = average;
          }
        }
      }
    });
  } catch (e) {
    print("❌ خطأ في تحميل التقييمات من Firebase: $e");
  }
}


  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredData = List.from(data);
      });
      return;
    }

    List<Map<String, dynamic>> tempList = [];
    for (var item in data) {
      if (item['name'].toLowerCase().contains(query.toLowerCase()) ||
          item['location'].toLowerCase().contains(query.toLowerCase())) {
        tempList.add(item);
      }
    }

    setState(() {
      filteredData = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // شريط البحث
            Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterSearchResults, // استدعاء البحث عند الكتابة
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, color: Colors.green),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // قائمة الأطباء
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // عدد الأعمدة
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: filteredData.length, // عدد العناصر بعد التصفية
                itemBuilder: (context, index) {
                  final person = filteredData[index]; // الحصول على بيانات الشخص
                  return CoachDoctorCard1(
  name: person['name'],
  rating: person['rating'],
  location: person['location'],
  age: person['age'],
  experience: person['experience'],
  imagePath: person['image'],
  phoneNumber: person['phone'],
  qualification: person['qualification'],
  workplaces: List<String>.from(person['workplaces']),
  specialty: person['specialty'],
  bio: person['bio'],
  onRatingChanged: (newRating) {
    setState(() {
      person['rating'] = newRating;
    });
  },
);

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CoachDoctorCard1 extends StatelessWidget {
  final String name;
  final double rating;
  final String location;
  final int age;
  final int experience;
  final String imagePath;
  final String phoneNumber;
   final Function(double) onRatingChanged; 
    final String qualification;
  final List<String> workplaces;
  final String specialty;
  final String bio;
   // مسار الصورة

  CoachDoctorCard1({
    required this.name,
    required this.rating,
    required this.location,
    required this.age,
    required this.experience,
    required this.imagePath,
    required this.phoneNumber,
      required this.onRatingChanged,
      required this.qualification,
    required this.workplaces,
    required this.specialty,
    required this.bio,


   

  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // عند الضغط على العنصر، عرض المزيد من التفاصيل
        showModalBottomSheet(
          context: context,
          builder: (context) => CoachDoctorDetails1(
            name: name,
            rating: rating,
            location: location,
            age: age,
            experience: experience,
            phoneNumber: phoneNumber,
             imagePath: imagePath, 
              onRatingChanged: onRatingChanged,
                qualification: qualification,
            workplaces: workplaces,
            specialty: specialty,
            bio: bio,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(imagePath), // عرض الصورة هنا
            ),
            SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text("⭐ ${rating.toStringAsFixed(1)}"),
            Text(location),
          ],
        ),
      ),
    );
  }
}
class CoachDoctorDetails1 extends StatelessWidget {
  final String name;
  final double rating;
  final String location;
  final int age;
  final int experience;
  final String phoneNumber;
  final String imagePath;
  final String qualification;
  final List<String> workplaces;
  final String specialty;
  final String bio;
  final Function(double) onRatingChanged;


  CoachDoctorDetails1({
    required this.name,
    required this.rating,
    required this.location,
    required this.age,
    required this.experience,
    required this.phoneNumber,
    required this.imagePath,
    required this.qualification,
    required this.workplaces,
    required this.specialty,
    required this.bio,
      required this.onRatingChanged,

  });

  // دالة للاتصال
  void _callPhone(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print("لا يمكن إجراء الاتصال");
    }
  }
  Future<void> saveDoctorRatingToFirestore(String doctorName, double newRating) async {
  try {
    final docRef = FirebaseFirestore.instance.collection('doctor_ratings').doc(doctorName);

    final snapshot = await docRef.get();

    double currentSum = 0;
    int currentCount = 0;

    if (snapshot.exists) {
      currentSum = snapshot.data()?['sum'] ?? 0.0;
      currentCount = snapshot.data()?['count'] ?? 0;
    }

    double newSum = currentSum + newRating;
    int newCount = currentCount + 1;
    double average = newSum / newCount;

    await docRef.set({
      'sum': newSum,
      'count': newCount,
      'average': average,
    });

    print("✅ تم حفظ التقييم في Firestore");
  } catch (e) {
    print("❌ خطأ أثناء حفظ التقييم: $e");
  }
}


  // دالة لإرسال رسالة واتساب
  void _sendWhatsAppMessage(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      print("لا يمكن فتح واتساب");
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(imagePath),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text("⭐ ${rating.toStringAsFixed(1)}"),
          Text("$age years old | $experience years experience"),
          Text(location),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                padding: EdgeInsets.only(bottom: 28),
                icon: Icon(Icons.phone, color: Colors.green),
                onPressed: () => _callPhone(phoneNumber),
              ),
              IconButton(
                padding: EdgeInsets.only(bottom: 28),
                icon: Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
                onPressed: () => _sendWhatsAppMessage(phoneNumber),
              ),
              IconButton(
                padding: EdgeInsets.only(bottom: 28),
                icon: Icon(Icons.calendar_month, color: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingPage(doctorName: name),
                    ),
                  );
                },
              ),
      IconButton(
  padding: EdgeInsets.only(bottom: 28),
  icon: Icon(Icons.star, color: Colors.green),
  onPressed: () async {
    final newAverage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RateDoctorPage(
          name: name,
          currentRating: rating,
          imagePath: imagePath,
          location: location,
          age: age,
          experience: experience,
          qualification: qualification,
          workplaces: workplaces,
          specialty: specialty,
          bio: bio,
        ),
      ),
    );
    if (newAverage != null) {
      onRatingChanged(newAverage);
    }
  },
),


                 IconButton( 
                  padding: EdgeInsets.only(bottom: 28),
  icon:  Icon(Icons.local_hospital, color: Colors.green),
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Choose1(), // Ensure 'Plan' is a defined widget
      ),
    );
  },
),
            ],
          ),
        ],
      ),
    );
  }
}

class BookingPage extends StatefulWidget {
  final String doctorName;

  BookingPage({required this.doctorName});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final TextEditingController nameController = TextEditingController();
  DateTime? selectedDate;
  String? selectedTime;
  String? selectedPayment;

  final List<String> times = [
    '10:00 صباحًا',
    '12:00 ظهرًا',
    '2:00 مساءً',
    '4:00 مساءً',
    '6:00 مساءً',
  ];

  List<String> availableTimes = [];

  final List<String> paymentMethods = [
    'دفع نقدي',
    'بطاقة ائتمان',
    'باي بال',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
       lastDate: DateTime(2101),
      locale: Locale('en'),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedTime = null;
      });
      await loadAvailableTimes(picked);
    }
  }

  Future<void> loadAvailableTimes(DateTime date) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('bookings')
      .where('doctorName', isEqualTo: widget.doctorName)
      .where('date', isEqualTo: date.toIso8601String().split('T')[0])
      .get();

  List<String> bookedTimes = snapshot.docs.map((doc) => doc['time'] as String).toList();

  DateTime now = DateTime.now();

  List<String> filteredTimes = times.where((time) {
    final timeParts = time.split(' ');
    final timeString = timeParts[0]; // "10:00"
    final amPm = timeParts[1]; // "صباحًا" أو "مساءً"

    int hour = int.parse(timeString.split(':')[0]);
    int minute = int.parse(timeString.split(':')[1]);

    if (amPm.contains('مساء') && hour != 12) hour += 12;
    if (amPm.contains('صباح') && hour == 12) hour = 0;

    DateTime fullTime = DateTime(date.year, date.month, date.day, hour, minute);

    // ✅ فلترة إذا التاريخ اليوم
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return fullTime.isAfter(now.add(const Duration(minutes: 30))) && !bookedTimes.contains(time);
    }

    // ✅ باقي الأيام بعد النهارده
    return fullTime.isAfter(now) && !bookedTimes.contains(time);
  }).toList();

  setState(() {
    availableTimes = filteredTimes;
  });

  if (filteredTimes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("لا توجد أوقات متاحة في هذا اليوم")),
    );
  }
}

  List<Map<String, dynamic>> data = [
    {"code" : 1   ,'name': 'Dr Hassan', 'location': 'Maadi', 'age': 36, 'experience': 14, 'rating': 4.5 , 'image': 'assets/images/search_doc_2.png' , 'phone': '+201550598053'},
    {"code" : 2   ,'name': 'Dr Hossam', 'location': 'Nasr City', 'age': 40, 'experience': 18, 'rating': 4.7 , 'image': 'assets/images/search_doc_3.png' , 'phone': '+201551704101'},
    {"code" : 3   ,'name': 'Dr Ahmed', 'location': 'Zamalek', 'age': 29, 'experience': 8, 'rating': 4.3 , 'image': 'assets/images/search_doc_4.png','phone': '+201152452727'},
    {"code" : 4   ,'name': 'Dr Mona', 'location': 'Heliopolis', 'age': 35, 'experience': 12, 'rating': 4.6 , 'image': 'assets/images/search_doc_1.png', 'phone': '+201550598053'},
    {"code" : 5   ,'name': 'Dr Sara', 'location': 'Dokki', 'age': 32, 'experience': 10, 'rating': 4.4 , 'image': 'assets/images/Asma_Khan.png', 'phone': '+201550598053'},
    {"code" : 6   ,'name': 'Dr Khaled', 'location': 'Giza', 'age': 38, 'experience': 16, 'rating': 4.8 , 'image': 'assets/images/Johir_Raihan.png', 'phone': '+201550598053' },
  ];

  void _confirmBooking() async {
    if (nameController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null ||
        selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
    } else {
      try {
        final selectedCoachData = data.firstWhere(
        (coach) => coach['name'] == widget.doctorName,
        orElse: () => {}, // تأكد من وجود الكوتش
      );

      final doctorCode = selectedCoachData['code'];
      
        await FirebaseFirestore.instance.collection('bookings').add({
          'doctorName': widget.doctorName,
            'doctorCode': doctorCode,
          'patientName': nameController.text,
          'date': selectedDate!.toIso8601String().split('T')[0], // حفظ التاريخ فقط
          'time': selectedTime,
          'paymentMethod': selectedPayment,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم الحجز بنجاح مع الدكتور ${widget.doctorName}')),
        );

        setState(() {
          nameController.clear();
          selectedDate = null;
          selectedTime = null;
          selectedPayment = null;
          availableTimes = [];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الحجز: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: Text('حجز مع الدكتور ${widget.doctorName}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/OIP.jpg'),
                  radius: 30,
                ),
                title: Text(widget.doctorName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text('دكتور متخصص', style: TextStyle(fontSize: 14)),
              ),
            ),
            SizedBox(height: 20),

            // اسم المريض
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: ' user name',
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

            // اختيار التاريخ
            Text("اختر التاريخ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 , )),
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text(selectedDate == null
                  ? "اختر التاريخ"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ), 
              
            ),
            SizedBox(height: 20),

            // اختيار الوقت
            Text("اختر الوقت", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            DropdownButton<String>(
              isExpanded: true,
              hint: Text("اختر الوقت"),
               style: TextStyle(color: Colors.black
               
               ,fontSize: 16),
              value: selectedTime,
              items: availableTimes.map((time) {
                return DropdownMenuItem(value: time, child: Text(time));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTime = value;
                });
              },
              // style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // اختيار وسيلة الدفع
            Text("اختر طريقة الدفع", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            DropdownButton<String>(
              isExpanded: true,
              hint: Text("اختر طريقة الدفع"),
              value: selectedPayment,
              items: paymentMethods.map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPayment = value;
                });
              },
              style: TextStyle(fontSize: 16 , 
              color: Colors.black),
            ),
            SizedBox(height: 30),

         SizedBox(
  width: double.infinity, // يجعل الزر بعرض المكان الموجود فيه
  child: ElevatedButton(
    onPressed: _confirmBooking,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green[800],
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
    child: const Text(
      'تأكيد الحجز',
      style: TextStyle(fontSize: 18 , 
      color: Colors.black ),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}


class BookingPage1 extends StatefulWidget {
  final String coachName;

  BookingPage1({required this.coachName});

  @override
  _BookingPage1State createState() => _BookingPage1State();
}

class _BookingPage1State extends State<BookingPage1> { 
    final TextEditingController nameController = TextEditingController();

  DateTime? selectedDate;
  String? selectedTime;
  String? selectedPayment;

  final List<String> times = [
    '10:00 AM',
    '12:00 PM',
    '02:00 PM',
    '04:00 PM',
    '06:00 PM',
  ];
    List<String> availableTimes = [];


  final List<String> paymentMethods = [
    'كاش',
    'فودافون كاش',
    'بطاقة بنكية',
  ];

Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: Locale('en'),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedTime = null;
      });
      await loadAvailableTimes(picked);
    }
  }

  Future<void> loadAvailableTimes(DateTime date) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('bookings')
      .where('coachName', isEqualTo: widget.coachName)
      .where('date', isEqualTo: date.toIso8601String().split('T')[0])
      .get();

  List<String> bookedTimes =
      snapshot.docs.map((doc) => doc['time'] as String).toList();

  DateTime now = DateTime.now();

  List<String> filteredTimes = times.where((time) {
    final parts = time.split(' ');
    final timePart = parts[0]; // "10:00"
    final amPm = parts[1];     // "AM" or "PM"

    int hour = int.parse(timePart.split(':')[0]);
    int minute = int.parse(timePart.split(':')[1]);

    if (amPm == 'PM' && hour != 12) hour += 12;
    if (amPm == 'AM' && hour == 12) hour = 0;

    DateTime fullTime = DateTime(date.year, date.month, date.day, hour, minute);

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return fullTime.isAfter(now.add(Duration(minutes: 30))) &&
          !bookedTimes.contains(time);
    }

    return !bookedTimes.contains(time);
  }).toList();

  setState(() {
    availableTimes = filteredTimes;
  });

  if (filteredTimes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("لا توجد مواعيد متاحة في هذا اليوم")),
    );
  }
}

    final List<Map<String, dynamic>> allCoaches = [
    { 'code': 1, 'name': 'Coach Hassan', 'location': 'Maadi', 'age': 36, 'experience': 14, 'rating': 4.5, 'image': 'assets/images/OIP.jpg', 'phone': '+201550598053'},
    {'code': 2,'name': 'Coach Hossam', 'location': 'Nasr City', 'age': 40, 'experience': 18, 'rating': 4.7, 'image': 'assets/images/OIP.jpg', 'phone': '+201550598053'},
    {'code': 3,'name': 'Coach Ahmed', 'location': 'Zamalek', 'age': 29, 'experience': 8, 'rating': 4.3, 'image': 'assets/images/OIP.jpg', 'phone': '+201550598053'},
    {'code': 4,'name': 'Coach Mona', 'location': 'Heliopolis', 'age': 35, 'experience': 12, 'rating': 4.6, 'image': 'assets/images/OIP.jpg', 'phone': '+201550598053'},
    {'code': 5,'name': 'Coach Sara', 'location': 'Dokki', 'age': 32, 'experience': 10, 'rating': 4.4, 'image': 'assets/images/OIP.jpg', 'phone': '+201550598053'},
    {'code': 6,'name': 'Coach Khaled', 'location': 'Giza', 'age': 38, 'experience': 16, 'rating': 4.8, 'image': 'assets/images/OIP.jpg', 'phone': '+201550598053'},
  ];

void _confirmBooking() async {
  if (selectedDate == null || selectedTime == null || selectedPayment == null || nameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('يرجى إكمال جميع الحقول')),
    );
  } else {
    try {
      // ابحث عن الكوتش باستخدام الاسم لجلب الكود الخاص به
      final selectedCoachData = allCoaches.firstWhere(
        (coach) => coach['name'] == widget.coachName,
        orElse: () => {}, // تأكد من وجود الكوتش
      );

      final coachCode = selectedCoachData['code'];

      // إرسال البيانات إلى Firestore
      await FirebaseFirestore.instance.collection('bookings').add({
        'coachCode': coachCode, // أضف كود الكوتش هنا
        'coachName': widget.coachName,
        'patientName': nameController.text,
        'date': selectedDate!.toIso8601String().split('T')[0],
        'time': selectedTime,
        'paymentMethod': selectedPayment,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // تأكيد الحجز بعد إرسال البيانات
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم الحجز مع ${widget.coachName} بنجاح!')),
      );
    } catch (e) {
      // في حال حدوث خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحجز: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حجز مع ${widget.coachName}'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/OIP.jpg'), // صورة المدرب
                ),
                title: Text(widget.coachName, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('مدرب شخصي معتمد'),
              ),
            ),
            SizedBox(height: 20),
              TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'user name ',
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

            // اختيار التاريخ
            Text("اختر التاريخ", style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text(selectedDate == null
                  ? "اختر التاريخ"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
            ),
            SizedBox(height: 20),

            // اختيار الوقت
            Text("اختر الوقت", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedTime,
              hint: Text("اختر الوقت"),
              items: availableTimes.map((time) {
                return DropdownMenuItem(value: time, child: Text(time));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTime = value;
                });
              },
            ),
            SizedBox(height: 20),

            // اختيار وسيلة الدفع
            Text("اختر طريقة الدفع", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedPayment,
              hint: Text("اختر طريقة الدفع"),
              items: paymentMethods.map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPayment = value;
                });
              },
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('تأكيد الحجز', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
