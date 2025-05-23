import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.of(context).pushReplacementNamed("/login");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      bodyTextStyle: TextStyle(fontSize: 16),
      imagePadding: EdgeInsets.all(24),
    );

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Bienvenido a Mi Estudio",
          body: "Organiza tus materias, notas, tareas y progreso en un solo lugar. ¡Estudia mejor y sin estrés!",
          image: Image.asset('assets/logo.png', color: theme.iconTheme.color, width: 120),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Tu estudio bajo control",
          body: "Visualiza tu calendario, organiza tus tareas, añade recordatorios y nunca olvides una entrega.",
          image: const Icon(Icons.calendar_today, size: 120),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Notas completas",
          body: "Guarda texto, imágenes y archivos en tus notas, y accede a ellas incluso sin conexión.",
          image: const Icon(Icons.note_alt, size: 120),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Empieza ya",
          body: "Presiona continuar para comenzar a usar la app.",
          image: const Icon(Icons.rocket_launch, size: 120),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text("Saltar"),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Comenzar", style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: Size(10, 10),
        color: theme.dividerColor,
        activeSize: Size(22, 10),
        activeColor: theme.primaryColor,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}