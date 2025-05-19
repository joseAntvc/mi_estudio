import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/auth_firebase.dart';
import 'package:mi_estudio/screens/dashboard_screen.dart';
import 'package:mi_estudio/screens/autentication/login_screen.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<bool>(
      future: isUserLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return AnimatedSplashScreen(
          backgroundColor: theme.scaffoldBackgroundColor,
          duration: 2000,
          splashIconSize: 150,
          splash: Image.asset(
            'assets/logo.png',
            color: theme.primaryColor,
          ),
          nextScreen: snapshot.data! ? DashboardScreen() : LoginScreen(),
          splashTransition: SplashTransition.scaleTransition,
          pageTransitionType: PageTransitionType.topToBottom,
        );
      },
    );
  }
  
  Future<bool> isUserLoggedIn() async {
    final user = AuthFirebase().getUser();
    return user != null;
  }
}