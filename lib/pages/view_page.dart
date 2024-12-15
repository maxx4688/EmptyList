import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_database/theme/theme_constance.dart';
import 'package:share_plus/share_plus.dart';

class ViewPage extends StatefulWidget {
  final String title;
  final String content;
  final Timestamp time;
  final String id;
  const ViewPage(
      {super.key,
      required this.title,
      required this.content,
      required this.time,
      required this.id});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMMM dd, HH:mm').format(dateTime);
  }

  late TextEditingController _titleEditController;
  late TextEditingController _contentEditController;
  bool _edit = false;

  @override
  void initState() {
    _titleEditController = TextEditingController(
        text: widget.title.isNotEmpty ? widget.title : 'Error load title');
    _contentEditController = TextEditingController(
        text: widget.content.isNotEmpty ? widget.content : 'Error load note');
    super.initState();
  }

  @override
  void dispose() {
    _contentEditController.dispose();
    _titleEditController.dispose();
    super.dispose();
  }

  // String formatYear(Timestamp timestamp) {
  @override
  Widget build(BuildContext context) {
    String formattedCreatedTime = formatTimestamp(widget.time);

    final colour = Theme.of(context).brightness == Brightness.light
        ? Colors.black54
        : Colors.white54;
    final lcolour = Theme.of(context).brightness == Brightness.light
        ? Colors.black38
        : Colors.white38;

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            children: [
              const SizedBox(
                height: 100,
              ),
              TextField(
                cursorColor: mainColour,
                cursorOpacityAnimates: true,
                scrollPhysics: const BouncingScrollPhysics(),
                controller: _titleEditController,
                onTap: () {
                  setState(() {
                    _edit = true;
                  });
                },
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'poppins',
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
                enabled: _edit,
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: mainColour),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    formattedCreatedTime,
                    style: TextStyle(
                      color: lcolour,
                      wordSpacing: 0.0,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const Text(
                    ' | ',
                    style: TextStyle(
                      color: mainColour,
                      fontSize: 20,
                      fontFamily: 'poppins',
                    ),
                  ),
                  Text(
                    '${widget.content.length.toString()} Letters',
                    style: TextStyle(
                      wordSpacing: 0,
                      letterSpacing: -1.5,
                      color: lcolour,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                cursorColor: mainColour,
                scrollPhysics: const BouncingScrollPhysics(),
                cursorOpacityAnimates: true,
                style: TextStyle(
                  color: colour,
                  wordSpacing: -1.5,
                  letterSpacing: -1.5,
                ),
                enabled: _edit,
                controller: _contentEditController,
                maxLength: null,
                maxLines: null,
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: mainColour),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 150,
            padding: const EdgeInsets.only(left: 20, bottom: 20),
            // color: Colors.black38,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Theme.of(context).brightness == Brightness.light
                  //     ? Colors.black
                  //     : Colors.white,
                  Colors.black,
                  Colors.black87,
                  Colors.black54,
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        color: mainColour,
                      ),
                      Text(
                        'Notes',
                        style: TextStyle(
                          // color: inverseCol,
                          fontFamily: 'poppins',
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Share.share(widget.content);
                      },
                      icon: const Icon(
                        Icons.share,
                        color: mainColour,
                      ),
                    ),
                    _edit == false
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _edit = true;
                              });
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: mainColour,
                            ))
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                _edit = false;
                              });
                              _updateNote(
                                widget.id,
                                _titleEditController.text,
                                _contentEditController.text,
                              );
                            },
                            icon: const Icon(
                              Icons.done,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateNote(String noteId, String title, String content) async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(noteId)
        .update({
      'noteTitle': title,
      'noteContent': content,
      'editedTime': FieldValue.serverTimestamp(),
    });
  }
}
