import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_database/applock/pin_provider.dart';
import 'package:notes_database/firebase/user_provider.dart';
import 'package:notes_database/login_page.dart';
import 'package:notes_database/theme/theme_constance.dart';
import 'package:notes_database/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final changeTheme = Provider.of<ThemeProvider>(context);
    final provider = Provider.of<CustomLockProvider>(context);

    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(
            height: 50,
          ),
          const Text(
            'Hello,',
            style: TextStyle(
              color: mainColour,
              fontSize: 40,
              fontFamily: 'poppins',
            ),
          ),
          Text(
            userProvider.email!,
            style: const TextStyle(
              wordSpacing: 1.0,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Card(
            color: Theme.of(context).cardColor,
            elevation: 10,
            child: ListTile(
              title: const Text(
                'Switch theme',
                style: TextStyle(fontFamily: 'poppins'),
              ),
              onTap: () {
                changeTheme.toggleTheme();
              },
            ),
          ),
          Card(
            color: Theme.of(context).cardColor,
            elevation: 10,
            child: SwitchListTile(
              thumbIcon: const WidgetStatePropertyAll(Icon(
                Icons.verified_user_rounded,
                color: Colors.green,
              )),
              activeTrackColor: Colors.green,
              title: Text(
                provider.isLocked == false
                    ? "Enable App lock"
                    : "Disable App lock",
                style: const TextStyle(fontFamily: 'poppins'),
              ),
              value: provider.isLocked,
              onChanged: (value) async {
                if (value) {
                  // Ask for a new PIN
                  final newPin = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      TextEditingController pinController =
                          TextEditingController();
                      return AlertDialog(
                        title: const Text(
                          "Set PIN",
                          style: TextStyle(
                              fontFamily: 'poppins', color: mainColour),
                        ),
                        content: TextField(
                          cursorColor: mainColour,
                          controller: pinController,
                          style: const TextStyle(fontFamily: 'poppins'),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: InputDecoration(
                            floatingLabelStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            labelText: "Enter 4-digit PIN",
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(mainColour)),
                            onPressed: () {
                              Navigator.pop(context, pinController.text);
                              print(provider.isLocked);
                              print(provider.code);
                            },
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'poppins',
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
          ),
          // ListTile(
          //   title: Text('Check in console'),
          //   onTap: () {
          //     print(provider.code);
          //     print(provider.isLocked);
          //   },
          // ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.67,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Not',
                style: TextStyle(fontSize: 20, fontFamily: 'poppins'),
              ),
              Text(
                'ing',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'poppins',
                  color: mainColour,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(),
          const Text(
            'Danger zone!!',
            style: TextStyle(
              color: Colors.red,
              wordSpacing: 1.0,
              letterSpacing: -1,
            ),
          ),
          Card(
            color: Theme.of(context).cardColor,
            elevation: 10,
            child: ListTile(
              title: const Text(
                'Log out',
                style: TextStyle(fontFamily: 'poppins'),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                userProvider.logout();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);

                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
