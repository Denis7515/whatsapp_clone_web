import 'dart:typed_data';

import 'package:whatsapp_web/default%20colors/default_colors.dart';
import 'package:whatsapp_web/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class LoginSignUp extends StatefulWidget {
  const LoginSignUp({super.key});

  @override
  State<LoginSignUp> createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> {

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool doesUserWhantSignUp = false;
  Uint8List? selectedImage;
  bool errorInPicture = false;
  bool loadingOn = false;


  chooseImage() async {
    FilePickerResult ? chosenImageFile = await FilePicker.platform
    .pickFiles(type: FileType.image);
    setState(() {
      selectedImage = chosenImageFile!.files.single.bytes;
    });
  }

  uploadImageToStorage(UserModel userData) {
   if(selectedImage != null) {
    Reference imageRef = FirebaseStorage.instance.ref(
      'ProfileImages/${userData.uid}.jpg');
      UploadTask task = imageRef.putData(selectedImage!);
      task.whenComplete(() async {
       String urlImage = await task.snapshot.ref.getDownloadURL();
       userData.imageProfile = urlImage;

       //3. SAVE USERDATA TO FIRESTORE DATABASE
       await FirebaseAuth.instance.currentUser?.updateDisplayName(userData.name);
       await FirebaseAuth.instance.currentUser?.updatePhotoURL(urlImage);

       final usersReference = FirebaseFirestore.instance.collection('users_web');
       usersReference.doc(userData.uid).set(userData.toJson()).then((value) {
        setState(() {
          loadingOn = false;
        });
        Navigator.pushReplacementNamed(context, '/home');
       });
      });
   } else {
    var snackBar = const SnackBar(content: Center(child: Text('Please choose an image.')));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
   }
  }

  //1. REGISTER USER
  signUpUser(nameInput, emailInput, passwordInput) async {
    final userCreated = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailInput, password: passwordInput);
  
  //2. UPLOAD IMAGE TO FIRESTORE
  String? uid = userCreated.user!.uid;
    if(uid != null) {
    final userData = UserModel(uid, nameInput, emailInput, passwordInput);
    uploadImageToStorage(userData); 
   }
  }
  // LOGIN USER
  logInUser(emailInput, passwordInput) {
    FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailInput, password: passwordInput).then((value) {
            setState(() {
              loadingOn = false;
            });
            Navigator.pushReplacementNamed(context, '/home');
          });
  }
  
  registerOrLogin() {
    setState(() {
      loadingOn = true;
      errorInPicture = false;
    });
    String nameInput = nameController.text.trim();
    String emailInput = emailController.text.trim();
    String passwordInput = passwordController.text.trim();
    if(emailInput.isNotEmpty && emailInput.contains('@')) {
      if(passwordInput.isNotEmpty && passwordInput.length >= 6) {
        if(doesUserWhantSignUp == true) {
          
          if(nameInput.isNotEmpty && nameInput.length >= 3) {
           signUpUser(nameInput, emailInput, passwordInput);
          } else {
            var snackBar = const SnackBar(content: Center(child: Text('Name is not valid.')));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
         logInUser(emailInput, passwordInput);
        }
      } else {
        var snackBar = const SnackBar(content: Center(child: Text('Password is not valid.')));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
        loadingOn = false;
        });
      }
    } else {
      var snackBar = const SnackBar(content: Center(child: Text('Email is not valid.')));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
      loadingOn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        color: DefaultColors.backgroundColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [

            Positioned(child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
               color: DefaultColors.primaryColor,
            )),
            Center(child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(17),
                child: Card(
                  elevation: 5,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(17))
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    width: 500,
                    child: Column(
                      children: [
 
                        Visibility(
                          visible: doesUserWhantSignUp,
                          child: ClipOval(
                           child: selectedImage != null ? Image.memory(selectedImage! , 
                           width: 124, height: 124, fit: BoxFit.cover) : 
                      //     ClipOval(child: Container(color: Colors.grey.shade400, 
                      //     width: 124, height: 124,),)
                           Image.asset('profile_default.png', 
                           width: 124, height: 124, fit: BoxFit.cover),
                          )),
                          const SizedBox(height: 10),
                        Visibility(
                          visible: doesUserWhantSignUp,
                          child: OutlinedButton(
                            onPressed: () {
                              chooseImage();
                            },
                            style: errorInPicture ? OutlinedButton.styleFrom(side: const BorderSide(
                              color: Colors.red, width: 3)) : null,
                            child: const Text('Choose picture'),
                            ) ),
                            const SizedBox(height: 15),
                          Visibility(
                            visible: doesUserWhantSignUp,
                            child: TextField(
                              keyboardType: TextInputType.text,
                              controller: nameController,
                              decoration: const InputDecoration(
                                hintText: 'Your name',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6))) ),
                            )),
                            const SizedBox(height: 15),
                             TextField(
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              decoration: const InputDecoration(                             
                                hintText: 'Your email',
                                prefixIcon: Icon(Icons.email_outlined),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6))) ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              keyboardType: TextInputType.text,
                              controller: passwordController,
                              obscureText: true,
                              decoration:  InputDecoration(                             
                                hintText: doesUserWhantSignUp ? 'Password' : 'Your password',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6))) ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                registerOrLogin();
                              }, 
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DefaultColors.primaryColor),
                              child:  Padding(
                                padding: const EdgeInsets.symmetric( vertical: 8),
                                child: loadingOn ? const SizedBox(
                                  height: 23, width: 23, child: Center(child: CircularProgressIndicator(color: Colors.white)),
                                ) :  Text( doesUserWhantSignUp ? 'Register' : 'Login', 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              )),),
                              const SizedBox(height: 15),
                              Row(children: [
                                const Text('Login'),
                                Switch(value: doesUserWhantSignUp, onChanged: (bool value) {
                                  setState(() {
                                    doesUserWhantSignUp = value;
                                  });
                                },),
                                const Text('Register'),
                              ],)
                      ],
                    ),
                  ),
                ),
              ),
            ),)
          ],
        ),
      ),
    );
  }
}