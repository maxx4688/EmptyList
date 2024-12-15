import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notes_database/applock/pin_entry.dart';
import 'package:notes_database/applock/pin_provider.dart';
import 'package:notes_database/firebase/user_provider.dart';
import 'package:notes_database/login_page.dart';
import 'package:notes_database/pages/home_page.dart';
import 'package:notes_database/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => UserProvider()),
      ChangeNotifierProvider(create: (context) => CustomLockProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Auth Demo',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const CheckLogin(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context)=> const LoginPage()
      },
    );
  }
}

class CheckLogin extends StatefulWidget {
  const CheckLogin({super.key});

  @override
  _CheckLoginState createState() => _CheckLoginState();
}

class _CheckLoginState extends State<CheckLogin> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<dynamic> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool? status = prefs.getBool('isLocked');

    if (isLoggedIn) {
      String? userId = prefs.getString('userId');
      String? email = prefs.getString('email');

      if (userId != null && email != null) {
        Provider.of<UserProvider>(context, listen: false)
            .setUser(userId, email);
        if (status == true) {
          print('enabled $status');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PinEntryPage()),
          );
        } else {
          print('enabled - else $status');
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SpinKitDoubleBounce(
          color: Colors.black,
        ),
      ),
    );
  }
}
