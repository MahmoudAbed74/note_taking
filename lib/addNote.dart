import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:flutter/cupertino.dart';

class add_note extends StatefulWidget {
  const add_note({super.key});

  @override
  State<add_note> createState() => _add_noteState();
}

class _add_noteState extends State<add_note> {
/* animation button
This declares the ButtonState enums that control the state of the progress button used to add notes.
*/
  ButtonState stateOnlyText = ButtonState.idle;
  ButtonState stateTextWithIcon = ButtonState.idle;
  void onPressedIconWithText_succed() {
    switch (stateTextWithIcon) {
      case ButtonState.idle:
        stateTextWithIcon = ButtonState.loading;

        Future.delayed(
          Duration(seconds: 3),
          () {
            setState(
              () {
                stateTextWithIcon = ButtonState.success;
              },
            );
          },
        );

        break;
    }
    setState(
      () {
        stateTextWithIcon = stateTextWithIcon;
      },
    );
  }

  void onPressedIconWithText_failed() {
    switch (stateTextWithIcon) {
      case ButtonState.idle:
        stateTextWithIcon = ButtonState.loading;

        Future.delayed(
          Duration(seconds: 3),
          () {
            setState(
              () {
                stateTextWithIcon = ButtonState.fail;
              },
            );
          },
        );

        break;

      case ButtonState.loading:
        break;
      case ButtonState.success:
        stateTextWithIcon = ButtonState.idle;
        break;
      case ButtonState.fail:
        stateTextWithIcon = ButtonState.idle;
        break;
    }
    setState(
      () {
        stateTextWithIcon = stateTextWithIcon;
      },
    );
  }

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
                        onPressedIconWithText_succed();
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

/* addNotes
This adds the note data to Firebase Firestore and Storage.
*/
  Future addNotes(context) async {
    if (file == null)
      return {
        onPressedIconWithText_failed(),
        Future.delayed(Duration(seconds: 5), () {}),
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'please enter the Image',
          desc: 'please enter the Image from grallery or camera',
          btnOkOnPress: () {},
        )..show()
      };

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
      await node_notes.add({
        "Title Note": Title_Note,
        "Body Note": Body_Note,
        "url image": url_image,
        "user ID": FirebaseAuth.instance.currentUser!.uid,
        "time": dateTime,
      }).then(
        (value) {
          onPressedIconWithText_succed();

          Future.delayed(Duration(seconds: 5), () {
            Navigator.of(context).pushNamed("Home Page");
          });
        },
      ).catchError((e) {
        print("error : $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("add note"),
      ),
      /* Form
      This contains the form fields for title, body and an "Upload Image" button that calls show_bottom_sheet().
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    hintText: "Title Note",
                    labelText: "add Title note",
                    labelStyle: Theme.of(context).textTheme.headlineSmall,
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
                        child: Text("Upload Image"))),
                SizedBox(
                  height: 5,
                ),
                Container(
                    height: 50,
                    /* Progress button
                      This contains the progress button with different states for adding notes.
                    */
                    child: ProgressButton.icon(
                        iconedButtons: {
                          ButtonState.idle: IconedButton(
                              text: 'Add note',
                              icon: Icon(Icons.send, color: Colors.white),
                              color: Colors.blue),
                          ButtonState.loading: IconedButton(
                              text: 'Loading',
                              color: Colors.deepPurple.shade700),
                          ButtonState.success: IconedButton(
                              text: 'Success',
                              icon: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              color: Colors.green.shade400),
                          ButtonState.fail: IconedButton(
                              text: 'failed',
                              icon: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              color: Colors.green.shade400)
                        },
                        onPressed: () async {
                          addNotes(context);
                        },
                        state: stateTextWithIcon)),
              ],
            ),
          )),
    );
  }
}
