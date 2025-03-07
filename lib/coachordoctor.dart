import 'package:finalpro/chooseuploadorlive.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class CoachesPage extends StatefulWidget {
  final String title;

  CoachesPage({required this.title});

  @override
  _CoachesPageState createState() => _CoachesPageState();
}

class _CoachesPageState extends State<CoachesPage> {
  String searchQuery = ""; // متغير لتخزين نص البحث

  // قائمة بيانات الأشخاص
  final List<Map<String, dynamic>> allCoaches = [
    {'name': 'coaches Hassan', 'location': 'Maadi', 'age': 36, 'experience': 14, 'rating': 4.5, 'image': 'assets/images/OIP.jpg', 'phone': '+201550598053'},
    {'name': 'coaches Hossam', 'location': 'Nasr City', 'age': 40, 'experience': 18, 'rating': 4.7, 'image': 'assets/images/OIP.jpg', 'phone': '+201550598053'},
    {'name': 'coaches Ahmed', 'location': 'Zamalek', 'age': 29, 'experience': 8, 'rating': 4.3, 'image': 'assets/images/OIP.jpg', 'phone': '+201550598053'},
    {'name': 'coaches Mona', 'location': 'Heliopolis', 'age': 35, 'experience': 12, 'rating': 4.6, 'image': 'assets/images/OIP.jpg', 'phone': '+201550598053'},
    {'name': 'coaches Sara', 'location': 'Dokki', 'age': 32, 'experience': 10, 'rating': 4.4, 'image': 'assets/images/OIP.jpg', 'phone': '+201550598053'},
    {'name': 'coaches Khaled', 'location': 'Giza', 'age': 38, 'experience': 16, 'rating': 4.8, 'image': 'assets/images/OIP.jpg', 'phone': '+201550598053'},
  ];

  List<Map<String, dynamic>> filteredCoaches = [];

  @override
  void initState() {
    super.initState();
    filteredCoaches = allCoaches;
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
 // مسار الصورة

  CoachDoctorCard({
    required this.name,
    required this.rating,
    required this.location,
    required this.age,
    required this.experience,
    required this.imagePath,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // عند الضغط على العنصر، عرض المزيد من التفاصيل
        showModalBottomSheet(
          context: context,
          builder: (context) => CoachDoctorDetails(
            name: name,
            rating: rating,
            location: location,
            age: age,
            experience: experience, phoneNumber: phoneNumber,
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
  final String phoneNumber; // رقم الهاتف

  CoachDoctorDetails({
    required this.name,
    required this.rating,
    required this.location,
    required this.age,
    required this.experience,
    required this.phoneNumber, // تمرير رقم الهاتف
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
  List<Map<String, dynamic>> data = [
    {'name': 'Dr Hassan', 'location': 'Maadi', 'age': 36, 'experience': 14, 'rating': 4.5 , 'image': 'assets/images/search_doc_2.png' , 'phone': '+201550598053'},
    {'name': 'Dr Hossam', 'location': 'Nasr City', 'age': 40, 'experience': 18, 'rating': 4.7 , 'image': 'assets/images/search_doc_3.png' , 'phone': '+201551704101'},
    {'name': 'Dr Ahmed', 'location': 'Zamalek', 'age': 29, 'experience': 8, 'rating': 4.3 , 'image': 'assets/images/search_doc_4.png','phone': '+201152452727'},
    {'name': 'Dr Mona', 'location': 'Heliopolis', 'age': 35, 'experience': 12, 'rating': 4.6 , 'image': 'assets/images/search_doc_1.png', 'phone': '+201550598053'},
    {'name': 'Dr Sara', 'location': 'Dokki', 'age': 32, 'experience': 10, 'rating': 4.4 , 'image': 'assets/images/Asma_Khan.png', 'phone': '+201550598053'},
    {'name': 'Dr Khaled', 'location': 'Giza', 'age': 38, 'experience': 16, 'rating': 4.8 , 'image': 'assets/images/Johir_Raihan.png', 'phone': '+201550598053' },
  ];

  List<Map<String, dynamic>> filteredData = [];

  @override
  void initState() {
    super.initState();
    filteredData = List.from(data); // تعيين القائمة الافتراضية عند بدء الصفحة
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
   // مسار الصورة

  CoachDoctorCard1({
    required this.name,
    required this.rating,
    required this.location,
    required this.age,
    required this.experience,
    required this.imagePath,
    required this.phoneNumber,
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

  CoachDoctorDetails1({
    required this.name,
    required this.rating,
    required this.location,
    required this.age,
    required this.experience,
    required this.phoneNumber,
     required this.imagePath, // تمرير رقم الهاتف
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
                onPressed: () => _callPhone(phoneNumber), // إجراء اتصال
              ),
             IconButton(
                padding: EdgeInsets.only(bottom: 28),
             icon: Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
              onPressed: () => _sendWhatsAppMessage(phoneNumber),
              ),
             IconButton(
                padding: EdgeInsets.only(bottom: 28),
  icon: Icon( FontAwesomeIcons.dumbbell, color: Colors.green),
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Choose1(), // Ensure 'Plan' is a defined widget
      ),
    );
  },
)

            ],
          )
        ],
      ),
    );
  }
}
