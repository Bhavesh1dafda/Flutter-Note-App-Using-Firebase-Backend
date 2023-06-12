import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_note_app/notepage.dart';
import 'package:firebase_note_app/signupPage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginaPage extends StatefulWidget {
  const LoginaPage({Key? key}) : super(key: key);

  @override
  State<LoginaPage> createState() => _LoginaPageState();
}

class _LoginaPageState extends State<LoginaPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController PassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return  Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Log In"),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              height: 300,
              child: Lottie.asset("assets/93385-login.json"),),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: TextFormField(
                controller:emailController ,
                decoration: InputDecoration(border: OutlineInputBorder(),hintText: "Enter Your Email"),
                validator: (value){
                  if(value!.isEmpty){
                    return "Required";
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: TextFormField(
                controller:PassController ,
                decoration: const InputDecoration(border: OutlineInputBorder(),hintText: "Enter Your Password"),
                validator: (value){
                  if(value!.isEmpty){
                    return "Required";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: () async {
                if(_formKey.currentState!.validate()){
                  var password = PassController.text.trim();
                  var email = emailController.text.trim();
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    print("User Okk");
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>NotesHomePage()));

                  } on FirebaseAuthException catch (e) {
                    print("error $e");
                    if (e.code == 'user-not-found') {
                      print("No user found for that email");
                    } else if (e.code == 'wrong-password') {
                      print("Wrong password provided for that user.");

                    } else {
                      print("${e.message}");

                    }
                  }

                }
              },
              child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(color: Colors.blue,borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text("Log In")),),
            ), SizedBox(height: 20,),
            InkWell(
              onTap: (){
Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpPage()));
              },
              child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(color: Colors.blue,borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text("Sign Up")),),
            )
          ],),
        ),
      ),
    );
  }
}
