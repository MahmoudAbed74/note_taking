import 'package:flutter/material.dart';
import 'package:app/add&removeNote.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/components/showAlteraget.dart';
//sign up with google
import 'package:google_sign_in/google_sign_in.dart';

class log_in extends StatefulWidget {
  const log_in({super.key});

  @override
  State<log_in> createState() => _log_inState();
}

class _log_inState extends State<log_in> {
  late String textData;
  late String EmailAdress;
  late String Passwordsave;
  late String PasswordData;
  bool val = false;
  GlobalKey<FormState> valid = new GlobalKey<FormState>();

  late UserCredential credential;
  // function for signing in with Google
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // function for logging in with email and password
  done() async {
    var StateDate = valid.currentState;
    //Check the Validatoin
    if (StateDate!.validate()) {
      StateDate.save();
      print("email adress: $EmailAdress");
      print(" Password: $Passwordsave");
      print("Valid");

      try {
        // show_loading(context);
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: EmailAdress,
          password: Passwordsave,
        );

        print("&" * 50);
        print(credential.user!.emailVerified);
        Navigator.of(context).pushNamed("Home Page");
        return credential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          //loading show to waiting only
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.rightSlide,
            title: 'user-not-found',
            desc: 'No user found for that email.',
            btnCancelOnPress: () {},
            btnOkOnPress: () {},
          )..show();
          print('No user found for that email.');
          print("==" * 20);
        } else if (e.code == 'wrong-password') {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.rightSlide,
            title: 'wrong-password',
            desc: 'Wrong password provided for that user',
            btnCancelOnPress: () {},
            btnOkOnPress: () {},
          ).show();
          print(
              'Wrong password provided for that user. \n#######################');
        } else if (credential.user!.emailVerified == false) {
          Navigator.of(context).pop();
          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.rightSlide,
            title: 'don\'t conformation email',
            desc: 'don\'t conformation email and check inbox Email',
            btnCancelOnPress: () {},
            btnOkOnPress: () {},
          ).show();
          print(
              'Wrong password provided for that user. \n#######################');
          print("==" * 20);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  "images/5.png",
                  fit: BoxFit.fill,
                  height: 150,
                  // width: 50,
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Form(
                    key: valid,
                    child: Column(
                      children: [
                        // TextFormField for email input
                        TextFormField(
                          cursorWidth: 3,
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.emailAddress,
                          // Validator for email input
                          validator: (text) {
                            textData = text!;
                            if (textData.isEmpty) {
                              return ("please write Email in Box ");
                            }
                            if (!textData.contains("@") ||
                                !textData.endsWith("com")) {
                              return ("please Write the Valid Email");
                            }

                            return null;
                          },

                          onEditingComplete: done,
                          autovalidateMode: AutovalidateMode.always,

                          //On Save
                          onSaved: (textsave) {
                            EmailAdress = textsave!;
                          },

                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: "Example@gmail.com",
                              hintStyle: TextStyle(color: Colors.black),
                              label: Text("Enter the Email"),
                              labelStyle: TextStyle(color: Colors.black),
                              enabled: true,
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.black)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 50))),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // TextFormField for password input
                        TextFormField(
                          cursorWidth: 3,
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !val,
                          maxLength: 25,
                          // Validator for password input
                          validator: (password) {
                            PasswordData = password!;
                            if (PasswordData.isEmpty) {
                              return ("Please Write password");
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.always,
                          onEditingComplete: done,

                          //on Save
                          onSaved: (textsave) {
                            Passwordsave = textsave!;
                          },
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.password),
                              hintText: "Password",
                              hintStyle: TextStyle(color: Colors.black),
                              label: Text("Enter the Password"),
                              labelStyle: TextStyle(color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.black)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.black))),
                        ),
                        // Checkbox for remember me functionality
                        Row(
                          children: [
                            Checkbox(
                                overlayColor:
                                    MaterialStatePropertyAll(Colors.blue),
                                checkColor: Colors.black,
                                shape: OvalBorder(),
                                value: val,
                                onChanged: (index) {
                                  setState(() {
                                    val = index!;
                                  });
                                }),
                            Text("Show Password")
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Row(
                            children: [
                              Text("You Haven't Emali "),
                              InkWell(
                                child: Text(
                                  "Clich Here",
                                  style: TextStyle(color: Colors.blue),
                                ),
                                onTap: () {
                                  Navigator.of(context).pushNamed("Sign Up");
                                },
                              )
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            var credential = await done();
                            if (credential.user!.emailVerified == true) {
                              if (credential != null) {
                                print(credential.user!.email);
                                Navigator.of(context)
                                    .pushReplacementNamed("Home Page");
                              }
                            }
                          },
                          child: Text(
                            "Log In",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.blue)),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              UserCredential signGoogle =
                                  await signInWithGoogle();
                              var user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                Navigator.of(context)
                                    .pushReplacementNamed("Home Page");
                              }
                            },
                            child: Text("sign up with Google")),
                      ],
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}
