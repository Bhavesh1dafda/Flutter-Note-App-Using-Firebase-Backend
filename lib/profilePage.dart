import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_note_app/notepage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController fullNameController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;

  File? _image;
  final picker = ImagePicker();

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future getImageGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 25);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('no image picked');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Profile"),
          centerTitle: true,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("usersData")
              .where("UserId", isEqualTo: user?.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {

              return const Text("something went wromg");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {

              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  var userID = snapshot.data?.docs[index]["UserId"];
                  var name = snapshot.data?.docs[index]["Name"];
                  var profileImage = snapshot.data?.docs[index]["ProfileImage"];
                  fullNameController..text = name;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Stack(children: [
                          InkWell(
                            onTap: () {
                              getImageGallery();
                            },
                            child: CircleAvatar(
                              radius: 80,
                              backgroundImage: (_image == null) ? NetworkImage(profileImage) : (FileImage(_image!) as ImageProvider?),
                              child: Visibility(
                                  visible: _image == null && profileImage == "",
                                  child: Icon(Icons.add_a_photo)),
                            ),
                          ),
                          Positioned(
                              bottom: 5,
                              right: 10,
                              child: InkWell(
                                onTap: (){
                                  getImageGallery();
                                },
                                child: Container(height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1,color: Colors.black),
                                      color: Colors.blue,borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: Icon(Icons.edit,color: Colors.white,size: 18,)),
                              )),
                        ],),

                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                              controller: fullNameController,
                              decoration: InputDecoration(
                                hintText: "Enter Your Name",
                                hintStyle: const TextStyle(
                                    fontSize: 20, color: Colors.black),
                                border: myinputborder(),
                                //normal border
                                enabledBorder: myinputborder(),
                                //enabled border
                                focusedBorder: myfocusborder(), //focused border
                                // set more border style like disabledBorder
                              )),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Container(
                          height: 60,
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  Future.delayed(
                                    Duration(seconds: 0),
                                    () async {
                                      if (_image != null) {
                                        firebase_storage.Reference ref =
                                            firebase_storage
                                                .FirebaseStorage.instance
                                                .ref(
                                                    '/ProfileImage/${DateTime.now().millisecondsSinceEpoch}');
                                        firebase_storage.UploadTask uploadTask =
                                            ref.putFile(_image!.absolute);
                                        Future.value(uploadTask)
                                            .then((value) async {
                                          var newUrl =
                                              await ref.getDownloadURL();
                                          FirebaseFirestore.instance
                                              .collection("usersData")
                                              .doc(user!.uid)
                                              .set({
                                            "ProfileImage":
                                                newUrl.toString() != null
                                                    ? newUrl.toString()
                                                    : profileImage,
                                            "Name":
                                                fullNameController.text.isEmpty
                                                    ? name
                                                    : fullNameController.text,
                                            "UpdatedAt": DateTime.now(),
                                            "UserId": user?.uid
                                          }, SetOptions(merge: true)).then(
                                                  (value) {
                                            fullNameController.clear();
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NotesHomePage()),
                                                    (Route<dynamic> route) =>
                                                        false);
                                          });
                                        });
                                      } else {
                                        FirebaseFirestore.instance
                                            .collection("usersData")
                                            .doc(user!.uid)
                                            .set({
                                          "Name":
                                              fullNameController.text.isEmpty
                                                  ? name
                                                  : fullNameController.text,
                                          "UpdatedAt": DateTime.now(),
                                          "UserId": user?.uid
                                        }, SetOptions(merge: true)).then(
                                                (value) {
                                          fullNameController.clear();
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              NotesHomePage()),
                                                  (Route<dynamic> route) =>
                                                      false);
                                        });
                                      }
                                    },
                                  );
                                  return AlertDialog(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    titlePadding: EdgeInsets.zero,
                                    content: Container(
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                            child: Text("Please Wait..."))),
                                  );
                                },
                              );
                            },
                            //icon data for elevated button
                            child: Text("Update Profile"), //label text
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }

            return Container();
          },
        ));
  }

  OutlineInputBorder myinputborder() {
    //return type is OutlineInputBorder
    return OutlineInputBorder(
        //Outline border type for TextFeild
        borderRadius: BorderRadius.all(Radius.circular(20)),
        borderSide: BorderSide(
          color: Colors.purple.withOpacity(0.50),
          width: 3,
        ));
  }

  OutlineInputBorder myfocusborder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        borderSide: BorderSide(
          color: Colors.purple,
          width: 3,
        ));
  }
}
