import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
//auth
import 'package:firebase_auth/firebase_auth.dart';
//sign up with google
import 'package:google_sign_in/google_sign_in.dart';
// firebase store
import 'package:cloud_firestore/cloud_firestore.dart';

class Sign_up extends StatefulWidget {
  const Sign_up({super.key});

  @override
  State<Sign_up> createState() => _Sign_upState();
}

class _Sign_upState extends State<Sign_up> {
  //sign google
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

  late String textData;
  late String EmailAdress;
  late String Passwordsave;
  late String PasswordData;
  late String Full_Name;
  late UserCredential credential;
// Valid phone Number regular expression
  RegExp regExp = new RegExp(r'[\+]{0,1}20[0-9]{11}');
  RegExp regExp1 = new RegExp(r'[0-9]{11}');
  bool val = false; //Show password
  bool val1 = false; // Show  Second password
  GlobalKey<FormState> valid = new GlobalKey<FormState>();

  done() async {
    // Check form validity and save input
    var StateDate = valid.currentState;
    //Check the Validatoin
    if (StateDate!.validate()) {
      StateDate.save();
      print("email adress: $EmailAdress");
      print(" Password: $Passwordsave");
      print("Valid");
      // Try creating user with email and password
      try {
        credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: EmailAdress,
          password: PasswordData,
        );

        return credential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.rightSlide,
            title: 'password Week',
            desc: 'The password provided is too weak.',
            btnCancelOnPress: () {},
            btnOkOnPress: () {},
          )..show();
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.info,
            animType: AnimType.rightSlide,
            title: 'account already exists',
            desc: 'The account already exists for that email',
            btnCancelOnPress: () {},
            btnOkOnPress: () {},
          )..show();
          print('The account already exists for that email.');
        }
        // Handle auth exceptions
      } catch (e) {
        print(e);
      }
    } else {
      print("^" * 100);
      print("Not Valid");
      print("<>" * 100);
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
                        // TextFormField For Name
                        TextFormField(
                          cursorWidth: 3,
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.name,
                          //Validtor
                          validator: (text) {
                            textData = text!;
                            if (textData.isEmpty) {
                              return ("please write Your Full Name ");
                            }

                            return null;
                          },

                          onEditingComplete: done,
                          autovalidateMode: AutovalidateMode.always,

                          //On Save
                          onSaved: (textsave) {
                            Full_Name = textsave!;
                          },

                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person_2),
                              hintText: "Full Name",
                              hintStyle: TextStyle(color: Colors.black),
                              label: Text("Full Name"),
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
                        // TextFormField for phone
                        TextFormField(
                          cursorWidth: 3,
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.phone,
                          //Validtor
                          validator: (text) {
                            textData = text!;
                            if (textData.isEmpty) {
                              return ("please write the Phone Number ");
                            }
                            if (regExp1.hasMatch(textData) == false &&
                                regExp.hasMatch(textData) == false) {
                              return ("the phone number is Error");
                            }

                            return null;
                          },

                          // onEditingComplete: done,
                          autovalidateMode: AutovalidateMode.always,
                          maxLength: 14,
                          initialValue: "+20",
                          //On Save
                          onSaved: (textsave) {
                            EmailAdress = textsave!;
                          },

                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: "Phone Number",
                              hintStyle: TextStyle(color: Colors.black),
                              label: Text("Enter the Phone Number"),
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
                          height: 5,
                        ),
                        //TextFormFiled Email.com
                        TextFormField(
                          cursorWidth: 3,
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.emailAddress,
                          //Validtor
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
                        //TextFormFiled Password
                        TextFormField(
                          cursorWidth: 3,
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !val,
                          maxLength: 25,
                          //Validtor
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
                        // Confirmation the password
                        //Second TextFormField For Password
                        //TextFormFiled Password
                        TextFormField(
                          cursorWidth: 3,
                          textDirection: TextDirection.ltr,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !val1,
                          maxLength: 25,

                          //on Save
                          onSaved: (textsave) {
                            Passwordsave = textsave!;
                          },
                          //Validtor
                          validator: (password) {
                            Passwordsave = password!;
                            if (password.isEmpty) {
                              return ("Please Write Confimation ");
                            }
                            if (Passwordsave != PasswordData) {
                              return ("the password is Different");
                            }
                            if (Passwordsave == PasswordData) {
                              return null;
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.always,
                          onEditingComplete: done,

                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.password),
                              hintText: " Same Password",
                              hintStyle: TextStyle(color: Colors.black),
                              label: Text("Enter the Same Password"),
                              labelStyle: TextStyle(color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.black)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.black))),
                        ),
                        Row(
                          children: [
                            Checkbox(
                                overlayColor:
                                    MaterialStatePropertyAll(Colors.blue),
                                checkColor: Colors.black,
                                shape: OvalBorder(),
                                value: val1,
                                onChanged: (index) {
                                  setState(() {
                                    val1 = index!;
                                  });
                                }),
                            Text("Show Password")
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Row(
                            children: [
                              Text("You Have Emali "),
                              InkWell(
                                child: Text(
                                  "Clich Here",
                                  style: TextStyle(color: Colors.blue),
                                ),
                                onTap: () {
                                  Navigator.of(context).pushNamed("Log In");
                                  Navigator.of(context).canPop();
                                },
                              )
                            ],
                          ),
                        ),
                        // ElevatedButton to sign up user
                        ElevatedButton(
                          onPressed: () async {
                            var credential = await done();
                            Navigator.of(context).pushNamed("Home Page");
                            if (credential != null) {
                              FirebaseFirestore.instance
                                  .collection("User")
                                  .add({
                                "Email": EmailAdress,
                                "user name": Full_Name,
                                "phone number": textData,
                                "password": PasswordData,
                              }); // Use credential, we know it's a UserCredential
                              print("&" * 50);
                              print(credential.user!.email);
                              print("-" * 50);
                            }
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.blue)),
                        ),
                        // ElevatedButton to sign up with Google
                        ElevatedButton(
                            onPressed: () async {
                              // Sign in with Google
                              UserCredential signGoogle =
                                  await signInWithGoogle();
                              var user = FirebaseAuth.instance.currentUser;

                              if (user != null) {
                                await FirebaseFirestore.instance
                                    .collection("User")
                                    .add({
                                  "emali": signGoogle.user?.email,
                                  "user name": signGoogle.user?.displayName,
                                  "phone": signGoogle.user?.phoneNumber,
                                });
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
