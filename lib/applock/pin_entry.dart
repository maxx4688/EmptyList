import 'package:flutter/material.dart';
import 'package:notes_database/applock/pin_provider.dart';
import 'package:notes_database/pages/home_page.dart';
import 'package:notes_database/theme/theme_constance.dart';
import 'package:provider/provider.dart';

class PinEntryPage extends StatelessWidget {
  PinEntryPage({super.key});

  final pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomLockProvider>(context);
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: provider.code == null
            ? const Center(
                child: Text('Secure code not found!!'),
              )
            : ListView(
                children: [
                  SizedBox(
                    height: screen.height / 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onLongPress: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Forgot your pin??"),
                              action: SnackBarAction(
                                textColor: mainColour,
                                label: 'Yes',
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                },
                              ),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.green,
                          size: 38,
                        ),
                      ),
                      const Text(
                        'SECURE',
                        style: TextStyle(
                          fontSize: 38,
                          fontFamily: 'poppins',
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      "Please enter your 4-digit PIN to proceed.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        wordSpacing: -2.0,
                        letterSpacing: -2,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.black54,
                      ),
                    ),
                  ),
                  // Text(provider.code!),
                  SizedBox(
                    height: screen.height / 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      cursorColor: mainColour,
                      obscureText: true,
                      maxLength: 4,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        labelStyle: const TextStyle(color: mainColour),
                        labelText: "PIN",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screen.height / 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(mainColour),
                        ),
                        onPressed: () {
                          if (pinController.text == provider.code!) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomePage()),
                            );
                          } else if (pinController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.black,
                                content: Text(
                                  "Enter you pin",
                                  style: TextStyle(
                                    color: Colors.white,
                                    wordSpacing: -2.0,
                                    letterSpacing: -2,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.black,
                                content: Text(
                                  "Incorrect PIN",
                                  style: TextStyle(
                                    color: mainColour,
                                    wordSpacing: -2.0,
                                    letterSpacing: -2,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "CONTINUE",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
