import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class edit_note extends StatefulWidget {
  final docid;
  final list;
  const edit_note({this.docid, this.list});
  @override
  State<edit_note> createState() => _edit_noteState();
}

class _edit_noteState extends State<edit_note> {
  final dateTime = DateFormat.yMd().add_jm().format(DateTime.now());
  CollectionReference node_notes =
      FirebaseFirestore.instance.collection("Notes");
  Reference ref = FirebaseStorage.instance.ref("images/");

  GlobalKey<FormState> stateform = new GlobalKey<FormState>();

  var Title_Note, Body_Note, url_image;
  File? file;
  String? Image_name;
  /* show_bottom_sheet
  This shows a bottom sheet that allows picking an image from either the gallery or camera.
  */
  show_bottom_sheet(context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Please Choose Image",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontFamily: AutofillHints.photo)),
                Container(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () async {
                      var imagePicked = ImagePicker();
                      var image = await imagePicked.pickImage(
                          source: ImageSource.gallery);

                      if (image != null) {
                        var rand = Random().nextInt(10000);
                        file = File(image.path);
                        var Image_name = "$rand" + basename(image.path);
                        // start Firebase Storage

                        ref = FirebaseStorage.instance
                            .ref("grallery")
                            .child("$Image_name");
                        Navigator.of(context).pop();
                      }
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined),
                          SizedBox(width: 10),
                          Text("upload Image from gallery",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: AutofillHints.photo))
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    var imagePicked = ImagePicker();
                    var image =
                        await imagePicked.pickImage(source: ImageSource.camera);

                    if (image != null) {
                      var rand = Random().nextInt(10000);
                      file = File(image.path);
                      var Image_name = "$rand" + basename(image.path);
                      ref = FirebaseStorage.instance
                          .ref("images/camera")
                          .child("$Image_name");
                      Navigator.of(context).pop();
                    }
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera),
                        SizedBox(width: 10),
                        Text("upload Image from camera",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontFamily: AutofillHints.photo))
                      ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /* edit_note
  This updates the note data in Firebase Firestore and Storage.
  */
  Future edit_note(context) async {
    if (file == null) {
      var statedata = stateform.currentState;

      if (statedata!.validate()) {
        //store data
        statedata.save();

        //start firebase store
        // امرر المعلومات id عن طريق widget.docid
        await node_notes.doc(widget.docid).update(
          {
            "Title Note": Title_Note,
            "Body Note": Body_Note,
            "user ID": FirebaseAuth.instance.currentUser!.uid,
            "time": dateTime,
          },
        ).then(
          (value) {
            print("succed");

            Navigator.of(context).pushNamed("Home Page");
          },
        ).catchError((e) {
          print("error : $e");
        });
      }
    } else {
      var statedata = stateform.currentState;
      if (statedata!.validate()) {
        //store data
        statedata.save();
        //start firebase storage

        await ref.putFile(file!);
        url_image = await ref.getDownloadURL();
        print("===" * 100);
        print(url_image);
        //start firebase store
        // امرر المعلومات id عن طريق widget.doci
        await node_notes.doc(widget.docid).update({
          "Title Note": Title_Note,
          "Body Note": Body_Note,
          "url image": url_image,
          "user ID": FirebaseAuth.instance.currentUser!.uid,
          "time": dateTime,
        }).then((_) {
          print('Document updated successfully.');
          print("==========" * 100);
          Navigator.of(context).pushNamed("Home Page");
        }).catchError((error) {
          print('Error updating document: $error');
          print("==========" * 100);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit note"),
      ),
      /* Form
      This contains the form fields for title and body, initialized with the existing note data.
      It also has buttons to edit or upload a new image.
      */
      body: Form(
          //key
          key: stateform,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: ListView(
              children: [
                SizedBox(
                  height: 10,
                ),
                // Title note
                TextFormField(
                  onSaved: (newValue) {
                    Title_Note = newValue;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return " please enter title note";
                    }
                    return null;
                  },
                  // القيمة المحفوظة من الليست
                  initialValue: widget.list["Title Note"],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    hintText: "Title Note",
                    labelText: "edit Title note",
                    labelStyle: Theme.of(context).textTheme.headlineSmall,
                    prefixIcon: Icon(Icons.note_add),
                  ),
                  minLines: 1,
                  maxLength: 25,
                ),
                SizedBox(
                  height: 10,
                ),
                // body note
                TextFormField(
                  onSaved: (newValue) {
                    Body_Note = newValue;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "please enter the note";
                    }
                    return null;
                  },
                  initialValue: widget.list['Body Note'],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    hintText: "Note",
                    labelText: "add body note",
                    labelStyle: Theme.of(context).textTheme.headlineSmall,
                    prefixIcon: Icon(Icons.note_add_rounded),
                  ),
                  minLines: 1,
                  maxLines: 6,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 60),
                    child: ElevatedButton(
                        onPressed: () {
                          show_bottom_sheet(context);
                        },
                        child: Text("Edit Image"))),
                SizedBox(
                  height: 5,
                ),
                Container(
                    height: 50,
                    child: ElevatedButton(
                        onPressed: () {
                          edit_note(context);
                        },
                        child: Text("edit note"))),
              ],
            ),
          )),
    );
  }
}
