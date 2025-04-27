import 'package:flutter/material.dart';
import 'package:fronte/auth/login_page.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({super.key});

  void _onIntroEnd(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to HonGym",
          body: "Track your workouts and achieve your fitness goals.",
          image: const Center(child: Icon(Icons.fitness_center, size: 100)),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
            titleTextStyle:
                TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            bodyTextStyle: TextStyle(fontSize: 16),
          ),
        ),
        PageViewModel(
          title: "Start by creating your own workout plans",
          body:
              "Workouts are composed of sessions which are themselves composed of exercises.",
          image: const Center(child: Icon(Icons.edit, size: 100)),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
            titleTextStyle:
                TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            bodyTextStyle: TextStyle(fontSize: 16),
          ),
        ),
        PageViewModel(
          title: "Get ready to hit the gym!",
          body: "Go to the gym with HonGym and record your workout",
          image: const Center(child: Icon(Icons.sports_gymnastics, size: 100)),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
            titleTextStyle:
                TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            bodyTextStyle: TextStyle(fontSize: 16),
          ),
        ),
        PageViewModel(
          title: "Keep track of your progress by analyzing your workouts",
          body: "Check on the different available statistics:\n\n"
              "- Total weight lifted\n"
              "- Number of sessions completed\n"
              "- Personal bests for each exercise\n"
              "- Weekly and monthly progress trends\n"
              "- Calories burned during workouts",
          image: const Center(child: Icon(Icons.show_chart, size: 100)),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
            titleTextStyle:
                TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            bodyTextStyle: TextStyle(fontSize: 16),
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showBackButton: true,
      back: const Icon(Icons.arrow_back),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
