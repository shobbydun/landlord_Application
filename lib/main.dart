import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:landify/authentication/auth_page.dart';
import 'package:landify/firebase_options.dart';
import 'package:landify/pages/home_page.dart';
import 'package:landify/pages/bills/bill_screen.dart';
import 'package:landify/pages/reminder_automation.dart';
import 'package:landify/pages/reports_screen.dart';
import 'package:landify/pages/settings_screen.dart';
import 'package:landify/pages/tenants_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthPage(),
          '/home': (context) => HomePage(),
          '/tenants': (context) => TenantsScreen(),
          '/bills': (context) => BillsScreen(),
          '/reports': (context) => ReportsScreen(),
          '/settings': (context) => SettingsScreen(),
          '/reminder_automation': (context) => ReminderAutomation(),
        });
  }
}
