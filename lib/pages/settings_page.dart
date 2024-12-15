import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_database/applock/pin_provider.dart';
import 'package:notes_database/firebase/user_provider.dart';
import 'package:notes_database/login_page.dart';
import 'package:notes_database/theme/theme_constance.dart';
import 'package:notes_database/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final changeTheme = Provider.of<ThemeProvider>(context);
    final provider = Provider.of<CustomLockProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: mainColour,
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 25,
          ),
        ),
      ),
      body: ScaleTransition(
        scale: _scaleAnimation,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.center,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
              ),
              child: Text(
                userProvider.email == null
                    ? '?'
                    : userProvider.email!.toUpperCase().substring(0, 1),
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 60,
                  color: mainColour,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Text(
                  userProvider.email == null
                      ? 'User not found\nPlease login again'
                      : userProvider.email!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    wordSpacing: -2.0,
                    letterSpacing: -1.5,
                  ),
                ),
                userProvider.isLoggedIn == false
                    ? ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(mainColour)),
                        onPressed: () {
                          Navigator.popAndPushNamed(context, '/login');
                        },
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const SizedBox()
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Divider(
              color: Theme.of(context).cardColor,
            ),
            const Text(
              'APP',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 20,
                color: mainColour,
              ),
            ),
            ListTile(
              title: const Text(
                'Switch theme',
                style: TextStyle(
                  wordSpacing: -2.0,
                  letterSpacing: -1.5,
                ),
              ),
              onTap: () {
                changeTheme.toggleTheme();
              },
              trailing: Theme.of(context).brightness == Brightness.light
                  ? const Icon(Icons.circle_outlined)
                  : const Icon(
                      Icons.circle,
                      color: mainColour,
                    ),
            ),
            ListTile(
              title: Text(
                provider.isLocked == false
                    ? "Enable App lock"
                    : "Disable App lock",
                style: const TextStyle(
                  wordSpacing: -2.0,
                  letterSpacing: -2,
                ),
              ),
              trailing: provider.isLocked == false
                  ? const Icon(Icons.circle_outlined)
                  : const Icon(
                      Icons.circle,
                      color: mainColour,
                    ),
              onTap: () async {
                if (provider.isLocked == false) {
                  // Ask for a new PIN
                  final newPin = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      TextEditingController pinController =
                          TextEditingController();
                      return AlertDialog(
                        backgroundColor: Theme.of(context).cardColor,
                        title: const Center(
                          child: Text(
                            "Set PIN",
                            style: TextStyle(
                                fontFamily: 'poppins', color: mainColour),
                          ),
                        ),
                        content: TextField(
                          cursorOpacityAnimates: true,
                          cursorColor: mainColour,
                          controller: pinController,
                          style: const TextStyle(fontFamily: 'poppins'),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: mainColour,
                              ),
                            ),
                            floatingLabelStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                              wordSpacing: -2.0,
                              letterSpacing: -2,
                            ),
                            labelText: "Enter 4-digit PIN",
                          ),
                        ),
                        actions: [
                          Center(
                            child: ElevatedButton(
                              style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(mainColour)),
                              onPressed: () {
                                Navigator.pop(context, pinController.text);
                              },
                              child: const Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'poppins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  if (newPin != null && newPin.length == 4) {
                    await provider.enableLock(newPin);
                  }
                } else {
                  await provider.disableLock();
                }
              },
            ),
            Divider(
              color: Theme.of(context).cardColor,
            ),
            const Text(
              'DEVELOPER',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 20,
                color: mainColour,
              ),
            ),
            ListTile(
              title: const Text(
                'Feedback',
                style: TextStyle(
                  wordSpacing: -2.0,
                  letterSpacing: -2,
                ),
              ),
              onTap: () {
                launchUrl(Uri.parse(
                    "mailto:alexmaxx8055@gmail.com?subject=Your feedback subject here"));
              },
            ),
            ListTile(
              title: const Text(
                'Report a bug',
                style: TextStyle(
                  wordSpacing: -2.0,
                  letterSpacing: -2,
                ),
              ),
              onTap: () {
                launchUrl(Uri.parse(
                    "mailto:alexmaxx8055@gmail.com?subject=Your query subject here"));
              },
            ),
            Divider(
              color: Theme.of(context).cardColor,
            ),
            const Text(
              'USER',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 20,
                color: mainColour,
              ),
            ),
            userProvider.email == null
                ? const SizedBox()
                : ListTile(
                    title: const Text(
                      'Log out',
                      style: TextStyle(
                        wordSpacing: -2.0,
                        letterSpacing: -2,
                      ),
                    ),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      userProvider.logout();
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', false);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                  ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 10,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Not',
                  style: TextStyle(fontSize: 30, fontFamily: 'poppins'),
                ),
                Text(
                  'ing',
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'poppins',
                    color: mainColour,
                  ),
                ),
              ],
            ),
            Divider(
              color: Theme.of(context).cardColor,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'BY ASHISH.',
                  style: TextStyle(
                    fontSize: 15,
                    wordSpacing: -2.0,
                    letterSpacing: -1.5,
                  ),
                ),
                const Spacer(),
                MyButton(
                  link: 'lib/assets/github.png',
                  onTap: () {
                    launchUrl(Uri.parse('https://github.com/maxx4688'));
                  },
                ),
                MyButton(
                  link: 'lib/assets/instagram.png',
                  onTap: () {
                    launchUrl(Uri.parse('https://instagram.com/maxx4688'));
                  },
                ),
                MyButton(
                  link: 'lib/assets/x.png',
                  onTap: () {
                    launchUrl(Uri.parse('https://twitter.com/maxx4688'));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MyButton extends StatelessWidget {
  final String link;
  void Function()? onTap;
  MyButton({super.key, required this.link, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      splashColor: mainColour,
      onTap: onTap,
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: SizedBox(
          height: 30,
          width: 30,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Image.asset(
              link,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : mainColour,
            ),
          ),
        ),
      ),
    );
  }
}
