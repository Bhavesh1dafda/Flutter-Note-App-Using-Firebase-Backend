

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_note_app/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController PassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sign Up"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 250,
                child: Lottie.asset("assets/118046-lf20-oahmox5rjson.json"),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Name"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    }
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Email"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    }
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextFormField(
                  controller: PassController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Password"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    }
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () async {
                  var name = nameController.text.trim();
                  var email = emailController.text.trim();
                  var Pass = PassController.text.trim();
                  if (_formKey.currentState!.validate()) {
                    await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email, password: Pass)
                        .then((value) async {
                          print("user created");
                          User? user = FirebaseAuth.instance.currentUser;
                        await  FirebaseFirestore.instance.collection("usersData").doc(user!.uid).set({
                            "Name" : name,
                            "Email" : email,
                            "CreatedAt" : DateTime.now(),
                            "UserId" : user.uid,
                            "ProfileImage" : "",
                             "UpdatedAt": ""
                          }
                          ).then((value) {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginaPage()));
                            FirebaseAuth.instance.signOut();

                        });
                    });
                  }
                },
                child: Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text("Create Account")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
