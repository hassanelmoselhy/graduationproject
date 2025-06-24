import 'package:finalpro/imageforupload.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';  
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
class Plane extends StatefulWidget {
  const Plane({super.key});
  @override
  State<Plane> createState() => _PlanStat1e();
}
class _PlanStat1e extends State<Plane> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AchievementsPage3()),
                  );
                },
                child: Text('Go to Achievements'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExercisesPage4(
                              totalExercises: 5, // عدد التمارين في اليوم
                            )),
                  );
                },
                child: Text("Today's Exercises"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class AchievementsPage3 extends StatefulWidget {
  @override
  _AchievementsPage3State createState() => _AchievementsPage3State();
}

class _AchievementsPage3State extends State<AchievementsPage3> {
  int completedExercises = 0;
  double score = 0;
  int totalExercises = 5;
  List<Map<String, dynamic>> achievements = [];

  bool _isExerciseInFitnessPlan(String exerciseName) {
    const List<String> fitnessExercises = [
      'push-up',
      'pull-up',
      'squats',
      'jumping-jacks',
      'sit-up',
    ];
    return fitnessExercises.contains(exerciseName.toLowerCase());
  }

  @override
  void initState() {
    super.initState();
    _initData(); // معالجة البيانات بشكل آمن مع async
  }

  void _initData() async {
    await loadAchievements();
    await fetchAllAchievements();

    // استقبال البيانات من UploadPage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        updateAchievements(args['score'], args['exerciseName']);
      }
    });
  }

  Future<void> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('achievements')
          .doc('fitness')
          .get();

      if (doc.exists) {
        setState(() {
          score = doc['score'] ?? 0;
          completedExercises = doc['completedExercises'] ?? 0;
        });
      }
    } catch (e) {
      print('Firestore load error: $e');
      // استخدم القيم المخزنة محليًا كبديل
      setState(() {
        score = prefs.getDouble('${email}_score_3') ?? 0;
        completedExercises = prefs.getInt('${email}_completedExercises_3') ?? 0;
      });
    }
  }

  Future<void> saveAchievements() async {
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');

  if (email == null || email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You must be logged in to save data')),
    );
    return;
  }

  try {
    // ✅ حفظ في مستند ثابت باسم "fitness" بدل .add()
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('achievements')
        .doc('fitness') // ← مستند ثابت زي therapy
        .set({
      'score': score,
      'completedExercises': completedExercises,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // تخزين محلي برضو لو حابب
    await prefs.setInt('${email}_completedExercises_3', completedExercises);
    await prefs.setDouble('${email}_score_3', score);
  } catch (e) {
    print('Firestore Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: ${e.toString()}')),
    );
  }
}


  void updateAchievements(double newScore, String exerciseName) async {
    if (!_isExerciseInFitnessPlan(exerciseName)) {
      print('Exercise "$exerciseName" is NOT in plan');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email == null) return;

    setState(() {
      completedExercises += 1;
      score = newScore;
    });

    await saveAchievements();
  }

Future<void> fetchAllAchievements() async {
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');

  if (email == null) return;

  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('achievements')
        .doc('fitness') // ← مستند ثابت
        .get();

    if (doc.exists) {
      setState(() {
        achievements = [doc.data() as Map<String, dynamic>];
      });
    }
  } catch (e) {
    print('Firestore fetch error: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<Map<String, dynamic>>(
  icon: Icon(Icons.history),
  onSelected: (achievement) {
    final timestamp = achievement['timestamp'];
    final dateText = (timestamp != null && timestamp is Timestamp)
        ? (timestamp as Timestamp).toDate().toLocal().toString().split(' ')[0]
        : 'No date';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Achievement Details'),
        content: Text(
          'Score: ${achievement['score']}\n'
          'Completed: ${achievement['completedExercises']}\n'
          'Date: $dateText',
        ),
      ),
    );
  },
  itemBuilder: (context) => achievements.map((a) {
    DateTime? date;
    if (a['timestamp'] != null && a['timestamp'] is Timestamp) {
      date = (a['timestamp'] as Timestamp).toDate();
    }

    return PopupMenuItem<Map<String, dynamic>>(
      value: a,
      child: Text(
        '${a['score']}% - ${date != null ? date.toLocal().toString().split(' ')[0] : 'No date'}',
      ),
    );
  }).toList(),
),

        ],
      ),
     body: Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.teal.shade100, Colors.teal.shade300],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ),
  child: SingleChildScrollView(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Achievement Circle
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${score.toInt()}%',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Circular Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: completedExercises / totalExercises,
                        strokeWidth: 11,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$completedExercises/$totalExercises',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Motivational Text
            Text(
              'Keep pushing forward!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.teal.shade900,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  ),
),

    );
  }
}

