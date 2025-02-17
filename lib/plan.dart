import 'package:finalpro/Time.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
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
                              totalExercises: 11, // عدد التمارين في اليوم
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
class AchievementsPage extends StatelessWidget {
  static int completedExercises = 0; // عدد التمارين المكتملة
  static double score = 0; // النقاط الحالية
  @override
  Widget build(BuildContext context) {
    int totalExercises = 11; // عدد التمارين اليومية
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
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
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
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
                          SizedBox(height: 4),
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
              SizedBox(height: 32),
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
    {'name': 'Push-up', 'time': '2m 26s', 'icon': FontAwesomeIcons.personPraying},
    {'name': 'Plank', 'time': '1m 30s', 'icon': FontAwesomeIcons.gripLines},
    {'name': 'Squats', 'time': '3m 10s', 'icon': FontAwesomeIcons.personArrowDownToLine},
    {'name': 'Lunges', 'time': '2m 15s', 'icon': FontAwesomeIcons.personWalking},
    {'name': 'Burpees', 'time': '4m', 'icon': FontAwesomeIcons.personRunning},
    {'name': 'Mountain Climbers', 'time': '2m 45s', 'icon': FontAwesomeIcons.personHiking},
    {'name': 'Jumping Jacks', 'time': '3m', 'icon': FontAwesomeIcons.child},
    {'name': 'Bicep Curls', 'time': '2m', 'icon': FontAwesomeIcons.dumbbell},
    {'name': 'Tricep Dips', 'time': '2m 20s', 'icon': FontAwesomeIcons.handHoldingHeart},
    {'name': 'Leg Raises', 'time': '3m 5s', 'icon': FontAwesomeIcons.personBooth},
     {'name': 'russian twists', 'time': '3m 5s', 'icon': FontAwesomeIcons.personBooth},
  ];

  void completeExercise() {
  setState(() {
    if (AchievementsPage.completedExercises < widget.totalExercises) {
      AchievementsPage.completedExercises++;
    }
    AchievementsPage.score = (AchievementsPage.completedExercises / widget.totalExercises) * 100;
    
    // تأكد أن النسبة لا تتجاوز 100%
    AchievementsPage.score = AchievementsPage.score.clamp(0, 100);
  });
}


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
                completeExercise();
                Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ExerciseTimerPage(
        exerciseName: exercises[index]['name']!,
        duration: exercises[index]['time'],
      ),
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

class AchievementsPage1 extends StatelessWidget {
  static int completedExercises = 0; // عدد التمارين المكتملة
  static double score = 0; // النقاط الحالية

  @override
  Widget build(BuildContext context) {
    int totalExercises = 2; // عدد التمارين اليومية
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
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
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
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
                          SizedBox(height: 4),
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
              SizedBox(height: 32),
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
    {'name': 'Straight leg raise', 'time': '2m 26s', 'icon': FontAwesomeIcons.personPraying},
    {'name': 'Bridging', 'time': '1m 30s', 'icon': FontAwesomeIcons.gripLines},
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

  void completeExercise1() {
  setState(() {
    if (AchievementsPage1.completedExercises < widget.totalExercises) {
      AchievementsPage1.completedExercises++;
    }
    AchievementsPage1.score = (AchievementsPage1.completedExercises / widget.totalExercises) * 100;
    
    // تأكد أن النسبة لا تتجاوز 100%
    AchievementsPage1.score = AchievementsPage1.score.clamp(0, 100);
  });
}


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
                completeExercise1();
                 Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ExerciseTimerPage(
        exerciseName: exercises1[index]['name']!,
        duration: exercises1[index]['time'],
      ),
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


