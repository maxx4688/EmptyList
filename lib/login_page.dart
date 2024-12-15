import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notes_database/firebase/user_provider.dart';
import 'package:notes_database/forgot_password.dart';
import 'package:notes_database/signup_page.dart';
import 'package:notes_database/theme/theme_constance.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isHidden = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  Future<void> _loginUser(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            "Enter both Email and password",
            style: TextStyle(
              color: Colors.white,
              wordSpacing: -2.0,
              letterSpacing: -2,
            ),
          ),
        ),
      );
    } else {
      setState(() {
        isLoading = true;
      });
      try {
        // Try to signing in the user
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Checking if user data exists in Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          // Save user data to UserProvider and Shared Preferences
          userProvider.setUser(userCredential.user!.uid, email);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('email', email);
          await prefs.setString('userId', userCredential.user!.uid);

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // If user data does not exist, prompt for account creation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.black,
              content: Text(
                "User not found. Please create a new account.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      } catch (e) {
        // Handle login errors
        if (e is FirebaseAuthException) {
          // If user not found, prompt for account creation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.black,
              content: Text(
                "User not found. Please create a new account.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        } else {
          // Show other errors (e.g., wrong password)
          print("Login failed: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.black,
              content: Text(
                "Login Failed, Please try again",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 40.0,
        ),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            child: const Center(
              child: Text(
                'Noting',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'poppins',
                ),
              ),
            ),
          ),
          const Row(
            children: [
              Text(
                'Hi,',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 35,
                ),
              ),
              Text(
                'User',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 35,
                  color: mainColour,
                ),
              ),
            ],
          ),
          Text(
            'Log in your account!',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black54,
              wordSpacing: -2.0,
              letterSpacing: -2,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 20,
          ),
          TextField(
            cursorColor: mainColour,
            controller: _emailController,
            cursorOpacityAnimates: true,
            style: const TextStyle(
              wordSpacing: -2.0,
              letterSpacing: -2,
            ),
            scrollPhysics: const BouncingScrollPhysics(),
            decoration: const InputDecoration(
              floatingLabelStyle: TextStyle(
                color: mainColour,
                wordSpacing: -2.0,
                letterSpacing: -2,
              ),
              labelText: 'Email',
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 30,
          ),
          TextField(
            cursorColor: mainColour,
            controller: _passwordController,
            cursorOpacityAnimates: true,
            style: const TextStyle(
              wordSpacing: -2.0,
              letterSpacing: -2,
            ),
            decoration: InputDecoration(
              floatingLabelStyle: const TextStyle(
                color: mainColour,
                wordSpacing: -2.0,
                letterSpacing: -2,
              ),
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  isHidden == false ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    isHidden = !isHidden;
                  });
                },
              ),
            ),
            obscureText: isHidden,
            scrollPhysics: const BouncingScrollPhysics(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 15,
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: mainColour,
                      fontSize: 12,
                      wordSpacing: -2.0,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: isLoading == false
                ? Hero(
                    tag: 'pass',
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(255, 22, 22, 22),
                        ),
                      ),
                      onPressed: () => _loginUser(context),
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          color: Colors.white,
                          wordSpacing: -2.0,
                          letterSpacing: -2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : SpinKitThreeBounce(
                    size: 25,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?",
                style: TextStyle(
                  wordSpacing: -2.0,
                  letterSpacing: -2,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoDialogRoute(
                        builder: (context) => const SignupPage(),
                        context: context),
                  );
                },
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    color: mainColour,
                    wordSpacing: -2.0,
                    letterSpacing: -2,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
