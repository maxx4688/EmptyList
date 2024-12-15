import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notes_database/firebase/user_provider.dart';
import 'package:notes_database/theme/theme_constance.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isHidden = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  Future<void> _createAccount(
      String email, String password, BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            "Enter both email and password",
            style: TextStyle(
              color: Colors.white,
              wordSpacing: -2.0,
              letterSpacing: -2,
            ),
          ),
        ),
      );
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(
        {
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      // Save to UserProvider and Shared Preferences
      userProvider.setUser(userCredential.user!.uid, email);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', userCredential.user!.uid);

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      //I/flutter ( 5333): Account creation failed: [firebase_auth/weak-password] Password should be at least 6 characters

      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.black,
            content: Text(
              "User with this email already exists, Try logging in...",
              style: TextStyle(
                color: Colors.white,
                wordSpacing: -2.0,
                letterSpacing: -2,
              ),
            ),
          ),
        );
      } else if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.black,
            content: Text(
              "Weak Passowrd!!!!!",
              style: TextStyle(
                color: Colors.white,
                wordSpacing: -2.0,
                letterSpacing: -2,
              ),
            ),
          ),
        );
      } else {
        print("Account creation failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.black,
            content: Text(
              "Failed to create account, Try again later...",
              style: TextStyle(
                color: Colors.white,
                wordSpacing: -2.0,
                letterSpacing: -2,
              ),
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
                'New,',
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
            'Create a new account!',
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
              labelText: 'New email',
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
              labelText: 'New password',
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: isLoading == false
                ? ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color.fromARGB(255, 22, 22, 22),
                      ),
                    ),
                    onPressed: () {
                      _createAccount(_emailController.text,
                          _passwordController.text, context);
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: Colors.white,
                        wordSpacing: -2.0,
                        letterSpacing: -2,
                        fontWeight: FontWeight.bold,
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
                "Already have an account?",
                style: TextStyle(
                  wordSpacing: -2.0,
                  letterSpacing: -2,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Log in',
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
