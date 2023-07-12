import 'package:app/editNote.dart';
import 'package:app/main.dart';
import 'package:app/viewnote.dart';
import 'package:flutter/material.dart';
import 'addNote.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'components/showAlteraget.dart';

class Home_page extends StatefulWidget {
  final Note_App;
  final mediaQurey;
  final docid;
  Home_page({this.Note_App, this.mediaQurey, this.docid});
  @override
  State<Home_page> createState() => _Home_pageState();
}

//function to exit App
void exitApp() {
  SystemNavigator.pop();
}

class _Home_pageState extends State<Home_page> {
  CollectionReference note = FirebaseFirestore.instance.collection("Notes");
  List userData = [];
  String? documentId;
  List userid = [];

// Function to retrieve data from Firebase Firestore
  getData() async {
// Get all notes for the current user
    var showallData = await note
        .where("user ID", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      // Add each note to the userData list
      for (final DocumentSnapshot documentSnapshot in showallData.docs) {
        documentId = documentSnapshot.id;
        final Object? doucumentdata = documentSnapshot.data();
        userData.add(doucumentdata);
        // Add the document ID to the userid list
        userid.add(documentId);
        print('Document ID: $documentId');
        print("*********" * 10);
      }
    });
  }

  @override
  void initState() {
    // Call the getData function when the widget is first built
    getData();
    print(userData);
    print(FirebaseAuth.instance.currentUser!.uid);

    print("==" * 100);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double mediaQurey =
        MediaQuery.of(context).size.width; // مقاس الشاشة بشكل عام
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            Text("Home Page", style: Theme.of(context).textTheme.displayLarge),
// Button to sign out the user
        leading: IconButton(
            icon: Icon(Icons.logout_outlined),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed("Log In");
            }),
        actions: [
          //for exist app without sigin out
          IconButton(
              onPressed: () {
                exitApp();
              },
              icon: Icon(Icons.exit_to_app)),
        ],
      ),
      // Button to add a new note
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed("add note");
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add)),
      body: userData.isEmpty || userData == null
          ? Center(
              child: Text(
              "loading",
              style: Theme.of(context).textTheme.labelLarge,
            ))
          : Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListView.builder(
                  itemCount: userData.length,
                  itemBuilder: (context, index) {
                    print(userData.length);
                    print(userData);
                    // Widget to display a single note and remove the note
                    return Dismissible(
                        //delete the note
                        onDismissed: (direction) async {
                          await note.doc(userid[index]).delete();
                          await FirebaseStorage.instance
                              .refFromURL(userData[index]["url image"])
                              .delete();
                          print("succed delete");
                        },
                        key: UniqueKey(),
                        child: List_notes(
                          shownotes: userData[index],
                          docid: userid[index],
                        ));
                  }),
            ),
    );
  }
}

// Widget to display a single note
class List_notes extends StatelessWidget {
  var shownotes;
  var docid;
  var clear;
  List_notes({this.shownotes, this.docid, this.clear});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          // Navigate to the view note page when the note is tapped
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return view_note(
                notes: shownotes,
              );
            },
          ));
        },
        child: Row(
          children: [
            Expanded(
                flex: 1, child: Image.network("${shownotes['url image']}")),
            Expanded(
              flex: 3,
              child: ListTile(
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return edit_note(
                        docid: docid,
                        list: shownotes,
                      );
                    }));
                  },
                ),
                title: Text("${shownotes['Title Note']}",
                    style: Theme.of(context).textTheme.headlineLarge),
                subtitle: Column(
                  children: [
                    Text(
                      "${shownotes['Body Note']}",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
