import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalpro/showtraining.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';  
import 'package:shared_preferences/shared_preferences.dart'; 
class Plan extends StatefulWidget {
  const Plan({super.key});
  @override
  State<Plan> createState() => _PlanState();
}
class _PlanState extends State<Plan> {
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
                    MaterialPageRoute(builder: (context) => AchievementsPage()),
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
                        builder: (context) => ExercisesPage(
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


class AchievementsPage extends StatefulWidget {
  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  int completedExercises = 0;
  double score = 0;
  int totalExercises = 5;
  bool isLoading = true;
  List<Map<String, dynamic>> firebaseScores = [];

  final List<Map<String, dynamic>> exercises = [
    {'name': 'Push-up', 'time': '1m 2s'},
    {'name': 'pull-up', 'time': '1m 30s'},
    {'name': 'Squats', 'time': '3m 10s'},
    {'name': 'jumping-jacks', 'time': '2m 15s'},
    {'name': 'sit-up', 'time': '4m 2s'},
  ];

  @override
  void initState() {
    super.initState();
    initializeAchievements();
    fetchScoresFromFirebase();
  }

 Future<void> fetchScoresFromFirebase() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('achievements')
        .orderBy('timestamp', descending: true)
        .get();

    final scores = snapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      firebaseScores = scores;
    });
  } catch (e) {
    debugPrint("❌ خطأ في جلب السكورات من Firebase: $e");
  }
}

  Future<void> initializeAchievements() async {
    await resetDailyAchievements();
    await loadAchievements();
    setState(() => isLoading = false);
  }

  Future<void> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email != null) {
      completedExercises = prefs.getInt('${email}_completedExercises') ?? 0;
      score = prefs.getDouble('${email}_score') ?? 0;
      totalExercises = exercises.length; // ✅ ديناميكي
    }
  }

  Future<void> saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email != null) {
      await prefs.setInt('${email}_completedExercises', completedExercises);
      await prefs.setDouble('${email}_score', score);
      await prefs.setInt('${email}_totalExercises', totalExercises);
    }
  }

  Future<void> resetDailyAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email != null) {
      String today = DateTime.now().toIso8601String().split("T")[0];
      String? lastResetDate = prefs.getString('${email}_lastResetDate');

      if (lastResetDate != today) {
        await prefs.setInt('${email}_completedExercises', 0);
        await prefs.setDouble('${email}_score', 0);
        await prefs.setString('${email}_lastResetDate', today);
        completedExercises = 0;
        score = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
     body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : Container(
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
                children: [
                  // Circle Score
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
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
                            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
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

                  // Circular progress
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
                              value: totalExercises > 0
                                  ? completedExercises / totalExercises
                                  : 0,
                              strokeWidth: 11,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                            ),
                          ),
                          Column(
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
                                style: TextStyle(fontSize: 14, color: Colors.teal.shade700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Keep pushing forward!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'نتائج التمارين:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ✅ استبدال Expanded بـ ListView shrinkWrap
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: exercises.map((exercise) {
                      final matchedScores = firebaseScores.where(
                        (score) =>
                            score['exercise'].toString().toLowerCase() ==
                            exercise['name'].toString().toLowerCase(),
                      ).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (matchedScores.isEmpty)
                            const Text(
                              "لا يوجد نتائج",
                              style: TextStyle(color: Colors.red),
                            )
                          else
                            ...matchedScores.map(
                              (score) => Padding(
                                padding: const EdgeInsets.only(left: 16.0, bottom: 4),
                                child: Text(
                                  "• Score: ${score['score']}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          const Divider(),
                        ],
                      );
                    }).toList(),
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


class ExercisesPage extends StatefulWidget {
  final int totalExercises;

  ExercisesPage({required this.totalExercises});

  @override
  _ExercisesPageState createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final List<Map<String, dynamic>> exercises = [
    {'name': 'Push-up', 'time': '1m 2s', 'icon': FontAwesomeIcons.personPraying  , 'screen': ImageScreen(index: 0,)},
    {'name': 'pull-up', 'time': '1m 30s', 'icon': FontAwesomeIcons.gripLines , 'screen': ImageScreen1(index: 1,)},
    {'name': 'Squats', 'time': '3m 10s', 'icon': FontAwesomeIcons.personArrowDownToLine , 'screen': ImageScreen2(index: 2,)},
    {'name': 'jumping-jacks', 'time': '2m 15s', 'icon': FontAwesomeIcons.personWalking , 'screen': ImageScreen3(index: 3,)},
    {'name': 'sit-up', 'time': '4m 2s', 'icon': FontAwesomeIcons.personRunning , 'screen': ImageScreen4(index: 4,)},
   
  ];


 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Exercises'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: FaIcon(
                exercises[index]['icon'],
                color: Colors.green,
                size: 30,
              ),
              title: Text(exercises[index]['name']!),
              subtitle: Text('Duration: ${exercises[index]['time']}'),
              onTap: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => exercises[index]['screen'],
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
class Plan1 extends StatefulWidget {
  const Plan1({super.key});

  @override
  _PlanState1 createState() => _PlanState1();
}

class _PlanState1 extends State<Plan1> {
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
                    MaterialPageRoute(builder: (context) => AchievementsPage1()),
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
                        builder: (context) => ExercisesPage1(
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


class AchievementsPage1 extends StatefulWidget {
  @override
  _AchievementsPageState1 createState() => _AchievementsPageState1();
}

class _AchievementsPageState1 extends State<AchievementsPage1> {
  int completedExercises = 0;
  double score = 0;
  int totalExercises = 0;
  bool isLoading = true;

  final List<Map<String, dynamic>> exercises1 = [
    {'name': 'Straight leg raise', 'time': '2m 26s'},
    {'name': 'Bridging', 'time': '1m 30s'},
  ];

  List<Map<String, dynamic>> firebaseScores = [];

  @override
  void initState() {
    super.initState();
    fetchScoresFromFirebase();
  }
Future<void> fetchScoresFromFirebase() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('achievements')
        .orderBy('timestamp', descending: true)
        .get();

    final allScores = snapshot.docs.map((doc) => doc.data()).toList();

    // احسب عدد التمارين اللي ليها نتائج
    final matched = exercises1.where((exercise) {
      return allScores.any((score) =>
          score['exercise'].toString().toLowerCase() ==
          exercise['name'].toString().toLowerCase());
    }).toList();

    setState(() {
      firebaseScores = allScores;
      completedExercises = matched.length;
      totalExercises = exercises1.length;
      score = (completedExercises / totalExercises) * 100;
      isLoading = false;
    });
  } catch (e) {
    debugPrint("❌ خطأ في جلب السكورات من Firebase: $e");
    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : Container(
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
                      gradient: const LinearGradient(
                          colors: [Colors.green, Colors.teal]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4)),
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
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${score.toInt()}%',
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Progress Indicator
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
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.orange),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$completedExercises/$totalExercises',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade800)),
                              const SizedBox(height: 4),
                              Text('Completed',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.teal.shade700)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Keep pushing forward!',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.teal.shade900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // ✅ عرض جميع السكورات
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: exercises1.map((exercise) {
                      final matchedScores = firebaseScores
                          .where((score) =>
                              score['exercise'].toString().toLowerCase() ==
                              exercise['name'].toString().toLowerCase())
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (matchedScores.isEmpty)
                            const Text(
                              "لا يوجد نتائج",
                              style: TextStyle(color: Colors.red),
                            )
                          else
                            ...matchedScores.map((score) => Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, bottom: 4),
                                  child: Text(
                                      "• Score: ${score['score']}",
                                      style: const TextStyle(fontSize: 16)),
                                )),
                          const Divider(),
                        ],
                      );
                    }).toList(),
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

class ExercisesPage1 extends StatefulWidget {
  final int totalExercises;

  ExercisesPage1({required this.totalExercises});

  @override
  _ExercisesPageState1 createState() => _ExercisesPageState1();
}

class _ExercisesPageState1 extends State<ExercisesPage1> {
  final List<Map<String, dynamic>> exercises1 = [
    {'name': 'Straight leg raise', 'time': '2m 26s', 'icon': FontAwesomeIcons.personPraying ,'screen': ImageScreen5(index: 5,)},
    {'name': 'Bridging', 'time': '1m 30s', 'icon': FontAwesomeIcons.gripLines , 'screen': ImageScreen6(index: 6,)},
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
        itemCount: exercises1.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: FaIcon(
                exercises1[index]['icon'],
                color: Colors.green,
                size: 30,
              ),
              title: Text(exercises1[index]['name']!),
              subtitle: Text('Duration: ${exercises1[index]['time']}'),
              onTap: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => exercises1[index]['screen'],
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


