import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase_options.dart';
import 'package:mi_estudio/screens/billing_screen.dart';
import 'package:mi_estudio/screens/calendar_screen.dart';
import 'package:mi_estudio/screens/configuration_screen.dart';
import 'package:mi_estudio/screens/dashboard_screen.dart';
import 'package:mi_estudio/screens/autentication/login_screen.dart';
import 'package:mi_estudio/screens/autentication/password_screen.dart';
import 'package:mi_estudio/screens/first/onboarding_screen.dart';
import 'package:mi_estudio/screens/motivation_screen.dart';
import 'package:mi_estudio/screens/note/note_dateils_screen.dart';
import 'package:mi_estudio/screens/note/note_form_screen.dart';
import 'package:mi_estudio/screens/note/note_screen.dart';
import 'package:mi_estudio/screens/notificacion_screen.dart';
import 'package:mi_estudio/screens/profile_screen.dart';
import 'package:mi_estudio/screens/autentication/register_screen.dart';
import 'package:mi_estudio/screens/first/splash_screen.dart';
import 'package:mi_estudio/screens/subject/subject_form_screen.dart';
import 'package:mi_estudio/screens/subject/subject_screen.dart';
import 'package:mi_estudio/screens/ubication_screen.dart';
import 'package:mi_estudio/services/key.dart';
import 'package:mi_estudio/services/notification_services.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_settings.dart';
import 'package:mi_estudio/utils/provider/connectivity_provider.dart';
import 'package:mi_estudio/utils/provider/note_from_provider.dart';
import 'package:mi_estudio/utils/provider/notification_provider.dart';
import 'package:mi_estudio/utils/provider/register_provider.dart';
import 'package:mi_estudio/utils/provider/subject_from_provider.dart';
import 'package:mi_estudio/utils/provider/subscription_provider.dart';
import 'package:mi_estudio/utils/provider/task_provider.dart';
import 'package:mi_estudio/utils/provider/theme_provider.dart';
import 'package:mi_estudio/utils/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService.initializeNotification();
  FirebaseMessaging.onBackgroundMessage(
    NotificationService.firebaseMessagingBackgroundHandler,
  );
  await Supabase.initialize(
    url: "https://oxnoyaakisepzikjdtzb.supabase.co",
    anonKey: supabaseKey,
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
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
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

    Future<bool> hasSeenOnboarding() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('seenOnboarding') ?? false;
    }

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
      supportedLocales: const [
        Locale('es'),
        Locale('en'), 
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SfGlobalLocalizations.delegate, 
      ],
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
        "/noteDetails": (context) => const NoteDateilsScreen(),
        "/calendar": (context) => const CalendarScreen(),
        "/billing": (context) => const BillingScreen(),
        "/notifications": (context) => const NotificacionScreen(),
        "/motivation": (context) => MotivationScreen()
      },
      home: FutureBuilder<bool>(
        future: hasSeenOnboarding(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return snapshot.data! ? const SplashScreen() : const OnboardingScreen();
        },
      ),
    );
  }
}