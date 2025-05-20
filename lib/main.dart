import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase_options.dart';
import 'package:mi_estudio/screens/configuration_screen.dart';
import 'package:mi_estudio/screens/dashboard_screen.dart';
import 'package:mi_estudio/screens/autentication/login_screen.dart';
import 'package:mi_estudio/screens/autentication/password_screen.dart';
import 'package:mi_estudio/screens/note/note_form_screen.dart';
import 'package:mi_estudio/screens/note/note_screen.dart';
import 'package:mi_estudio/screens/profile_screen.dart';
import 'package:mi_estudio/screens/autentication/register_screen.dart';
import 'package:mi_estudio/screens/splash_screen.dart';
import 'package:mi_estudio/screens/subject/subject_form_screen.dart';
import 'package:mi_estudio/screens/subject/subject_screen.dart';
import 'package:mi_estudio/screens/ubication_screen.dart';
import 'package:mi_estudio/utils/custom_settings.dart';
import 'package:mi_estudio/utils/provider/note_from_provider.dart';
import 'package:mi_estudio/utils/provider/register_provider.dart';
import 'package:mi_estudio/utils/provider/subject_from_provider.dart';
import 'package:mi_estudio/utils/provider/theme_provider.dart';
import 'package:mi_estudio/utils/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: "https://oxnoyaakisepzikjdtzb.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im94bm95YWFraXNlcHppa2pkdHpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc0MjczNzcsImV4cCI6MjA2MzAwMzM3N30.5bDxo1pcsWdrZwpI1y5W299bpzqESX0uFm2xEKwEafA",
  );
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => SubjectFromProvider()),
        ChangeNotifierProvider(create: (_) => NoteFormProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData getCustomTheme(AppTheme theme) {
  switch (theme) {
      case AppTheme.blue:
        return Themes.blueTheme();
      //Por si llegara a meter mas temas personalizados
      default:
        return Themes.lightTheme();
    }
  }

  @override
  Widget build(BuildContext context) { 
    final provider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: getCustomTheme(provider.appTheme).copyWith(
        textTheme:  getCustomTheme(provider.appTheme).textTheme.apply(
          fontFamily: provider.font
        ),
      ),
      darkTheme: Themes.darkTheme().copyWith(
        textTheme: Themes.darkTheme().textTheme.apply(
          fontFamily: provider.font
        ),
      ),
      themeMode: provider.themeMode,
      title: 'MiEstudio',
      routes: {
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        "/password": (context) => const PasswordScreen(),
        "/dash": (context) => const DashboardScreen(),
        "/profile": (context) => const ProfileScreen(),
        "/configuration": (context) => const ConfigurationScreen(),
        "/ubication": (context) => const UbicationScreen(),
        "/subject": (context) => const SubjectScreen(),
        "/subjectForm": (context) => const SubjectFormScreen(),
        "/note": (context) => const NoteScreen(),
        "/noteForm": (context) => const NoteFormScreen(),
      },
      home: SplashScreen(),
    );
  }
}