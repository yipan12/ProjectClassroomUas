import 'package:Classroom/pages/homePage.dart';
import 'package:Classroom/pages/loginPages.dart';
import 'package:Classroom/pages/registerPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Classroom/providers/kelasProvider.dart';
import 'package:Classroom/providers/authProvider.dart';
import 'package:Classroom/pages/splashPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://aaqdxzndfjiswpyxgrxa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFhcWR4em5kZmppc3dweXhncnhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ2MjA1NzgsImV4cCI6MjA1MDE5NjU3OH0.xtrK2eKqzuYxI2RRPNLa27Khp4KyK7B_1v_ddmi0tHQ',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => KelasProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Classroom App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => Splashpage(),
          '/login': (_) => LoginPage(),
          '/register': (_) => RegisterPage(),
          '/home': (_) => HomePage(),
        },
      ),
    );
  }
}
