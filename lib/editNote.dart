import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'notepage.dart';

class EditNotes extends StatefulWidget {
  const EditNotes({Key? key}) : super(key: key);

  @override
  State<EditNotes> createState() => _EditNotesState();
}

class _EditNotesState extends State<EditNotes> {
  final editAmountController = TextEditingController();
  final editNoteController = TextEditingController();

  var id;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null &&
        Get.arguments["docId"] != null &&
        Get.arguments["docId"] is String) {
      id = Get.arguments["docId"];
    }
  }

  User? user = FirebaseAuth.instance.currentUser;

  bool loading = false;

  File? _image;

  final picker = ImagePicker();

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future getImageGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
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
          title: Text("Edit Bill Note"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      getImageGallery();
                    },
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      child: _image == null
                          ? Center(
                              child:
                                  Image.network(Get.arguments["BillImageUrl"]))
                          : Image.file(_image!.absolute),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Edit Amount"),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextFormField(
                  controller: editAmountController
                    ..text = Get.arguments["Amount"].toString(),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Enter Amount"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text("Edit Note"),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextFormField(
                  controller: editNoteController
                    ..text = Get.arguments["Note"].toString(),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Your Note"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () {
                  if (_image != null) {
                    firebase_storage.Reference ref =
                        firebase_storage.FirebaseStorage.instance.ref(
                            '/ProfileImage/${DateTime.now().millisecondsSinceEpoch}');
                    firebase_storage.UploadTask uploadTask =
                        ref.putFile(_image!.absolute);
                    Future.value(uploadTask).then((value) async {
                      var newUrl = await ref.getDownloadURL();
                      User? user = FirebaseAuth.instance.currentUser;
                      FirebaseFirestore.instance
                          .collection("usersData")
                          .doc(user?.uid)
                          .collection("notes")
                          .doc(id)
                          .set({
                        "BillImageUrl":newUrl.toString(),
                        "Note": editNoteController.text.trim(),
                        "Amount": editAmountController.text.trim(),
                      }, SetOptions(merge: true)).then((value) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => NotesHomePage()),
                                (Route<dynamic> route) => false);
                      });
                    });


                  } else {
                    User? user = FirebaseAuth.instance.currentUser;
                    FirebaseFirestore.instance
                        .collection("usersData")
                        .doc(user?.uid)
                        .collection("notes")
                        .doc(id)
                        .set({
                      "Note": editNoteController.text.trim(),
                      "Amount": editAmountController.text.trim(),
                    }, SetOptions(merge: true)).then((value) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => NotesHomePage()),
                          (Route<dynamic> route) => false);
                    });
                  }
                },
                child: Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text("Update Note")),
                ),
              ),
            ],
          ),
        ));
  }
}
