import 'package:finalpro/plan.dart';
import 'package:finalpro/showtraining1.dart';
import 'package:flutter/material.dart';

class Choose extends StatefulWidget {
  const Choose({super.key});

  @override
  State<Choose> createState() => _ChooseState();
}

class _ChooseState extends State<Choose> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness App'),
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
                    MaterialPageRoute(builder: (context) => Plane()),
                  );
                },
                child: const Text('Upload Video'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                 
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Plan(
                            )),
                
                    );
                 
                },
                child: const Text('Live Training'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class Choose1 extends StatefulWidget {
  const Choose1({super.key});

  @override
  State<Choose1> createState() => _ChooseState1();
}

class _ChooseState1 extends State<Choose1> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness App'),
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
                    MaterialPageRoute(builder: (context) => Plane1()),
                  );
                },
                child: const Text('Upload Video'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // يمكنك تعديلها لاختيار تمرين معين
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>   Plan1(
                            
                            )),
                  );
                  
              
                },
                child: const Text('Live Training'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