class ExercisesPage4 extends StatefulWidget {
  final int totalExercises;

  ExercisesPage4({required this.totalExercises}); 
  

  @override
  _ExercisesPageState createState() => _ExercisesPageState(); 
  
}

class _ExercisesPageState extends State<ExercisesPage4> {
  final List<Map<String, dynamic>> exercises4 = [
    {'name': 'Push-up', 'time': '1m 2s', 'icon': FontAwesomeIcons.personPraying  , 'screen': ImageScreen9(index: 0,)},
    {'name': 'pull-up', 'time': '1m 30s', 'icon': FontAwesomeIcons.gripLines , 'screen': ImageScreen10(index: 1,)},
    {'name': 'Squats', 'time': '3m 10s', 'icon': FontAwesomeIcons.personArrowDownToLine , 'screen': ImageScreen11(index: 2,)},
    {'name': 'jumping-jacks', 'time': '2m 15s', 'icon': FontAwesomeIcons.personWalking , 'screen': ImageScreen12(index: 3,)},
    {'name': 'sit-up', 'time': '4m 2s', 'icon': FontAwesomeIcons.personRunning , 'screen': ImageScreen13(index: 4,)},
   
  ]; 

  


 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Exercises'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: exercises4.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: FaIcon(
                exercises4[index]['icon'],
                color: Colors.green,
                size: 30,
              ),
              title: Text(exercises4[index]['name']!),
              onTap: () {
               Navigator.push(
                  context,
                  MaterialPageRoute( 
                    builder: (context) => exercises4[index]['screen'],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
class Plane1 extends StatefulWidget {
  const Plane1({super.key});

  @override
  _PlanState1 createState() => _PlanState1();
}

class _PlanState1 extends State<Plane1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('therapuls App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AchievementsPage5()),
                  );
                },
                child: Text('Go to Achievements'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExercisesPage6(
                              totalExercises: 2, // عدد التمارين في اليوم
                            )),
                  );
                },
                child: Text("Today's Exercises"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class AchievementsPage5 extends StatefulWidget {
  @override
  _AchievementsPageState6 createState() => _AchievementsPageState6();
}

class _AchievementsPageState6 extends State<AchievementsPage5> {
  int completedExercises = 0;
  double score = 0;
  int totalExercises = 2; 
  List<Map<String, dynamic>> achievements = [];


  // دالة للتحقق إذا كان التمرين جزءًا من خطة العلاج
  bool _isExerciseInFitnessPlan(String exerciseName) {
    const List<String> therapyExercises = [
      'Straight leg raise',
      'Bridging',
    ];
    return therapyExercises.contains(exerciseName);
  }

  @override
  void initState() {
    super.initState();
    loadAchievements();
    fetchAllAchievements();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        updateAchievements(args['score'], args['exerciseName']);
      }
    });
  } 

Future<void> fetchAllAchievements() async {
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');

  if (email == null) return;

  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('achievements')
        .doc('therapy')
        .get();

    if (doc.exists) {
      setState(() {
        achievements = [doc.data() as Map<String, dynamic>];
      });
    }
  } catch (e) {
    print('Firestore fetch error: $e');
  }
}


 Future<void> loadAchievements() async {
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');

  if (email != null) {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('achievements')
          .doc('therapy')
          .get();

      if (doc.exists) {
        setState(() {
          score = doc['score'] ?? 0;
          completedExercises = doc['completedExercises'] ?? 0;
        });
      }
    } catch (e) {
      print('Firestore load error: $e');
      // fallback from SharedPreferences
      setState(() {
        score = prefs.getDouble('${email}_score_5') ?? 0;
        completedExercises = prefs.getInt('${email}_completedExercises_5') ?? 0;
      });
    }
  }
}

Future<void> saveAchievements() async {
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');

  if (email != null) {
    await prefs.setInt('${email}_completedExercises_5', completedExercises);
    await prefs.setDouble('${email}_score_5', score);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('achievements')
          .doc('therapy')
          .set({
        'score': score,
        'completedExercises': completedExercises,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // <-- مهم

      await Future.delayed(Duration(seconds: 1)); // <-- انتظر للتحديث
      await fetchAllAchievements(); // <-- قراءة بعد التأكد من وجود timestamp
    } catch (e) {
      print('Firestore Error: $e');
    }
  }
}


  // تحديث الإنجازات عند إتمام التمرين
  void updateAchievements(double newScore, String exerciseName) async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email != null && _isExerciseInFitnessPlan(exerciseName)) {
      setState(() {
        completedExercises = (prefs.getInt('${email}_completedExercises_5') ?? 0) + 1;
        score = newScore;
      });

      // حفظ الإنجازات في SharedPreferences و Firebase
      await saveAchievements();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: Text(
    'Achievements',
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  ),
  centerTitle: true,
  backgroundColor: Colors.teal,
  actions: [
    PopupMenuButton<Map<String, dynamic>>(
      icon: Icon(Icons.history),
      onSelected: (achievement) {
  showDialog(
    context: context,
    builder: (_) {
      final timestamp = achievement['timestamp'];
      final dateText = (timestamp != null && timestamp is Timestamp)
          ? (timestamp as Timestamp).toDate().toString()
          : 'No date';

      return AlertDialog(
        title: Text('Achievement Details'),
        content: Text(
          'Score: ${achievement['score']}\n'
          'Completed: ${achievement['completedExercises']}\n'
          'Date: $dateText',
        ),
      );
    },
  );
},

  itemBuilder: (context) => achievements.map((a) {
  DateTime? date;
  if (a['timestamp'] != null && a['timestamp'] is Timestamp) {
    date = (a['timestamp'] as Timestamp).toDate();
  }

  return PopupMenuItem<Map<String, dynamic>>(
    value: a,
    child: Text(
      '${a['score']}% - ${date != null ? date.toLocal().toString().split(' ')[0] : 'No date'}',
    ),
  );
}).toList(),

    ),
  ],
),
body: Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.teal.shade100, Colors.teal.shade300],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ),
  child: SingleChildScrollView(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Achievement Circle
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${score.toInt()}%',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Circular Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 11,
                        backgroundColor: Colors.grey.shade300,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$completedExercises/$totalExercises',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Motivational Text
            Text(
              'Keep pushing forward!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.teal.shade900,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  ),
),

    );
  }
}
class ExercisesPage6 extends StatefulWidget {
  final int totalExercises;

  ExercisesPage6({required this.totalExercises});

  @override
  _ExercisesPageState1 createState() => _ExercisesPageState1();
}

class _ExercisesPageState1 extends State<ExercisesPage6> {
  final List<Map<String, dynamic>> exercises7 = [
    {'name': 'Straight leg raise', 'time': '2m 26s', 'icon': FontAwesomeIcons.personPraying ,'screen': ImageScreen14(index: 5,)},
    {'name': 'Bridging', 'time': '1m 30s', 'icon': FontAwesomeIcons.gripLines , 'screen': ImageScreen15(index: 6,)},
    // {'name': 'Squats', 'time': '3m 10s', 'icon': FontAwesomeIcons.personArrowDownToLine},
    // {'name': 'Lunges', 'time': '2m 15s', 'icon': FontAwesomeIcons.personWalking},
    // {'name': 'Burpees', 'time': '4m', 'icon': FontAwesomeIcons.personRunning},
    // {'name': 'Mountain Climbers', 'time': '2m 45s', 'icon': FontAwesomeIcons.personHiking},
    // {'name': 'Jumping Jacks', 'time': '3m', 'icon': FontAwesomeIcons.child},
    // {'name': 'Bicep Curls', 'time': '2m', 'icon': FontAwesomeIcons.dumbbell},
    // {'name': 'Tricep Dips', 'time': '2m 20s', 'icon': FontAwesomeIcons.handHoldingHeart},
    // {'name': 'Leg Raises', 'time': '3m 5s', 'icon': FontAwesomeIcons.personBooth},
    //  {'name': 'russian twists', 'time': '3m 5s', 'icon': FontAwesomeIcons.personBooth},
  ];
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Exercises'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: exercises7.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: FaIcon(
                exercises7[index]['icon'],
                color: Colors.green,
                size: 30,
              ),
              title: Text(exercises7[index]['name']!),
              onTap: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => exercises7[index]['screen'],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


